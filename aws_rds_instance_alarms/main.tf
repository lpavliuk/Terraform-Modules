locals {
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.MaxConnections
  # Max Connections: DBInstanceClassMemoryBytes/12582880
  # db.t3.micro: 1 GiB (RDS Instance RAM) = 1073741824 bytes (DBInstanceClassMemoryBytes)
  max_connections_limit = (local.datasets.db_instance_classes_memory_gib[var.db_instance_class] * 1073741824) / 12582880
  # NOTE: The threshold is set to approximately 10% less than the actual limit because the RDS reserves a significant portion of
  # the available memory for the operating system and the RDS processes that manage the DB instance.
  db_connections_limit_threshold = floor((local.max_connections_limit / 100) * (var.db_connections_limit_threshold - 10))
  alarm_name_prefix = "${var.name_prefix}rds-${var.db_cluster_name == "" ? var.db_instance_name : var.db_cluster_name}"
  alarms = [
    {
      codename            : "cpu_utilization_too_high",
      name                : "${local.alarm_name_prefix}-highCPUUtilization",
      is_enabled          : var.enable_cpu_utilization_alarms
      metric_name         : "CPUUtilization",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.cpu_utilization_too_high_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average database CPU utilization too high"
    },
    {
      codename            : "cpu_credit_balance_too_low",
      name                : "${local.alarm_name_prefix}-lowCPUCreditBalance",
      is_enabled          : var.enable_cpu_credit_balance_alarms
      metric_name         : "CPUCreditBalance",
      comparison_operator : "LessThanThreshold",
      threshold           : var.cpu_credit_balance_too_low_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average database CPU credit balance too low, expect a significant performance drop soon"
    },
    {
      codename            : "read_iops_too_high",
      name                : "${local.alarm_name_prefix}-highReadIOPS",
      is_enabled          : var.enable_read_iops_alarms
      metric_name         : "ReadIOPS",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.read_iops_too_high_threshold
      evaluation_periods  : "1" #
      description         : "Average database Read IOPS too high"
    },
    { // Aurora only
      codename            : "select_throughput_too_high",
      name                : "${local.alarm_name_prefix}-highSelectThroughput",
      is_enabled          : var.is_aurora ? var.enable_select_throughput_alarms : false
      metric_name         : "SelectThroughput",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.select_throughput_too_high_threshold
      evaluation_periods  : "1" #
      description         : "Average database Select Throughput too high"
    },
    {
      codename            : "burst_balance_too_low",
      name                : "${local.alarm_name_prefix}-lowEBSBurstBalance",
      is_enabled          : var.enable_burst_balance_alarms
      metric_name         : "BurstBalance",
      comparison_operator : "LessThanThreshold",
      threshold           : var.burst_balance_too_low_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average database storage burst balance too low, expect a significant performance drop soon"
    },
    {
      codename            : "disk_queue_depth_too_high",
      name                : "${local.alarm_name_prefix}-highDiskQueueDepth",
      is_enabled          : var.enable_disk_queue_depth_alarms
      metric_name         : "DiskQueueDepth",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.disk_queue_depth_too_high_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average database disk queue depth too high, performance may suffer"
    },
    {
      codename            : "freeable_memory_too_low",
      name                : "${local.alarm_name_prefix}-lowFreeableMemory",
      is_enabled          : var.enable_freeable_memory_alarms
      metric_name         : "FreeableMemory",
      comparison_operator : "LessThanThreshold",
      threshold           : var.freeable_memory_too_low_threshold * 1000 * 1000, # Mb => Bytes
      evaluation_periods  : var.evaluation_periods
      description         : "Average database freeable memory too low, performance may suffer"
    },
    {
      codename            : "disk_free_storage_space_threshold",
      name                : "${local.alarm_name_prefix}-lowFreeStorageSpace",
      is_enabled          : var.enable_disk_free_storage_space_alarms
      metric_name         : var.is_aurora ? "FreeLocalStorage" : "FreeStorageSpace",
      comparison_operator : "LessThanThreshold",
      threshold           : var.disk_free_storage_space_threshold * 1000 * 1000, # Mb => Bytes
      evaluation_periods  : var.evaluation_periods
      description         : "Average database free storage space too low"
    },
    {
      codename            : "memory_swap_usage_too_high",
      name                : "${local.alarm_name_prefix}-highSwapUsage",
      is_enabled          : var.enable_memory_swap_usage_alarms
      metric_name         : "SwapUsage",
      comparison_operator : "GreaterThanThreshold",
      threshold           : var.memory_swap_usage_too_high_threshold * 1000 * 1000, # Mb => Bytes
      evaluation_periods  : var.evaluation_periods
      description         : "Average database swap usage too high, performance may suffer"
    },
    {
      codename            : "db_connections_limit",
      name                : "${local.alarm_name_prefix}-limitDBConnections",
      is_enabled          : var.enable_db_connections_alarms
      metric_name         : "DatabaseConnections",
      comparison_operator : "GreaterThanThreshold",
      threshold           : local.db_connections_limit_threshold,
      evaluation_periods  : var.evaluation_periods
      description         : "Average database connections amount almost reached ${var.db_connections_limit_threshold} percent of the limit, may cause connection disruption"
    }
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
  namespace           = "AWS/RDS"
  period              = var.statistics_period
  statistic           = "Average"
  threshold           = lookup(each.value, "threshold", null)
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = var.db_cluster_name == "" ? {
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/dimensions.html
    DBInstanceIdentifier = var.db_instance_name
  } : {
    # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/dimensions.html
    DBClusterIdentifier = var.db_cluster_name
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_event_subscription
resource "aws_db_event_subscription" "this" {
  for_each = toset(var.sns_topic_arns)

  name_prefix = "${var.db_cluster_name == "" ? var.db_instance_name : var.db_cluster_name}-"
  sns_topic   = each.value

  source_type = var.db_cluster_name == "" ? "db-instance" : "db-cluster"
  source_ids  = [var.db_cluster_name == "" ? var.db_instance_name : var.db_cluster_name]

  event_categories = [
    "failover",
    "failure",
    "low storage",
    "maintenance",
    #    "notification",
    "recovery",
  ]
}


