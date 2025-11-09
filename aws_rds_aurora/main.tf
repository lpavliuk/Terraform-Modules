# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "this" {
  apply_immediately = true

  cluster_identifier                  = "${var.name}-aurora-cluster"
  engine                              = var.engine
  engine_version                      = var.engine_version
  engine_mode                         = var.engine_mode
  master_username                     = var.master_username
  master_password                     = var.manage_master_user_pswd ? null : var.master_password
  manage_master_user_password         = var.manage_master_user_pswd ? true : null
  #master_user_secret_kms_key_id      = "" # the default KMS key for your AWS account is used
  iam_database_authentication_enabled = var.enabled_iam_authentication
  availability_zones                  = var.multi_az ? data.aws_availability_zones.available.names : null

  replication_source_identifier       = var.replication_source_identifier

  storage_type                        = var.storage_type
  storage_encrypted                   = true

  vpc_security_group_ids              = [aws_security_group.this.id]
  db_subnet_group_name                = var.rds_subnet_group_id
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.this.name
  preferred_maintenance_window        = var.maintenance_window_utc_period
  backup_retention_period             = var.backup_retention_period_days
  preferred_backup_window             = var.backup_window_utc_period
  skip_final_snapshot                 = true

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.MySQLDB.PublishtoCloudWatchLogs.html
  enabled_cloudwatch_logs_exports     = length(var.cloudwatch_logs_exports) > 0 ? var.cloudwatch_logs_exports : null

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.instance_class == "db:serverless" ? [1] : []
    content {
      min_capacity             = var.min_acu
      max_capacity             = var.max_acu
    }
  }

  lifecycle {
    precondition {
      error_message = "If manage_master_user_pswd is false, master_password is required!"
      condition     = var.manage_master_user_pswd || (!var.manage_master_user_pswd && var.master_password != null)
    }
    ignore_changes = [engine_version]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "this" {
  count               = var.multi_az ? 2 : 1
  depends_on          = [aws_rds_cluster.this]

  identifier          = "${var.name}-aurora${count.index > 0 ? "-" : ""}${count.index > 0 ? count.index : ""}"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  publicly_accessible = var.is_private ? false : true
  ca_cert_identifier  = var.ca_cert_identifier
  monitoring_interval = var.enable_enhanced_monitoring ? 15 : 0 # in seconds
  monitoring_role_arn = var.enable_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  promotion_tier      = count.index
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = var.name
  family      = "${var.engine}${join(".", slice(split(".", var.engine_version), 0, 2))}" # 8.0.23 => 8.0

  # CloudWatch Logs Parameters:
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.MySQLDB.PublishtoCloudWatchLogs.html
  # Best Practices: https://aws.amazon.com/blogs/database/best-practices-for-configuring-parameters-for-amazon-rds-for-mysql-part-3-parameters-related-to-security-operational-manageability-and-connectivity-timeout/
  parameter {
    name  = "general_log"
    value = contains(var.cloudwatch_logs_exports, "general") ? "1" : "0"
  }
  parameter {
    name  = "slow_query_log"
    value = contains(var.cloudwatch_logs_exports, "slowquery") ? "1" : "0"
  }
  parameter {
    name  = "log_queries_not_using_indexes"
    value = "0" # Log queries that do not use indexes
  }
  parameter { # https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_log_error_verbosity
    name = "log_error_verbosity"
    value = "3" # ERROR, WARNING, INFORMATION - 'Warning' includes failed connections!
  }
  parameter {
    name  = "long_query_time"
    value = "3" # seconds
  }
  parameter {
    name  = "log_slow_extra"
    value = "1" # Log full query information
  }
  parameter {
    name = "log_slow_admin_statements"
    value = "1" # Log slow admin statements
  }
  parameter {
    name  = "net_write_timeout"
    value = "120" # seconds
  }
  # Advanced Auditing: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Auditing.html
  parameter {
    name  = "server_audit_logging"
    value = "1"
  }
  parameter {
    name  = "server_audit_events"
    value = "CONNECT,QUERY"
  }
  parameter {
    name  = "server_audit_excl_users"
    value = "rdsadmin,rdsproxyadmin"
  }

  dynamic "parameter" {
    for_each = var.db_parameters

    content {
      name  = lookup(parameter.value, "name", null)
      value = lookup(parameter.value, "value", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "logs" {
  for_each = toset(var.cloudwatch_logs_exports)

  name              = "/aws/rds/cluster/${var.name}-aurora-cluster/${each.key}"
  retention_in_days = var.cloudwatch_logs_retention_period_days
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG RDS - ${var.name}"
  vpc_id      = var.vpc_id
}

# ================================================
# Enhanced Monitoring IAM Role:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  name_prefix        = "rds-enhanced-monitoring-"
  description        = "RDS - ${var.name}"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  count = var.enable_enhanced_monitoring ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}
