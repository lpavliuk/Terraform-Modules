variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Name of the ECS Service.

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

variable "cluster_id" {
  type        = string
  nullable    = false
  description = "ECS Cluster ID for the ECS Service Tasks"
}

variable "capacity_provider_name" {
  type        = string
  nullable    = false
  description = "ECS Capacity Provider Name of the ECS Service"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Number of ECS Service Copies to place and keep running"
}

variable "ordered_placement_strategy" {
  type        = object({
    type  = string
    field = optional(string)
  })
  default     = {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  description = <<-EOF
    [Amazon ECS - Placement Strategy](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PlacementStrategy.html)
  EOF
}

variable "network_configuration" {
  type        = object({
    security_groups = list(string)
    subnet_ids      = list(string)
  })
  default     = null
  description = <<-EOF
    Network Configuration.

    **NOTE!** The attribute is required and applied only in case `container_network_mode` = `awsvpc`.
  EOF
}

variable "task_network_mode" {
  type        = string
  default     = "bridge"
  description = <<-EOF
    Task networking mode to use for its containers.

    Available network modes:
      - `none`
      - `bridge`
      - `awsvpc`
      - `host`

    [Amazon ECS - Network Mode](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#network_mode)
  EOF

  validation {
    condition = contains([
      "none",
      "bridge",
      "awsvpc",
      "host"
    ], var.task_network_mode)
    error_message = <<-EOF
      Only the following values of 'container_network_mode' are available:
        - none
        - bridge
        - awsvpc
        - host
    EOF
  }
}

variable "task_cpu" {
  type        = number
  default     = 256
  description = "CPU Units used by the ECS Service Task"
}

variable "task_memory" {
  type        = number
  default     = 256
  description = "Memory in MiB used by the ECS Service Task"
}

variable "task_log_group_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch Log Group Retention Period Days of the ECS Service Task"
}

variable "task_tags" {
  type        = object({
    name  = string
    value = string
  })
  default     = null
  description = "ECS Service Task Tags"
}

variable "containers" {
  type        = list(object({
    name                         = string
    port                         = number
    port_range                   = optional(string)
    host_port                    = optional(number)
    host_port_range              = optional(string)
    links                        = optional(list(string), [])
    image                        = string
    private_registry_credentials = optional(object({
      username = string
      password = string
    }))
    essential                    = optional(bool, true)
    target_group_arn             = optional(string)
    cpu                          = optional(number)
    gpu                          = optional(number)
    memory                       = optional(number)
    memory_reservation           = optional(number)
    health_check                 = optional(object({
      endpoint     = string
      interval     = optional(number, 30),
      retries      = optional(number, 3),
      timeout      = optional(number, 5),
      start_period = optional(number)
    }))
    env                          = optional(list(object({
      name  = string,
      value = string
    })), [])
    env_files                    = optional(list(object({
      s3_object_arn = string
    })), [])
    secret_vars                  = optional(list(object({
      name       = string,
      secret_arn = string
    })), [])
    hostname                     = optional(string)
    etc_hosts                    = optional(list(object({
      hostname   = string
      ip_address = string
    })), [])
    disable_networking           = optional(bool, false)
  }))
  nullable    = false
  description = <<-EOF
    [Amazon ECS - Container Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions)

    `image` attribute must be defined as **Image_URL:TAG**. For example: `"registry.gitlab.com/group/webserver:latest"`.

    **NOTE!** if `host_port` attribute is not defined, the port will be assigned automatically!

    `endpoint` of `health_check` attribute must start with `/`. For example: `"/api/health"`.
  EOF
}
