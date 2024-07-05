output "sms_limit_usd" {
  value       = var.sms_limit_usd
  sensitive   = false
  description = "SMS Limit in USD"
}

output "default_sender_id" {
  value       = var.default_sender_id
  sensitive   = false
  description = "Default Sender ID"
}

output "default_sms_type" {
  value       = var.default_sms_type
  sensitive   = false
  description = "Default SMS type"
}

output "sms_limit_alarm_arn" {
  value = var.notification_topic_arn != "" ? aws_cloudwatch_metric_alarm.this[0].arn : null
  sensitive   = false
  description = "SMS Limit CloudWatch Alarm ARN"
}

output "sms_limit_alarm_name" {
  value = var.notification_topic_arn != "" ? aws_cloudwatch_metric_alarm.this[0].alarm_name : null
  sensitive   = false
  description = "SMS Limit CloudWatch Alarm Name"
}

output "sms_limit_alarm_threshold" {
  value = var.notification_topic_arn != "" ? aws_cloudwatch_metric_alarm.this[0].threshold : null
  sensitive   = false
  description = "SMS Limit CloudWatch Alarm Threshold"
}
