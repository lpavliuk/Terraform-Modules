# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "ingress" {
  for_each = { for index, rule in var.inbound_rules : var.start_rule_number + index => rule }

  network_acl_id = var.network_acl_id

  egress      = false
  rule_number = each.key
  rule_action = each.value.action
  protocol    = each.value.port_range == "all" ? "-1" : lookup(each.value, "protocol", "tcp")
  from_port   = each.value.port_range == "all" ? null : split("-", each.value.port_range)[0]
  to_port     = each.value.port_range == "all" ? null : try(split("-", each.value.port_range)[1], each.value.port_range)
  # Source Types:
  cidr_block      = each.value.source_type == "cidr_ipv4" ? each.value.source : null
  ipv6_cidr_block = each.value.source_type == "cidr_ipv6" ? each.value.source : null
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
resource "aws_network_acl_rule" "egress" {
  for_each = { for index, rule in var.outbound_rules : var.start_rule_number + index => rule }

  network_acl_id = var.network_acl_id

  egress      = true
  rule_number = each.key
  rule_action = each.value.action
  protocol    = each.value.port_range == "all" ? "-1" : lookup(each.value, "protocol", "tcp")
  from_port   = each.value.port_range == "all" ? null : split("-", each.value.port_range)[0]
  to_port     = each.value.port_range == "all" ? null : try(split("-", each.value.port_range)[1], each.value.port_range)
  # Source Types:
  cidr_block      = each.value.source_type == "cidr_ipv4" ? each.value.source : null
  ipv6_cidr_block = each.value.source_type == "cidr_ipv6" ? each.value.source : null
}
