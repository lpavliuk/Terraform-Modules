# main.tf
module "instance_sg_rules" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_security_group_rules"

  security_group_id = local.instance_sg_id
  inbound_rules     = [
    {
      description = "(MySQL) from Specific IP Address"
      protocol    = "tcp"
      port_range  = 3306
      source_type = "cidr_ipv4"
      source      = "172.31.11.16/32"
    },
    {
      description = "(MSs Ports) from VPC"
      protocol    = "tcp"
      port_range  = "52000-52999"
      source_type = "cidr_ipv4"
      source      = "172.31.0.0/16"
    },
    {
      description = "from EC2 VPN"
      port_range  = "all"
      source_type = "security_group_id"
      source      = local.vpn_instance_sg_id
    },
  ]
}
