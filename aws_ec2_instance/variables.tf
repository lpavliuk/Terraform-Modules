variable "name" {
  type        = string
  nullable    = false
  description = "Name of the Instance"
}

variable "ami" {
  type        = string
  nullable    = false
  description = "AMI ID the Instance will be created from"
}

variable "type" {
  type        = string
  default     = "t2.small"
  description = <<-EOT
    Type of the Instance. [Available Instance Types](https://aws.amazon.com/ec2/instance-types/)
  EOT
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "VPC ID where the Instance will be launched in"
}

variable "subnet_id" {
  type        = string
  nullable    = false
  description = "Subnet ID where the Instance will be launched in"
}

variable "security_group_id" {
  type        = string
  nullable    = false
  description = "Default Security Group ID of the Instance"
}

variable "extra_sg_ids" {
  type        = list(string)
  default     = []
  description = "Extra Security Groups IDs except for default one"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "The script that will be executed after the instance is created"
}

variable "has_elastic_ip" {
  type        = bool
  default     = false
  description = "Reserve static Public IP Address for the Instance"
}
