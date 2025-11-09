variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    RDS Instance Name.

    **NOTE!**  Must contain 1 to 63 alphanumeric characters or hyphens (`-`).
    [Naming constraints in Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.Constraints)
  EOF

  validation {
    error_message = <<-EOF
      Must contain 1 to 63 alphanumeric characters or hyphens (-).
      https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.Constraints
    EOF
    condition     = can(regex(
      "[0-9a-zA-Z$_]+",
      var.name
    ))
  }
}

variable "instance_class" {
  type        = string
  default     = "db.serverless"
  description = <<-EOF
      RDS Instance Class (e.g. `db.serverless` for serverless, `db.t3.micro` for provisioned)

      For more information, see [DB instance classes](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html)
  EOF
}

variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = <<-EOF
    Database Engine. Available engines:
      - `aurora-mysql`
      - `aurora-postgresql`
  EOF

  validation {
    error_message = "This module supports only the following engines: 'aurora-mysql', 'aurora-postgresql'."
    condition     = contains([
      "aurora-mysql",
      "aurora-postgresql"
    ], var.engine)
  }
}

variable "engine_version" {
  type        = string
  default     = "8.0.mysql_aurora.3.10.0"
  description = "Engine Version"
}

variable "engine_mode" {
  type        = string
  default     = "provisioned"
  description = <<-EOF
    The database engine mode of the DB cluster. Valid values: `provisioned`, `serverless`, `parallelquery`

    For more information, see [CreateDBCluster - EngineMode](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBCluster.html#RDS-CreateDBCluster-request-EngineMode)
  EOF

  validation {
    error_message = "This module supports only the following engine modes: 'provisioned', 'serverless' and 'parallelquery'."
    condition     = contains([
      "provisioned",
      "serverless",
      "parallelquery"
    ], var.engine_mode)
  }
}

variable "min_acu" {
  type        = number
  default     = 0.5
  description = "Minimum ACU"
}

variable "max_acu" {
  type        = number
  default     = 2
  description = "Maximum ACU"
}

variable "storage_type" {
  type        = string
  default     = ""
  description = "Storage Type (e.g. `aurora-iopt1`)"
}

variable "master_username" {
  type        = string
  nullable    = false
  description = "Master Username"
}

variable "master_password" {
  type        = string
  default     = null
  description = <<-EOF
    Master Password.

    **NOTE!** Required if `manage_master_user_pswd` is `false`
  EOF
}

variable "manage_master_user_pswd" {
  type        = bool
  nullable    = false
  description = "Enable automatic RDS management of the master user password in AWS Secret Manager"
}

variable "enabled_iam_authentication" {
  type        = bool
  default     = false
  description = "Enable IAM DB Authentication"
}

variable "multi_az" {
  type        = bool
  nullable    = false
  description = "Enable Multi-AZ for the RDS Instance"
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID the RDS Instance will be provisioned in"
}

variable "rds_subnet_group_id" {
  type        = string
  nullable    = false
  description = "RDS Subnet Group ID the RDS Instance will be provisioned in"
}

variable "ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
  description = "CA Certificate of the database"
}

variable "is_private" {
  type        = bool
  nullable    = false
  description = "Enable private mode of the RDS Instance (accessible only from VPC)"
}

variable "backup_retention_period_days" {
  type        = number
  default     = 7
  description = "Automatic Backup retention period in days. NOTE: `0` days disables the automatic backups."
}

variable "backup_window_utc_period" {
  type        = string
  default     = "14:00-16:00"
  description = <<-EOF
    The daily time range of the automatic backups (in UTC). Default: `14:00-16:00` (01:00-03:00 AEDT)
    Must not overlap `maintenance_window_utc_period` parameter
  EOF
}

variable "enable_enhanced_monitoring" {
  type        = bool
  default     = false
  description = "Enable Enhanced Monitoring"
}

variable "maintenance_window_utc_period" {
  type        = string
  default     = "Sat:16:00-Sat:18:00"
  description = <<-EOF
    The daily time range of the maintenance (in UTC). Default: `Sat:16:00-Sat:18:00` (Sun:03:00-Sun:05:00 AEDT)
    Must not overlap `backup_window_utc_period` parameter
  EOF
}

variable "replication_source_identifier" {
    type        = string
    default     = null
    description = <<-EOF
        The Amazon Resource Name (ARN) of the source DB instance or DB cluster if this DB cluster is created as a read replica.
        For more information, see [Creating a Read Replica for an Amazon Aurora DB Cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Replication.html#Aurora.Replication.CreatingReadReplica).
    EOF
}

variable cloudwatch_logs_exports {
  type        = list(string)
  default     = []
  description = <<-EOF
    Enable publishing MySQL logs to Amazon CloudWatch Logs.

    Available: `error`, `general`, `slowquery`, `audit`, `instance`, `iam-db-auth-error` and `postgresql`.
  EOF
  validation {
    error_message = "Only 'error', 'general', 'slowquery', 'audit', 'instance', 'iam-db-auth-error' and 'postgresql' can be defined"
    condition     = alltrue([
      for log in var.cloudwatch_logs_exports : contains([
        "error",
        "general",
        "slowquery",
        "audit",
        "iam-db-auth-error",
        "instance",
        "postgresql"
      ], log)
    ])
  }
}

variable "cloudwatch_logs_retention_period_days" {
  type        = number
  default     = 7
  description = "CloudWatch Logs retention period in days. Available: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365."

  validation {
    error_message = "Invalid retention value! Available: [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365]"
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365], var.cloudwatch_logs_retention_period_days)
  }
}

variable "db_parameters" {
  type        = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = <<-EOF
    Parameters are added to the DB Parameter Group.

    - [MySQL server system parameters](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html)
    - [Aurora MySQL configuration parameters](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Reference.ParameterGroups.html)
  EOF
}
