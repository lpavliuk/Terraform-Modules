variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Name of the WAF ACL.

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

variable "scope" {
  type        = string
  default     = "REGIONAL"
  description = <<-EOF
    WAF ACL Scope.

    Available values:
      - `REGIONAL`: A regional ACL is scoped for all cases (default).
      - `CLOUDFRONT`: A global ACL is scoped for an AWS CloudFront distribution.
  EOF

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Invalid value for scope. Valid values are 'REGIONAL' or 'CLOUDFRONT'."
  }
}

variable "default_action" {
  type        = string
  default     = "Allow"
  description = <<-EOF
    Default action for WAF ACL. Action to perform if none of the rules contained in the WebACL match.

    Available values:
      - `Allow`: Allow the request.
      - `Block`: Block the request.
  EOF

  validation {
      condition     = contains(["Allow", "Block"], var.default_action)
      error_message = "Invalid value for default_action. Valid values are 'Allow' or 'Block'."
  }
}

variable "rules" {
  type        = list(object({
    name     = string
    action   = object({
      block = bool
    })
    statement = object({
      managed_rule_group_statement = object({
        name        = string
        vendor_name = string
      })
      geo_match_statement = object({
        country_codes = list(string)
      })
    })
  }))
  default     = []
  description = "WAF ACL Rules"
}

variable "logs_retention_in_days" {
  type        = number
  default     = 7
  description = "Retention in days for Log Group in CloudWatch"
}
