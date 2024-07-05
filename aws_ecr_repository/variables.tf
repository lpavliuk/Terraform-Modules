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

variable "lifecycle_policy_json" {
  type        = string
  default     = null
  description = <<-EOF
    ECR Repository Lifecycle Policy

    [More details here.](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy)
  EOF
}
