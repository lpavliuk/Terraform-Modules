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

variable "engine" {
  type        = string
  default     = "mysql"
  description = <<-EOF
    Database Engine. Available engines:
      - `mysql`
      - `aurora-mysql`
  EOF

  validation {
    error_message = "This module supports only the following engines: 'mysql', 'aurora-mysql'."
    condition     = contains([
      "mysql",
      "aurora-mysql"
    ], var.engine)
  }
}

variable "engine_version" {
  type        = string
  default     = "8.0.28"
  description = "Engine Version"

  validation {
    error_message = "Must be 3 digits which represent Major.Minor.Patch version"
    condition     = can(regex(
      "^([1-9]\\d*|0)(\\.(([1-9]\\d*)|0)){2}$",
      var.engine_version
    ))
  }
}

variable "instance_type" {
  type        = string
  nullable    = false
  description = "RDS Instance Type (e.g. `db.t3.micro`)"
}

variable "storage_type" {
  type        = string
  nullable    = false
  description = "Storage Type (e.g. `gp3`)"
}

variable "storage_size" {
  type        = number
  default     = 20
  description = "Storage size in GB"
}

variable "max_storage_size" {
  type        = number
  default     = 40
  description = "Max allocated storage size in GB"
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
  default     = "rds-ca-rsa4096-g1"
  description = "CA Certificate of the database"
}

variable "is_private" {
  type        = bool
  nullable    = false
  description = "Enable private mode of the RDS Instance (accessible only from VPC)"
}

variable "multi_az" {
  type        = bool
  nullable    = false
  description = "Enable Multi-AZ for the RDS Instance"
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

variable "enable_auto_minor_version_upgrade" {
  type        = bool
  default     = false
  description = "Enable Auto Minor Version Upgrade"
}

variable "maintenance_window_utc_period" {
  type        = string
  default     = "Sat:16:00-Sat:18:00"
  description = <<-EOF
    The daily time range of the maintenance (in UTC). Default: `Sat:16:00-Sat:18:00` (Sun:03:00-Sun:05:00 AEDT)
    Must not overlap `backup_window_utc_period` parameter
  EOF
}

variable cloudwatch_logs_exports {
  type        = list(string)
  default     = []
  description = "Enable publishing MySQL logs to Amazon CloudWatch Logs. Available: `error`, `general` and `slowquery`"

  validation {
    error_message = "Only 'error', 'general' and 'slowquery' can be defined"
    condition     = alltrue([
    for log in var.cloudwatch_logs_exports : contains(["error", "general", "slowquery"], log)
    ])
  }
}

variable "cloudwatch_logs_retention_period_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention period in days. Available: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365."

  validation {
    error_message = "Invalid retention value! Available: [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365]"
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365], var.cloudwatch_logs_retention_period_days)
  }
}

variable "aws_cli_profile" {
  type        = string
  default     = null
  description = "AWS CLI Profile used for this module. Used to execute AWS CLI `local-exec` commands absent in Terraform"
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
