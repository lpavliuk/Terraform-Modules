variable "sms_limit_usd" {
  type        = number
  nullable    = false
  description = "SMS Limit amount in USD"
}

variable "default_sender_id" {
  type        = string
  default     = ""
  description = "Default Sender ID"
}

variable "default_sms_type" {
  type        = string
  default     = ""
  description = "Default SMS message type. Available: `Promotional`, `Transactional`"

  validation {
    error_message = "Invalid SMS type! Available: Promotional, Transactional"
    condition = contains([
      "Promotional",
      "Transactional"
    ], var.default_sms_type)
  }
}

variable "notification_topic_arn" {
  type        = string
  default     = ""
  description = "SNS Topic ARN for CloudWatch alarm actions"
}

variable "sms_limit_alarm_threshold_percent" {
  type        = number
  default     = 90
  description = "Threshold in percent of the SMS Limit alarm"
}
