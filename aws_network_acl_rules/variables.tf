variable "network_acl_id" {
  type        = string
  nullable    = false
  description = "Network ACL ID"
}

variable "start_rule_number" {
  type        = number
  nullable    = false
  description = "Start number of rules"
}

variable "inbound_rules" {
  type        = list(object({
    action      = string
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
  EOF

  validation {
    condition = alltrue([
      for r in var.inbound_rules : contains([
        "cidr_ipv4",
        "cidr_ipv6",
      ], r.source_type)
    ])
    error_message = <<-EOF
      Only the following values of `source_type` are available:
        - `cidr_ipv4`
        - `cidr_ipv6`
    EOF
  }
}

variable "outbound_rules" {
  type        = list(object({
    action      = string
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
  EOF

  validation {
    condition = alltrue([
      for r in var.outbound_rules : contains([
        "cidr_ipv4",
        "cidr_ipv6",
      ], r.source_type)
    ])
    error_message = <<-EOF
      Only the following values of `source_type` are available:
        - `cidr_ipv4`
        - `cidr_ipv6`
    EOF
  }
}
