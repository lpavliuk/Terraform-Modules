# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "this" {
  bucket        = var.name != null ? substr(var.name, 0, 62) : null
  bucket_prefix = var.name == null ? substr(var.bucket_prefix, 0, 36) : null
  force_destroy = var.force_destroy

  lifecycle {
    precondition {
      error_message = "Either name or bucket_prefix must be defined!"
      condition     = var.name != null || var.bucket_prefix != null
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.is_public ? false : true
  block_public_policy     = var.is_public ? false : true
  ignore_public_acls      = var.is_public ? false : true
  restrict_public_buckets = var.is_public ? false : true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.is_public ? "BucketOwnerPreferred" : "ObjectWriter"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this.id
  acl    = var.is_public ? "public-read" : var.acl
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this] # Must have bucket versioning enabled first

  bucket = aws_s3_bucket.this.id

  rule {
    id = "all_objects"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_after_days
    }

    expiration {
      days                         = var.current_version_expiration_days != 0 ? var.current_version_expiration_days : null
      expired_object_delete_marker = var.current_version_expiration_days != 0 ? null : var.expired_object_delete_marker
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = var.keep_last_versions_number > 0 ? var.keep_last_versions_number : null
      noncurrent_days           = var.noncurrent_version_expiration_days
    }

    dynamic "noncurrent_version_transition" {
      for_each = { for conf in var.version_transitions : conf.storage_class => conf }

      content {
        newer_noncurrent_versions = lookup(noncurrent_version_transition.value, "keep_last_versions_number", null)
        noncurrent_days           = lookup(noncurrent_version_transition.value, "after_days", null)
        storage_class             = lookup(noncurrent_version_transition.value, "storage_class", null)
      }
    }

    status = var.enable_versioning || var.current_version_expiration_days != 0 ? "Enabled" : "Disabled"
  }
}

# ============================================
# Bucket Replication:
# ============================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  count = var.enable_replication ? 1 : 0

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.this.id

  rule {
    id = "ReplicaRule"

    status = "Enabled"

    # Must be defined to specify the V2 replication configuration
    filter {}

    destination {
      bucket        = var.replica_bucket_arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = var.delete_marker_replication ? "Enabled" : "Disabled"
    }
  }

  lifecycle {
    precondition {
      condition     = !var.enable_replication || (var.enable_replication && var.replica_bucket_arn != "")
      error_message = "If enable_replication is true, replica_bucket_arn is required!"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "replication" {
  count    = var.enable_replication ? 1 : 0

  name_prefix        = "s3-replication-role-"
  description        = "S3 ${aws_s3_bucket.this.bucket}"
  assume_role_policy = data.aws_iam_policy_document.replica_role[0].json

  inline_policy {
    name   = "S3_Replication_Policy_${replace(aws_s3_bucket.this.bucket, "-", "_")}"
    policy = data.aws_iam_policy_document.replication[0].json
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "replica_role" {
  count    = var.enable_replication ? 1 : 0

  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "replication" {
  count    = var.enable_replication ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = ["${var.replica_bucket_arn}/*"]
  }
}

# ============================================
# S3 Batch Operation: Replicate Existed Objects
# ============================================
# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
resource "null_resource" "s3_batch_operation" {
  count    = var.enable_replication ? 1 : 0

  provisioner "local-exec" {
    # Creates an S3 Batch Replication job using a S3 generated manifest
    command = <<-EOT
      aws s3control create-job \
        --account-id ${data.aws_caller_identity.current.account_id} \
        --operation '{"S3ReplicateObject":{}}' \
        --priority 1 \
        --report '{"Enabled": false}' \
        --manifest-generator '{"S3JobManifestGenerator": {"SourceBucket": "${aws_s3_bucket.this.arn}", "EnableManifestOutput": false, "Filter": {"EligibleForReplication": true, "ObjectReplicationStatuses": ["NONE","FAILED"]}}}' \
        --role-arn ${aws_iam_role.s3_batch_operation[0].arn} \
        --no-confirmation-required \
        --profile ${var.aws_cli_profile} \
        --region ${data.aws_region.current.region}
EOT
  }

  # Must have the Replication created first
  depends_on = [aws_s3_bucket_replication_configuration.replication]

  lifecycle {
    precondition {
      condition     = !var.enable_replication || (var.enable_replication && var.aws_cli_profile != "")
      error_message = "If enable_replication is true, aws_cli_profile is required!"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "s3_batch_operation" {
  count    = var.enable_replication ? 1 : 0

  name_prefix        = "s3-batch-operation-role-"
  description        = "S3 ${aws_s3_bucket.this.bucket}: Replicating existed objects"
  assume_role_policy = data.aws_iam_policy_document.s3_batch_operation_role[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policies_exclusive
resource "aws_iam_role_policies_exclusive" "s3_batch_operation" {
  count    = var.enable_replication ? 1 : 0

  role_name    = aws_iam_role.s3_batch_operation[0].name
  policy_names = [aws_iam_role_policy.s3_batch_operation_policy[0].name]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "s3_batch_operation_policy" {
  count    = var.enable_replication ? 1 : 0

  name   = "S3_Batch_Operation_Policy_${replace(aws_s3_bucket.this.bucket, "-", "_")}"
  role   = aws_iam_role.s3_batch_operation[0].id
  policy = data.aws_iam_policy_document.s3_batch_operation[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "s3_batch_operation_role" {
  count    = var.enable_replication ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["batchoperations.s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "s3_batch_operation" {
  count    = var.enable_replication ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:InitiateReplication"
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::{{ManifestDestination}}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::{{ReportBucket}}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:PutInventoryConfiguration"
    ]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::{{ManifestDestination}}/*"]
  }
}

# ============================================
# Custom Policies:
# ============================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "read_only" {
  count = var.create_iam_policies ? 1 : 0

  name        = "x2_S3Bucket_${replace(aws_s3_bucket.this.bucket, "-", "_")}_Read_Only"
  description = "Access to S3 Bucket ${aws_s3_bucket.this.bucket} Read Only"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:ListBucketMultipartUploads",
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
        ]
      }
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "write_read_only" {
  count = var.create_iam_policies ? 1 : 0

  name        = "x2_S3Bucket_${replace(aws_s3_bucket.this.bucket, "-", "_")}_WriteRead_Only"
  description = "Access to S3 Bucket ${aws_s3_bucket.this.bucket} WriteRead Only"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:AbortMultipartUpload",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
        ]
      }
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "full_access" {
  count = var.create_iam_policies ? 1 : 0

  name        = "x2_S3Bucket_${replace(aws_s3_bucket.this.bucket, "-", "_")}_FullAccess"
  description = "Access to S3 Bucket ${aws_s3_bucket.this.bucket} FullAccess Only"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:AbortMultipartUpload",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
        ]
      }
    ]
  })
}

