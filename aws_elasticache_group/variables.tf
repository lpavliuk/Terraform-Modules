variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Cache Name.

    **NOTE!**  Must contain 1 to 63 alphanumeric characters or hyphens (`-`).
  EOF

  validation {
    error_message = <<-EOF
      Must contain 1 to 63 alphanumeric characters or hyphens (-).
    EOF
    condition     = can(regex(
      "[0-9a-zA-Z$_]+",
      var.name
    ))
  }
}

variable "num_cache_cluster" {
  type        = number
  nullable    = false
  description = <<-EOF
    Number of Cache Cluster.

    **NOTE!** Enables **Multi-AZ** and **Automatic Failover** features, if the value is more than 1.
  EOF

  validation {
    error_message = <<-EOF
      Must contain a number higher than 0.
    EOF
    condition     = var.num_cache_cluster > 0
  }
}

variable "node_type" {
  type        = string
  nullable    = false
  description = <<-EOF
    ElastiCache Node Type (e.g. `cache.t4g.micro`)"

    [Cache Nodes Supported Types](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/CacheNodes.SupportedTypes.html)
  EOF
}

variable "port" {
  type        = number
  default     = 6379
  description = "Cache Port"
}

variable "engine" {
  type        = string
  default     = "redis"
  description = <<-EOF
    Cache Engine. Available engines:
      - `redis`
      - `valkey`
  EOF

  validation {
    condition = contains([
      "redis",
      "valkey",
    ], var.engine)
    error_message = <<-EOF
      Only the following values of 'container_network_mode' are available:
        - redis
        - valkey
    EOF
  }
}

variable "engine_version" {
  type        = string
  default     = "7.1"
  description = "Engine Version"
}

variable "parameter_group_name" {
  type        = string
  default     = "default.redis7"
  description = "Parameter Group Name"
}

variable "auth_token" {
  type        = string
  default     = ""
  description = <<-EOF
    Auth Token for the ElastiCache Instance.

    **NOTE!** Required for Redis Cluster with `transit_encryption_enabled` set to `true`.
  EOF

  validation {
    condition     = var.auth_token == "" || can(regex("^[a-zA-Z0-9]{16,40}$", var.auth_token))
    error_message = "Auth token must be empty or contain only alphanumeric characters and be between 16 and 40 characters long."
  }
}

variable "auth_token_update_strategy" {
    type        = string
    default     = "ROTATE"
    description = <<-EOF
        Auth Token Update Strategy. Available values:
        - `SET` - Set a new auth token.
        - `ROTATE` - Rotate the auth token.
        - `DELETE` - Delete the auth token.
    EOF

    validation {
        condition = contains(["SET", "ROTATE", "DELETE"], var.auth_token_update_strategy)
        error_message = "Only the following values of 'auth_token_update_strategy' are available: SET, ROTATE, DELETE"
    }
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID the ElastiCache Instance will be provisioned in"
}

variable "elasticache_subnet_group_id" {
  type        = string
  nullable    = false
  description = "ElastiCache Subnet Group ID the ElastiCache Instance will be provisioned in"
}

variable "enable_auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Enable Auto Minor Version Upgrade"
}

variable "enable_at_rest_encryption" {
  type        = bool
  default     = true
  description = "Enable At Rest Encryption"
}

variable "enable_transit_encryption" {
  type        = bool
  default     = true
  description = <<-EOF
    Enable Transit Encryption.

    **NOTE!** Required for User Group attachment!
  EOF
}

variable "maintenance_window_utc_period" {
  type        = string
  default     = "sat:15:00-sat:20:00"
  description = <<-EOF
    The daily time range of the maintenance (in UTC). Default: `Sat:15:00-Sat:20:00` (Sun:02:00-Sun:07:00 AEDT)
    Must not overlap `backup_window_utc_period` parameter
  EOF
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
