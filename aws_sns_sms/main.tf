# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_sms_preferences
resource "aws_sns_sms_preferences" "this" {
  monthly_spend_limit = var.sms_limit_usd
  default_sender_id   = var.default_sender_id
  default_sms_type    = var.default_sms_type
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  count = var.notification_topic_arn != "" ? 1 : 0

  alarm_name                = "aws-sns-${data.aws_caller_identity.current.account_id}-sms-spending-limit"
  alarm_description         = "Monthly SMS Limit! SMS spending has almost reached the limit: ${var.sms_limit_usd} USD"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "SMSMonthToDateSpentUSD"
  namespace                 = "AWS/SNS"
  period                    = 60 # sec
  statistic                 = "Maximum"
  threshold                 = (var.sms_limit_usd / 100) * var.sms_limit_alarm_threshold_percent
  alarm_actions             = [var.notification_topic_arn]

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-missing-data
  treat_missing_data        = "notBreaching"
}