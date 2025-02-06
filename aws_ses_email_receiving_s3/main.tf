# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_receipt_rule_set
resource "aws_ses_receipt_rule_set" "this" {
  rule_set_name = var.codename
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_receipt_rule_set
resource "aws_ses_active_receipt_rule_set" "this" {
  count         = var.is_active ? 1 : 0
  depends_on    = [aws_ses_receipt_rule.this]
  rule_set_name = aws_ses_receipt_rule_set.this.rule_set_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_receipt_rule
resource "aws_ses_receipt_rule" "this" {
  for_each = { for rule in var.rules: rule.codename => rule }

  name          = each.value.codename
  rule_set_name = aws_ses_receipt_rule_set.this.rule_set_name
  recipients    = formatlist("%s${var.email_domain_name}",each.value.emails_prefix)
  enabled       = each.value.enabled
  scan_enabled  = each.value.scan
  tls_policy    = "Require"

  s3_action {
    bucket_name       = each.value.s3_bucket
    object_key_prefix = each.value.s3_bucket_prefix
    iam_role_arn      = aws_iam_role.ses.arn
    position          = 1
  }
}

/**************************************************
 * IAM Role
 **/
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ses" {
  name_prefix        = "ses-${var.codename}-"
  assume_role_policy = data.aws_iam_policy_document.ses_assume_role.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "ses_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = formatlist("${aws_ses_receipt_rule_set.this.arn}:receipt-rule/%s", [for rule in var.rules: rule.codename])
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "ci_permissions" {
  name_prefix = "s3-permissions-"
  role        = aws_iam_role.ses.id
  policy      = data.aws_iam_policy_document.s3_bucket_pricing_registry.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "s3_bucket_pricing_registry" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = distinct(concat(
      formatlist("arn:aws:s3:::%s", [for rule in var.rules: rule.s3_bucket]),
      formatlist("arn:aws:s3:::%s/*", [for rule in var.rules: rule.s3_bucket])
    ))
  }
}

/**************************************************
 * Domain Name Verification (Route 53)
 **/
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "mx" {
  zone_id = var.domain_zone_id
  name    = var.email_domain_name
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity
resource "aws_ses_domain_identity" "email_receiving" {
  domain = var.email_domain_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "email_receiving_verification_record" {
  zone_id = var.domain_zone_id
  name    = "_amazonses.${var.email_domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.email_receiving.verification_token]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim
resource "aws_ses_domain_dkim" "email_receiving" {
  domain = aws_ses_domain_identity.email_receiving.domain
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "email_receiving_amazonses_dkim_record" {
  count   = 3

  zone_id = var.domain_zone_id
  name    = "${aws_ses_domain_dkim.email_receiving.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.email_receiving.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

