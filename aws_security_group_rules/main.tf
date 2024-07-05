# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for rule in var.inbound_rules : "${rule.port_range}_${rule.source}" => rule }

  security_group_id = var.security_group_id

  description       = lookup(each.value, "description", "")
  ip_protocol       = each.value.port_range == "all" ? "-1" : lookup(each.value, "protocol", "tcp")
  from_port         = each.value.port_range == "all" ? null : split("-", each.value.port_range)[0]
  to_port           = each.value.port_range == "all" ? null : try(split("-", each.value.port_range)[1], each.value.port_range)
  # Source Types:
  cidr_ipv4                    = each.value.source_type == "cidr_ipv4" ? each.value.source : null
  cidr_ipv6                    = each.value.source_type == "cidr_ipv6" ? each.value.source : null
  referenced_security_group_id = each.value.source_type == "security_group_id" ? each.value.source : null
  prefix_list_id               = each.value.source_type == "prefix_list_id" ? each.value.source : null
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for rule in var.outbound_rules : "${rule.port_range}_${rule.source}" => rule }

  security_group_id = var.security_group_id

  description       = lookup(each.value, "description", "")
  ip_protocol       = each.value.port_range == "all" ? "-1" : lookup(each.value, "protocol", "tcp")
  from_port         = each.value.port_range == "all" ? null : split("-", each.value.port_range)[0]
  to_port           = each.value.port_range == "all" ? null : try(split("-", each.value.port_range)[1], each.value.port_range)
  # Source Types:
  cidr_ipv4                    = each.value.source_type == "cidr_ipv4" ? each.value.source : null
  cidr_ipv6                    = each.value.source_type == "cidr_ipv6" ? each.value.source : null
  referenced_security_group_id = each.value.source_type == "security_group_id" ? each.value.source : null
  prefix_list_id               = each.value.source_type == "prefix_list_id" ? each.value.source : null
}
