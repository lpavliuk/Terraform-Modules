# main.tf
module "network_acl_rules" {
  source   = "../../../../modules/aws_network_acl_rules"
  for_each = toset(local.subnet_groups_network_acl_ids)

  network_acl_id    = each.value
  start_rule_number = local.acl_rule_number

  inbound_rules = [
    {
      action      = "allow"
      protocol    = "tcp"
      port_range  = "52000-54000"
      source_type = "cidr_ipv4"
      source      = "10.0.0.0/16"
    },
    {
      action      = "allow"
      protocol    = "tcp"
      port_range  = 443
      source_type = "cidr_ipv4"
      source      = "10.0.0.0/16"
    },
    {
      action      = "allow"
      protocol    = "tcp"
      port_range  = 80
      source_type = "cidr_ipv4"
      source      = "10.0.0.0/16"
    }
  ]

  outbound_rules = [
    {
      action      = "allow"
      port_range  = "all"
      source_type = "cidr_ipv4"
      source      = "10.0.0.0/16"
    }
  ]
}