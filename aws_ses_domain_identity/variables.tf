variable "domain_name" {
  type        = string
  nullable    = false
  description = "Domain Name"
}

variable "bounce_notification_topic_arn" {
  type        = string
  default     = ""
  description = "SNS Topic ARN for bounced emails"
}

variable "complaint_notification_topic_arn" {
  type        = string
  default     = ""
  description = "SNS Topic ARN for email complaints"
}

variable "delivery_notification_topic_arn" {
  type        = string
  default     = ""
  description = "SNS Topic ARN for emails delivery status"
}
