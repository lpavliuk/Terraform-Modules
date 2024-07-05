output "cpu_utilization_too_high_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "cpu_utilization_too_high", {arn: null}).arn
  sensitive   = false
  description = "'CPU Utilization Too High' alarm's ARN"
}

output "cpu_utilization_too_high_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "cpu_utilization_too_high", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'CPU Utilization Too High' alarm's Name"
}

output "cpu_utilization_too_high_alarm_threshold" {
  value       = var.enable_cpu_utilization_alarms ? var.cpu_utilization_too_high_threshold : null
  sensitive   = false
  description = "'CPU Utilization Too High' alarm's Threshold"
}
