variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Name of the ECS Cluster

    **NOTE!** Must contain alphanumeric characters or hyphens (`-`).
  EOF

  validation {
    condition     = can(regex(
      "[0-9a-zA-Z$_]+",
      var.name
    ))
    error_message = <<-EOF
      Must contain alphanumeric characters or hyphens (-).
    EOF
  }
}

variable "subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "Subnet IDs"
}

variable "node_image_id" {
  type        = string
  nullable    = false
  description = <<-EOF
    Node Image (AMI) ID.

    **NOTE!** Changing this will trigger instance refresh!
  EOF
}

variable "node_instance_type" {
  type        = string
  default     = "t4g.micro"
  description = "Node Instance Type"
}

variable "node_min_count" {
  type        = number
  default     = 2
  description = "Minimum number of Nodes in Auto Scaling Group"

  validation {
    error_message = "Must be more than 0"
    condition     = var.node_min_count > 0
  }
}

variable "node_max_count" {
  type        = number
  default     = null
  description = "Maximum number of Nodes in Auto Scaling Group. Default is the `min_nodes_count`"
}

variable "node_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security Groups IDs attached to the Node"
}

variable "node_extra_tags" {
  type        = list(object({
    key                 = string,
    value               = string,
    propagate_at_launch = bool
  }))
  default     = []
  description = "Node Extra Tags"
}

variable "enable_session_manager" {
  type        = bool
  default     = false
  description = "Enable Session Manager for the ECS Nodes"
}
