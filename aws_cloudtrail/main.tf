# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail
resource "aws_cloudtrail" "this" {
  name                          = var.name
  enable_logging                = var.enabled
  is_organization_trail         = var.is_organization_trail
  is_multi_region_trail         = var.is_multi_region_trail
  enable_log_file_validation    = true # to detect tampering
  include_global_service_events = var.include_global_service_events
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  # Send logs to CloudWatch Logs
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_role.arn
  # Send logs to S3
  s3_bucket_name                = var.s3_bucket_name != "" ? var.s3_bucket_name : null
  s3_key_prefix                 = var.s3_bucket_key_prefix != "" ? var.s3_bucket_key_prefix : null

  sns_topic_name                = var.sns_topic_arn != "" ? var.sns_topic_arn : null

  # Enable Insights
#  dynamic "insight_selector" {
#    for_each = compact([
#      var.api_call_rate_insight ? "ApiCallRateInsight" : null,
#      var.api_error_rate_insight ? "ApiErrorRateInsight" : null,
#    ])
#    content {
#      insight_type = insight_selector.value
#    }
#  }

  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = ["kms.amazonaws.com", "rdsdata.amazonaws.com"]
  }

  depends_on = [
    aws_kms_key.cloudtrail,
    aws_kms_alias.cloudtrail,
  ]
}

# ================================================
# CloudWatch Log Group:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name_prefix       = "cloudtrail-${var.name}-"
  retention_in_days = var.cloudwatch_log_group_retention_days
  kms_key_id        = aws_kms_key.cloudtrail.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name_prefix        = "cloudtrail-${var.name}-"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  inline_policy {
    name   = "WriteCloudWatchLogs"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "inline_policy" {
  statement {
    sid       = "WriteCloudWatchLogs"
    effect    = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.cloudtrail.arn}:*"]
  }
}


# ================================================
# KMS Key:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "cloudtrail" {
  description             = "A KMS key used to encrypt CloudTrail log files stored in S3."
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.cloudtrail_kms.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "cloudtrail_kms" {
  # The default AWS CloudTrail policy
  # Source: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/default-cmk-policy.html
  statement {
    sid     = "Enable IAM User Permissions"
    effect  = "Allow"
    actions = ["kms:*"]

    principals {
      type = "AWS"

      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.this.account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid     = "Allow CloudTrail to encrypt logs"
    effect  = "Allow"
    actions = ["kms:GenerateDataKey*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.this.account_id}:trail/*"]
    }
  }

  statement {
    sid     = "Allow CloudTrail to describe key"
    effect  = "Allow"
    actions = ["kms:DescribeKey"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.this.account_id}:trail/*"]
    }
  }

  statement {
    sid     = "Allow alias creation during setup"
    effect  = "Allow"
    actions = ["kms:CreateAlias"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.region}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.this.account_id}:trail/*"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow logs KMS access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Cloudtrail to decrypt and generate key for sns access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt*",
      "kms:GenerateDataKey*",
    ]
    resources = ["*"]
  }
}
