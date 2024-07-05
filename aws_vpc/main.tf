# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "this_vpc" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-zone"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list
resource "aws_ec2_managed_prefix_list" "this_vpc" {
  name           = "Intranet (${var.name} VPC)"
  address_family = "IPv4"
  max_entries    = 10
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry
resource "aws_ec2_managed_prefix_list_entry" "entry" {
  prefix_list_id = aws_ec2_managed_prefix_list.this_vpc.id
  cidr           = aws_vpc.this.cidr_block
  description    = "${var.name} VPC"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this_vpc" {
  name        = "SG VPC - ${var.name}"
  vpc_id      = aws_vpc.this.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "this" {
  count = var.domain_zone_name != null ? 1 : 0

  name = var.domain_zone_name

  vpc {
    vpc_id = aws_vpc.this.id
  }

  lifecycle {
    ignore_changes = [vpc] # as VPC Peering attaches new VPC IDs to the Hosted Zone
  }
}

