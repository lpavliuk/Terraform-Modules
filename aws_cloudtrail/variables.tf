variable "name" {
  type        = string
  nullable    = false
  description = "Codename of the CloudTrail"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Enables logging for the trail. Setting this to false will pause logging"
}

variable "cloudwatch_log_group_retention_days" {
  type        = number
  default     = 7
  description = "Retention period of CloudWatch Log Group in days"
}

variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "S3 Bucket Name to store logs"
}

variable "s3_bucket_key_prefix" {
  type        = string
  default     = ""
  description = "S3 Bucket Key Prefix to store logs"
}

variable "is_organization_trail" {
  type        = bool
  default     = false
  description = <<-EOF
    Defines whether it is an organization trail.
    **NOTE: that organization trails can ONLY be created in organization
    master accounts; this will fail if run in a non-master account**
  EOF
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "Whether the trail is created in the current region or in all regions"
}

variable "include_global_service_events" {
  type        = bool
  default     = true
  description = "Whether the trail is publishing events from global services such as IAM to the log files"
}

variable "sns_topic_arn" {
  type        = string
  default     = ""
  description = "SNS Topic ARN for notifications"
}

variable "kms_key_deletion_window_in_days" {
  type        = number
  default     = 30
  description = "The waiting period. After the waiting period ends, AWS KMS deletes the KMS key"
}
