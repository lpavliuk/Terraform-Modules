locals {
  alarms = [
    {
      codename            : "cpu_utilization_too_high",
      name                : "${var.name_prefix}ec2-${var.ec2_instance_codename}-highCPUUtilization",
      is_enabled          : var.enable_cpu_utilization_alarms
      metric_name         : "CPUUtilization",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.cpu_utilization_too_high_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average EC2 CPU utilization too high"
    },
    {
      codename            : "mem_utilization_too_high",
      name                : "${var.name_prefix}ec2-${var.ec2_instance_codename}-highMemUtilization",
      is_enabled          : var.enable_mem_utilization_alarms
      namespace           : "CWAgent/EC2",
      metric_name         : "mem_used_percent",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.mem_utilization_too_high_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average EC2 Memory utilization too high"
    },
    {
      codename            : "disk_utilization_too_high",
      name                : "${var.name_prefix}ec2-${var.ec2_instance_codename}-highDiskUtilization",
      is_enabled          : var.enable_disk_utilization_alarms
      namespace           : "CWAgent/EC2",
      metric_name         : "disk_used_percent",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.disk_utilization_too_high_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average EC2 Disk utilization too high"
    },
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = { for alarm in local.alarms : alarm.codename => alarm if alarm.is_enabled }

  alarm_name          = lookup(each.value, "name", null)
  alarm_description   = lookup(each.value, "description", null)
  comparison_operator = lookup(each.value, "comparison_operator", null)
  evaluation_periods  = lookup(each.value, "evaluation_periods", null)
  metric_name         = lookup(each.value, "metric_name", null)
  namespace           = lookup(each.value, "namespace", "AWS/EC2")
  period              = var.statistics_period
  statistic           = "Average"
  threshold           = lookup(each.value, "threshold", null)
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = { # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html#ec2-cloudwatch-dimensions
    InstanceId = var.ec2_instance_id
  }
}
