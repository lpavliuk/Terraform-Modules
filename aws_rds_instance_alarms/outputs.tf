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

output "cpu_credit_balance_too_low_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "cpu_credit_balance_too_low", {arn: null}).arn
  sensitive   = false
  description = "'CPU Credit Balance' alarm's ARN"
}

output "cpu_credit_balance_too_low_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "cpu_credit_balance_too_low", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'CPU Credit Balance' alarm's Name"
}

output "cpu_credit_balance_too_low_alarm_threshold" {
  value       = var.enable_cpu_credit_balance_alarms ? var.cpu_credit_balance_too_low_threshold : null
  sensitive   = false
  description = "'CPU Credit Balance' alarm's Threshold"
}

output "read_iops_too_high_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "read_iops_too_high", {arn: null}).arn
  sensitive   = false
  description = "'Read IOPS' alarm's ARN"
}

output "read_iops_too_high_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "read_iops_too_high", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Read IOPS' alarm's Name"
}

output "read_iops_too_high_alarm_threshold" {
  value       = var.enable_read_iops_alarms ? var.read_iops_too_high_threshold : null
  sensitive   = false
  description = "'Read IOPS' alarm's Threshold"
}

output "burst_balance_too_low_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "burst_balance_too_low", {arn: null}).arn
  sensitive   = false
  description = "'Burst Balance' alarm's ARN"
}

output "burst_balance_too_low_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "burst_balance_too_low", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Burst Balance' alarm's Name"
}

output "burst_balance_too_low_alarm_threshold" {
  value       = var.enable_burst_balance_alarms ? var.burst_balance_too_low_threshold : null
  sensitive   = false
  description = "'Burst Balance' alarm's Threshold"
}

output "disk_queue_depth_too_high_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "disk_queue_depth_too_high", {arn: null}).arn
  sensitive   = false
  description = "'Disk Queue Depth' alarm's ARN"
}

output "disk_queue_depth_too_high_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "disk_queue_depth_too_high", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Disk Queue Depth' alarm's Name"
}

output "disk_queue_depth_too_high_alarm_threshold" {
  value       = var.enable_disk_queue_depth_alarms ? var.disk_queue_depth_too_high_threshold : null
  sensitive   = false
  description = "'Disk Queue Depth' alarm's Threshold"
}

output "freeable_memory_too_low_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "freeable_memory_too_low", {arn: null}).arn
  sensitive   = false
  description = "'Freeable Memory' alarm's ARN"
}

output "freeable_memory_too_low_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "freeable_memory_too_low", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Freeable Memory' alarm's Name"
}

output "freeable_memory_too_low_alarm_threshold" {
  value       = var.enable_freeable_memory_alarms ? var.freeable_memory_too_low_threshold : null
  sensitive   = false
  description = "'Freeable Memory' alarm's Threshold"
}

output "disk_free_storage_space_threshold_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "disk_free_storage_space_threshold", {arn: null}).arn
  sensitive   = false
  description = "'Disk Free Storage Space' alarm's ARN"
}

output "disk_free_storage_space_threshold_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "disk_free_storage_space_threshold", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Disk Free Storage Space' alarm's Name"
}

output "disk_free_storage_space_alarm_threshold" {
  value       = var.enable_disk_free_storage_space_alarms ? var.disk_free_storage_space_threshold : null
  sensitive   = false
  description = "'Disk Free Storage Space' alarm's Threshold"
}

output "memory_swap_usage_too_high_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "memory_swap_usage_too_high", {arn: null}).arn
  sensitive   = false
  description = "'Swap Usage' alarm's ARN"
}

output "memory_swap_usage_too_high_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "memory_swap_usage_too_high", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Swap Usage' alarm's Name"
}

output "memory_swap_usage_too_high_alarm_threshold" {
  value       = var.enable_memory_swap_usage_alarms ? var.memory_swap_usage_too_high_threshold : null
  sensitive   = false
  description = "'Swap Usage' alarm's Threshold"
}

output "db_connections_limit_alarm_arn" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "db_connections_limit", {arn: null}).arn
  sensitive   = false
  description = "'Database Connections' alarm's ARN"
}

output "db_connections_limit_alarm_name" {
  value       = lookup(aws_cloudwatch_metric_alarm.this, "db_connections_limit", {alarm_name: null}).alarm_name
  sensitive   = false
  description = "'Database Connections' alarm's Name"
}

output "db_connections_limit_alarm_threshold" {
  value       = var.enable_db_connections_alarms ? var.db_connections_limit_threshold : null
  sensitive   = false
  description = "'Database Connections' alarm's Threshold"
}

