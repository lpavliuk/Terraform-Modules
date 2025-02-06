variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Name of the ECR Repository Cluster

    **NOTE!** The repository name must start with a letter and
    can only contain lowercase letters, numbers, hyphens, underscores,
    and forward slashes.
  EOF

  validation {
    condition     = can(regex(
      "(?:[a-z0-9]+(?:[._-][a-z0-9]+)*/)*[a-z0-9]+(?:[._-][a-z0-9]+)*",
      var.name
    ))
    error_message = <<-EOF
      The repository name must start with a letter and
      can only contain lowercase letters, numbers, hyphens, underscores,
      and forward slashes.
    EOF
  }
}

variable "enable_image_tag_immutability" {
  type        = bool
  default     = false
  description = "Enable image tag immutability"
}

variable "enable_scanning_on_push" {
  type        = bool
  default     = false
  description = "Enable scanning on push"
}

variable "repository_policy_json" {
  type        = string
  default     = null
  description = <<-EOF
    ECR Repository Policy

    [More details here.](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy)
  EOF
}

variable "lifecycle_policy_rules" {
  type        = list(object({
    description          = optional(string)
    tag_status           = string
    tag_prefix_list      = optional(list(string))
    count_type           = string
    count_unit           = optional(string)
    count_number         = number
  }))
  default     = null
  description = <<-EOF
    Lifecycle Policy Rules.

    [Lifecycle policy properties in Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_parameters.html)
    [Examples of lifecycle policies in Amazon ECR.](https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html)
    [More details here.](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters)
  EOF
}
