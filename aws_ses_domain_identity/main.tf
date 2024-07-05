# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity
resource "aws_ses_domain_identity" "this" {
  domain = data.aws_route53_zone.this.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "verification_record" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "_amazonses.${data.aws_route53_zone.this.name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.this.verification_token]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim
resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "amazonses_dkim_record" {
  count   = 3

  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_notification_topic
resource "aws_ses_identity_notification_topic" "bounce" {
  count = var.bounce_notification_topic_arn != "" ? 1 : 0

  identity                 = aws_ses_domain_identity.this.domain
  notification_type        = "Bounce"
  topic_arn                = var.bounce_notification_topic_arn
  include_original_headers = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_notification_topic
resource "aws_ses_identity_notification_topic" "complaint" {
  count = var.complaint_notification_topic_arn != "" ? 1 : 0

  identity                 = aws_ses_domain_identity.this.domain
  notification_type        = "Complaint"
  topic_arn                = var.complaint_notification_topic_arn
  include_original_headers = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_identity_notification_topic
resource "aws_ses_identity_notification_topic" "delivery" {
  count = var.delivery_notification_topic_arn != "" ? 1 : 0

  identity                 = aws_ses_domain_identity.this.domain
  notification_type        = "Delivery"
  topic_arn                = var.delivery_notification_topic_arn
  include_original_headers = true
}
