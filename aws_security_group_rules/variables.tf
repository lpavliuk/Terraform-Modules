variable "security_group_id" {
  type        = string
  nullable    = false
  description = "Security Group ID"
}

variable "inbound_rules" {
  type        = list(object({
    description = optional(string, "")
    protocol    = optional(string, "tcp")
    port_range  = string
    source_type = string
    source      = string
  }))
  default     = []
  description = <<-EOF
    Inbound Rules.

    Use `port_range` = `"all"` to define **all traffic** rule.
    `port_range` definition examples:
      - `80`
      - `"80"`
      - `"80-443"`
      - `"all"`

    Available `source_type` values:
        - `cidr_ipv4`
        - `cidr_ipv6`
        - `security_group_id`
        - `prefix_list_id`
  EOF

  validation {
    condition = alltrue([
      for r in var.inbound_rules : contains([
        "cidr_ipv4",
        "cidr_ipv6",
        "security_group_id",
        "prefix_list_id",
      ], r.source_type)
    ])
    error_message = <<-EOF
      Only the following values of `source_type` are available:
        - `cidr_ipv4`
        - `cidr_ipv6`
        - `security_group_id`
        - `prefix_list_id`
    EOF
  }
}

variable "outbound_rules" {
  type        = list(object({
    description = optional(string, "")
    protocol    = optional(string, "tcp")
    port_range  = string
    source_type = string
    source      = string
  }))
  default     = []
  description = <<-EOF
    Outbound Rules.

    Use `port_range` = `"all"` to define **all traffic** rule.
    `port_range` definition examples:
      - `80`
      - `"80"`
      - `"80-443"`
      - `"all"`

    Available `source_type` values:
        - `cidr_ipv4`
        - `cidr_ipv6`
        - `security_group_id`
        - `prefix_list_id`
  EOF

  validation {
    condition = alltrue([
      for r in var.outbound_rules : contains([
        "cidr_ipv4",
        "cidr_ipv6",
        "security_group_id",
        "prefix_list_id",
      ], r.source_type)
    ])
    error_message = <<-EOF
      Only the following values of `source_type` are available:
        - `cidr_ipv4`
        - `cidr_ipv6`
        - `security_group_id`
        - `prefix_list_id`
    EOF
  }
}
