variable "name" {
  type        = string
  nullable    = false
  description = "ALB Name"
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID the ALB will be created in"
}

variable "subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "Subnet IDs the ALB will be attached to"
}

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Enable the ALB Access and Connection Logging to S3 bucket"
}

variable "logs_expiration_days" {
  type        = number
  default     = 7
  description = "Retention period of the ALB Access and Connection Logs in S3 bucket"
}

variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable the deletion protection of the ALB"
}

variable "is_private" {
  type        = bool
  default     = false
  description = "Enable private mode of the ALB (accessible only from VPC)"
}

variable "preserve_host_header" {
  type        = bool
  default     = false
  description = "Enable Preserve Host Header mode of the ALB"
}

variable "xff_header_processing_mode" {
  type        = string
  default     = "append"
  description = "XFF Header Processing mode of the ALB"
  // TODO: Add validation!
}

variable "https_certificate_arn" {
  type        = string
  default     = null
  description = <<-EOT
      ACM Certificate ARN for HTTPS (:443) Listener.

      **NOTE!** Creates HTTPS (:443) Listener
  EOT
}

variable "extra_sg_ids" {
  type        = list(string)
  default     = []
  description = "Additional Security Group IDs attached to the ALB except for default Security Group"
}
