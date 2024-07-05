variable "name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for CloudWatch alarms names"
}

variable "ec2_instance_id" {
  type        = string
  nullable    = false
  description = "Instance ID alarms will be created for"
}

variable "ec2_instance_codename" {
  type        = string
  nullable    = false
  description = "Instance Codename for CloudWatch alarms names"
}

variable "sns_topic_arns" {
  type        = list(string)
  nullable    = false
  description = "SNS Topic ARNs attached to CloudWatch alarms"
}

variable "evaluation_periods" {
  type        = number
  default     = 5 # times
  description = "Evaluation period over which to use when triggering alarms"
}

variable "statistics_period" {
  type        = number
  default     = 60 # secs (1 min)
  description = "Number of seconds that make each statistic period"
}

variable "enable_cpu_utilization_alarms" {
  type        = bool
  default     = true
  description = "Create CPU Utilization alarms"
}

variable "cpu_utilization_too_high_threshold" {
  type        = number
  default     = 80 # percent
  description = "Percentage threshold of CPU utilization alarm"
}
