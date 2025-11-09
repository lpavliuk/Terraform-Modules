variable "name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for CloudWatch alarms names"
}

variable "db_instance_name" {
  type        = string
  default     = ""
  description = "RDS Instance Name alarms will be created for"
}

variable "db_cluster_name" {
  type        = string
  default     = ""
  description = "RDS Cluster Name alarms will be created for (if any)"
}

variable "db_instance_class" {
  type        = string
  nullable    = false
  description = "RDS Instance Class for CloudWatch alarms names"
}

variable "is_aurora" {
  type        = bool
  default     = false
  description = "Set to true if the alarms are created for an Aurora cluster"
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

variable "enable_cpu_credit_balance_alarms" {
  type        = bool
  default     = true
  description = "Create CPU Credit Balance alarms"
}

variable "enable_read_iops_alarms" {
  type        = bool
  default     = true
  description = "Create Read IOPS alarms"
}

variable "enable_select_throughput_alarms" {
  type        = bool
  default     = true
  description = "Create Select Throughput alarms. (Only for Aurora clusters!)"
}

variable "enable_burst_balance_alarms" {
  type        = bool
  default     = true
  description = "Create Burst Balance alarms"
}

variable "enable_disk_queue_depth_alarms" {
  type        = bool
  default     = true
  description = "Create Disk Queue Depth alarms"
}

variable "enable_disk_free_storage_space_alarms" {
  type        = bool
  default     = true
  description = "Create Disk Free Storage Space alarms"
}

variable "enable_freeable_memory_alarms" {
  type        = bool
  default     = true
  description = "Create Freeable Memory alarms"
}

variable "enable_memory_swap_usage_alarms" {
  type        = bool
  default     = true
  description = "Create Swap Usage alarms"
}

variable "enable_db_connections_alarms" {
  type        = bool
  default     = true
  description = "Create Database Connections alarms"
}

variable "cpu_utilization_too_high_threshold" {
  type        = number
  default     = 80 # percent
  description = "The maximum percentage of CPU utilization"
}

variable "cpu_credit_balance_too_low_threshold" {
  type        = number
  default     = 50 # credit units
  description = "The minimum number of CPU credits (t2 instances only) available"
}

variable "read_iops_too_high_threshold" {
  type        = number
  default     = 100 # units
  description = "The number of IOPS is meant to be suspicious"
}

variable "select_throughput_too_high_threshold" {
  type        = number
  default     = 100 # units
  description = "The number of Select Throughput is meant to be suspicious"
}

variable "burst_balance_too_low_threshold" {
  type        = number
  default     = 90 # credit units
  description = "The minimum percent of General Purpose SSD (gp2) burst-bucket I/O credits available"
}

variable "disk_queue_depth_too_high_threshold" {
  type        = number
  default     = 64 # units
  description = "The maximum number of outstanding IOs (read/write requests) waiting to access the disk"
}

variable "disk_free_storage_space_threshold" {
  type        = number
  default     = 2000 # bytes (2 GB)
  description = "The minimum amount of available storage space in Megabytes"
}

variable "freeable_memory_too_low_threshold" {
  type        = number
  default     = 150 # Megabytes
  description = "The minimum amount of available random access memory in Megabytes"
}

variable "memory_swap_usage_too_high_threshold" {
  type        = number
  default     = 1000 # Megabytes
  description = "The maximum amount of swap space used on the DB instance in Megabytes"
}

variable "db_connections_limit_threshold" {
  type        = number
  default     = 80
  description = "The maximum percent of connections connected to the DB instance"
}
