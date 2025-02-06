variable "name" {
  type        = string
  nullable    = false
  description = "VPC Name"
}

variable "cidr" {
  type        = string
  nullable    = false
  description = "IPv4 CIDR Block for the VPC (e.g. `10.0.0.0/16`). Must have `/16` mask"

  validation {
    error_message = "Must be 4 digits with /16 IPv4 CIDR Block"
    condition     = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/16$",
      var.cidr
    ))
  }
}

variable "domain_zone_name" {
  type        = string
  default     = null
  description = "Private Hosted Zone Name that will be created in Route53"
}

variable "enable_flow_logs" {
  type        = bool
  default     = false
  description = "Enable Flow Logs to CloudWatch"
}

variable "flow_logs_retention_in_days" {
  type        = number
  default     = 7
  description = "Retention in days for Flow Logs in CloudWatch"
}
