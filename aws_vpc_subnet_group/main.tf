locals {
  az_list = data.aws_availability_zones.available.names
  max_az_number = length(local.az_list) < var.max_az_number ? length(local.az_list) : var.max_az_number
  # https://developer.hashicorp.com/terraform/language/functions/cidrsubnets
  subnet_group_cidrs = cidrsubnets(var.cidr, 2, 2, 2, 2) # 10.0.0.0/18 => 10.0.0.0/20, 10.0.16.0/20, etc.
  subnet_group = [
    for index, az in slice(local.az_list, 0, local.max_az_number) : {
      az: az
      cidr: element(local.subnet_group_cidrs, index)
    }
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "subnets" {
  for_each = { for subnet in local.subnet_group : subnet.az => subnet }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.auto_assign_public_ip

  tags = {
    Name = "${var.vpc_name}-${var.name}-${each.key}"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "zone" {
  for_each = { for subnet in local.subnet_group : subnet.az => subnet }

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-${var.name}-subnet-group-${each.key}"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "this_subnet_group" {
  for_each = { for subnet in local.subnet_group : subnet.az => subnet }

  route_table_id = aws_route_table.zone[each.key].id
  subnet_id      = aws_subnet.subnets[each.key].id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_network_acl" "this_subnet" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.vpc_name}-${var.name}-subnet-group"
  }
}

resource "aws_network_acl_association" "this_subnet_group" {
  for_each = { for subnet in local.subnet_group : subnet.az => subnet }

  network_acl_id = aws_network_acl.this_subnet.id
  subnet_id      = aws_subnet.subnets[each.key].id
}
