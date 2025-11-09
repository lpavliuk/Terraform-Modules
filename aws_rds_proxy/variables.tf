variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    RDS Proxy Name.

    **NOTE!**  Must contain 1 to 63 alphanumeric characters or hyphens (`-`).
  EOF

  validation {
    error_message = <<-EOF
      Must contain 1 to 63 alphanumeric characters or hyphens (-).
    EOF
    condition     = can(regex(
      "[0-9a-zA-Z-]+",
      var.name
    ))
  }
}

variable "engine" {
  type        = string
  default     = "MYSQL"
  description = <<-EOF
    Proxy Engine. Available engines:
      - `MYSQL`
  EOF

  validation {
    error_message = "This module supports only the following engines: 'MYSQL'."
    condition     = var.engine != null ? contains([
      "MYSQL",
      # "POSTGRESQL",
      # "SQLSERVER"
    ], var.engine) : true
  }
}

variable "vpc_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "Subnet IDs the RDS Proxy will be provisioned in"
}

variable "security_group_ids" {
  type        = list(string)
  nullable    = false
  description = "Security Group IDs to attach to the RDS Proxy"
}

variable "target_rds_instance_name" {
  type        = string
  default     = null
  description = "Target RDS Instance Name"
}

variable "target_rds_cluster_name" {
  type        = string
  default     = null
  description = "Target RDS Cluster Name"
}

variable "create_read_only_endpoint" {
  type        = bool
  default     = false
  description = "Whether to create a read-only endpoint for the proxy. Only applicable for RDS clusters."
}

variable "users" {
  type        = list(object({
    username   = string
    password   = string
    iam_auth   = bool
    # kms_key_id = optional(string)
  }))
  nullable    = false
  description = "Proxy Users"

  validation {
    error_message = <<-EOF
      Username can contain only 1 to 63 alphanumeric characters or underscore (`_`).
    EOF
    condition     = alltrue([
      for u in var.users : can(regex(
        "[0-9a-zA-Z_]+",
        u.username
      ))
    ])
  }
}
