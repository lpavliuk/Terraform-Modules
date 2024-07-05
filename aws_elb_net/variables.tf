variable "name" {
  type        = string
  nullable    = false
  description = "NLB Name"
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID the NLB will be created in"
}

variable "subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "Subnet IDs the NLB will be attached to"
}

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Enables the NLB traffic logging to S3 bucket"
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Enables the deletion protection of the NLB"
}

variable "enable_cross_zone" {
  type        = bool
  default     = false
  description = "Enables private mode of the NLB (accessible only from VPC)"
}

variable "is_private" {
  type        = bool
  default     = false
  description = "Enables private mode of the NLB (accessible only from VPC)"
}

variable "extra_sg_ids" {
  type        = list(string)
  default     = []
  description = "Additional Security Group IDs attached to the NLB except for default Security Group"
}
