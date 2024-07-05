# main.tf
module "sms" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_sns_sms"

  sms_limit_usd          = 50
  default_sender_id      = "Example"
  default_sms_type       = "Transactional"

  notification_topic_arn = local.notification_topic_arn # Creates CloudWatch Alarm
}
