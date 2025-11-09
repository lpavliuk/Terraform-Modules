# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "this" {
  apply_immediately                   = true

  identifier                          = var.name
  instance_class                      = var.instance_type

  allocated_storage                   = var.storage_size
  max_allocated_storage               = var.max_storage_size
  storage_type                        = var.storage_type
  storage_encrypted                   = true

  engine                              = var.engine
  engine_version                      = var.engine_version

  username                            = var.master_username
  password                            = var.manage_master_user_pswd ? null : var.master_password
  manage_master_user_password         = var.manage_master_user_pswd ? true : null
  #master_user_secret_kms_key_id      = "" # the default KMS key for your AWS account is used
  iam_database_authentication_enabled = var.enabled_iam_authentication

  vpc_security_group_ids              = [aws_security_group.this.id]
  db_subnet_group_name                = var.rds_subnet_group_id
  parameter_group_name                = aws_db_parameter_group.this.name
  option_group_name                   = aws_db_option_group.this.name

  auto_minor_version_upgrade          = var.enable_auto_minor_version_upgrade
  maintenance_window                  = var.maintenance_window_utc_period

  backup_retention_period             = var.backup_retention_period_days
  backup_window                       = var.backup_window_utc_period

  monitoring_interval                 = var.enable_enhanced_monitoring ? 15 : 0 # in seconds
  monitoring_role_arn                 = var.enable_enhanced_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  publicly_accessible                 = var.is_private ? false : true
  multi_az                            = var.multi_az
  skip_final_snapshot                 = true
  ca_cert_identifier                  = var.ca_cert_identifier

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.MySQLDB.PublishtoCloudWatchLogs.html
  enabled_cloudwatch_logs_exports     = length(var.cloudwatch_logs_exports) > 0 ? var.cloudwatch_logs_exports : null

  lifecycle {
    precondition {
      error_message = "If manage_master_user_pswd is false, master_password is required!"
      condition     = var.manage_master_user_pswd || (!var.manage_master_user_pswd && var.master_password != null)
    }
    ignore_changes = [engine_version]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "read_replica" {
  count                 = var.read_replica_enabled ? 1 : 0
  depends_on            = [aws_db_instance.this]
  apply_immediately     = true
  replicate_source_db   = aws_db_instance.this.arn # Links to the primary instance

  identifier                          = "${var.name}-replica"
  instance_class                      = var.read_replica_instance_type != null ? var.read_replica_instance_type : var.instance_type
  allocated_storage                   = var.storage_size
  max_allocated_storage               = var.max_storage_size
  storage_type                        = var.storage_type
  storage_encrypted                   = true

  iam_database_authentication_enabled = var.enabled_iam_authentication

  engine                              = var.engine
  engine_version                      = var.engine_version
  vpc_security_group_ids              = [aws_security_group.this.id]
  db_subnet_group_name                = var.rds_subnet_group_id
  parameter_group_name                = aws_db_parameter_group.this.name
  option_group_name                   = aws_db_option_group.this.name

  auto_minor_version_upgrade          = var.enable_auto_minor_version_upgrade
  maintenance_window                  = var.maintenance_window_utc_period
  backup_window                       = var.backup_window_utc_period

  publicly_accessible                 = var.is_private ? false : true
  multi_az                            = var.multi_az
  skip_final_snapshot                 = true
  ca_cert_identifier                  = var.ca_cert_identifier
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_db_parameter_group" "this" {
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
  parameter {
    name  = "log_output"
    value = "FILE"
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
    value = "ON" # Log full query information
  }
  parameter {
    name = "log_slow_admin_statements"
    value = "1" # Log slow admin statements
  }
  parameter {
    name  = "net_write_timeout"
    value = "120" # seconds
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

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_option_group
resource "aws_db_option_group" "this" {
  name_prefix              = var.name
  engine_name              = var.engine
  major_engine_version     = join(".", slice(split(".", var.engine_version), 0, 2)) # e.g. 8.0.40 => 8.0
  option_group_description = "Option group for RDS MySQL instance - ${var.name}"

  dynamic "option" {
    for_each = contains(var.cloudwatch_logs_exports, "audit") ? [true] : []
    content {
      # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MySQL.Options.AuditPlugin.html
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings {
        name  = "SERVER_AUDIT_EVENTS"
        value = "CONNECT,QUERY" # Adjust based on the events you want to log
      }

      option_settings {
        name  = "SERVER_AUDIT_FILE_ROTATE_SIZE"
        value = "1000000" # Rotate log file after 1MB
      }

      option_settings {
        name  = "SERVER_AUDIT_FILE_ROTATIONS"
        value = "10" # Keep up to 10 rotated logs
      }

      option_settings {
        name  = "SERVER_AUDIT_EXCL_USERS"
        value = "rdsadmin,rdsproxyadmin" # "user1,user2" - Exclude specific users from audit logging
      }

      option_settings {
          name  = "SERVER_AUDIT_QUERY_LOG_LIMIT"
          value = "4096" # Maximum length of the query to log
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "logs" {
  for_each = toset(var.cloudwatch_logs_exports)

  name              = "/aws/rds/instance/${var.name}/${each.key}"
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
