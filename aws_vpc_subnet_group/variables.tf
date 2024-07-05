variable "name" {
  type        = string
  nullable    = false
  description = "Subnet Group Name"
}

variable "cidr" {
  type        = string
  nullable    = false
  description = "Subnet Group IPv4 CIDR Block (e.g. `10.0.0.0/18`). Must have `/18` mask"

  validation {
    error_message = "Must be 4 digits with /18 IPv4 CIDR Block (10.0.0.0/18)"
    condition     = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/18$",
      var.cidr
    ))
  }
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID"

  validation {
    error_message = "Must start with vpc-xxx"
    condition     = can(regex(
      "^vpc-[0-9a-zA-Z]",
      var.vpc_id
    ))
  }
}

variable "vpc_name" {
  type        = string
  nullable    = false
  description = "VPC Name"
}

variable "auto_assign_public_ip" {
  type        = bool
  default     = false
  description = "Enable Public IP Auto-assigning"
}

variable "max_az_number" { # TODO: Consider using availability_zones instead
  type        = number
  default     = 2
  description = "Maximum number of Availability Zones Subnets will be created in the group"

  validation {
    error_message = "Cannot be less than 1"
    condition     = var.max_az_number > 0
  }
}

