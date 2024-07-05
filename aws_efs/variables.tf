variable "name" {
  type        = string
  nullable    = false
  description = "EFS Name"
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID where the EFS will be created in"
}

variable "subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "Subnet IDs the EFS will be attached to"
}

variable "is_encrypted" {
  type        = bool
  default     = true
  description = "Enables disk encryption"
}

variable "enable_backup" {
  type        = bool
  default     = false
  description = "Enables AWS EFS backup policy"
}

variable "replica_region" {
  type        = string
  default     = ""
  description = "Enables a replication to an additional region"
}
