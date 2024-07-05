# main.tf
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association
resource "aws_route53_zone" "this" {
  name = local.domain_name
}

module "ses_domain_identity" {
  source = "../../../../modules/aws_ses_domain_identity"

  domain_name = aws_route53_zone.this.name

  bounce_notification_topic_arn    = local.notifications_sns_topic_arn
  complaint_notification_topic_arn = local.notifications_sns_topic_arn
}

