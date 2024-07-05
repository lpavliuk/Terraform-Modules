variable "name" {
  type        = string
  nullable    = false
  description = "Codename for this backup plan"
}

variable "rules" {
  type        = list(object({
    name                     = string
    schedule_cron            = string
    start_window_mins        = optional(string)
    completion_window_mins   = optional(string)
    enable_continuous_backup = optional(string)
    recovery_point_tags      = optional(map(string))
    lifecycle                = optional(object({
      cold_storage_after_days = optional(number)
      delete_after_days       = optional(number)
    }))
    copy_action              = optional(object({
      destination_vault_arn = string
      lifecycle             = optional(object({
        cold_storage_after_days = optional(number)
        delete_after_days       = optional(number)
      }))
    }))
  }))
  nullable    = false
  description = <<-EOF
    List of backup plan rules.
    `start_window_min`: >= 60 mins

    [schedule_cron expressions reference](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cron-expressions.html)
  EOF
}

variable "backup_resources" {
  type        = list(string)
  default     = []
  description = "List of resources ARNs that get backup by this plan"
}

variable "backup_not_resources" {
  type        = list(string)
  default     = []
  description = "List of resources ARNs this plan will ignore"
}

variable "backup_selection_tags" {
  type        = list(object({
    type  = string
    key   = string
    value = string
  }))
  default     = []
  description = <<-EOF
    List of tags resource of which will get backup by this plan. Available `type`:
      - `STRINGEQUALS`
      - `STRINGLIKE`
      - `STRINGNOTEQUALS`
      - `STRINGNOTLIKE`
  EOF

  validation {
    condition = alltrue([
      for tag in var.backup_selection_tags : contains([

        "STRINGEQUALS",
        "STRINGLIKE",
        "STRINGNOTEQUALS",
        "STRINGNOTLIKE"
      ], tag.type)
    ])
    error_message = <<-EOF
      Only the following values are available:
        - "STRINGEQUALS"
        - "STRINGLIKE"
        - "STRINGNOTEQUALS"
        - "STRINGNOTLIKE"
    EOF
  }
}

variable "notifications_events" {
  type        = list(string)
  default     = []
  description = <<-EOF
    List of the notification events. Available:
      - `BACKUP_JOB_STARTED`
      - `BACKUP_JOB_COMPLETED`
      - `BACKUP_JOB_FAILED`
      - `COPY_JOB_STARTED`
      - `COPY_JOB_SUCCESSFUL`
      - `COPY_JOB_FAILED`
      - `RESTORE_JOB_STARTED`
      - `RESTORE_JOB_COMPLETED`
      - `RECOVERY_POINT_MODIFIED`
      - `S3_BACKUP_OBJECT_FAILED`
      - `S3_RESTORE_OBJECT_FAILED`

    [Backup Vault Notifications](https://docs.aws.amazon.com/aws-backup/latest/devguide/backup-notifications.html#backup-notifications-section)
  EOF

  validation {
    condition = alltrue([
      for event in var.notifications_events : contains([
        # Custom events:
        "BACKUP_JOB_FAILED",
        # Backup Vault Notifications:
        "BACKUP_JOB_STARTED",
        "BACKUP_JOB_COMPLETED",
        "COPY_JOB_STARTED",
        "COPY_JOB_SUCCESSFUL",
        "COPY_JOB_FAILED",
        "RESTORE_JOB_STARTED",
        "RESTORE_JOB_COMPLETED",
        "RECOVERY_POINT_MODIFIED",
        "S3_BACKUP_OBJECT_FAILED",
        "S3_RESTORE_OBJECT_FAILED",
      ], event)
    ])
    error_message = <<-EOF
      Only the following values are available:
        - "BACKUP_JOB_STARTED"
        - "BACKUP_JOB_COMPLETED"
        - "BACKUP_JOB_FAILED"
        - "COPY_JOB_STARTED"
        - "COPY_JOB_SUCCESSFUL"
        - "COPY_JOB_FAILED"
        - "RESTORE_JOB_STARTED"
        - "RESTORE_JOB_COMPLETED"
        - "RECOVERY_POINT_MODIFIED"
        - "S3_BACKUP_OBJECT_FAILED"
        - "S3_RESTORE_OBJECT_FAILED"
    EOF
  }
}

variable "notifications_sns_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN for all notifications are defined in `notifications_events`"
}
