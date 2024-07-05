variable "bucket_prefix" {
  type        = string
  nullable    = false
  description = "Bucket Prefix. The full bucket name will be generated by AWS module"
}

variable "is_public" {
  type        = bool
  default     = false
  description = "Defines whether the bucket is public."
}

variable "enable_versioning" {
  type        = bool
  default     = false
  description = "Enable bucket versioning"
}

variable "create_iam_policies" {
  type        = bool
  default     = false
  description = "Create custom IAM Policies: `Read_Only`, `WriteRead_Only`, and `FullAccess`"
}

variable "keep_last_versions_number" {
  type        = number
  default     = 0
  description = "Number of last non-current versions to retain forever"
}

variable "current_version_expiration_days" {
  type        = number
  default     = 0
  description = "Number of days a current version expires. NOTE: `0` disables the expiration"
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 30
  description = "Number of days a non-current version expires"
}

variable "version_transitions" {
  type        = list(object({
    keep_last_versions_number = optional(number)
    after_days                = number
    storage_class             = string
  }))
  default     = []
  description = <<-EOT
    Version Transitions settings. Available `storage_class`:
      - `GLACIER`
      - `STANDARD_IA`
      - `ONEZONE_IA`
      - `INTELLIGENT_TIERING`
      - `DEEP_ARCHIVE`
      - `GLACIER_IR`
  EOT

  validation {
    condition = alltrue([
      for t in var.version_transitions : contains([
        "GLACIER",
        "STANDARD_IA",
        "ONEZONE_IA",
        "INTELLIGENT_TIERING",
        "DEEP_ARCHIVE",
        "GLACIER_IR"
      ], t.storage_class)
    ])
    error_message = <<-EOF
      Only the following values of "storage_class" are available:
        - "GLACIER",
        - "STANDARD_IA",
        - "ONEZONE_IA",
        - "INTELLIGENT_TIERING",
        - "DEEP_ARCHIVE",
        - "GLACIER_IR"
    EOF
  }
}

variable "expired_object_delete_marker" {
  type        = bool
  default     = true
  description = <<-EOF
    Indicates whether Amazon S3 will remove a delete marker with no noncurrent versions.
    Conflicts with `current_version_expiration_days`
  EOF
}

variable "abort_incomplete_multipart_upload_after_days" {
  type        = number
  default     = 1
  description = <<-EOF
    Days since the initiation of an incomplete multipart upload that Amazon S3 will wait before
    permanently removing all parts of the upload
  EOF
}

variable "enable_replication" {
  type        = bool
  default     = false
  description = "Enable bucket replication"
}

variable "replica_bucket_arn" {
  type        = string
  default     = ""
  description = "S3 Bucket ARN that objects will be replicating to"
}

variable "delete_marker_replication" {
  type        = bool
  default     = false
  description = "Enable Delete Marker replication"
}

variable "aws_cli_profile" {
  type        = string
  default     = ""
  description = "AWS CLI Profile used for this module. Used to execute AWS CLI `local-exec` commands absent in Terraform"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Allow S3 bucket destruction regardless existed objects"
}
