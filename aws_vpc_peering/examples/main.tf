# main.tf
module "vpc_peering" {
  source = "../../../../modules/aws_vpc_peering"

  providers = {
    aws.requester = aws
    aws.accepter  = aws.accepter
  }

  requester_vpc = {
    id                  = local.requester_vpc_id
    name                = local.requester_vpc_name
    account_id          = local.requester_vpc_account_id
    region              = local.requester_vpc_region
    cidr                = local.requester_vpc_cidr
    route_table_ids     = local.requester_subnet_groups_route_table_ids
    vpc_domain_zone_ids = local.requester_vpc_domain_zone_ids
  }

  accepter_vpc = {
    id                  = local.accepter_vpc_id
    name                = local.accepter_vpc_name
    account_id          = local.accepter_vpc_account_id
    region              = local.accepter_vpc_region
    cidr                = local.accepter_vpc_cidr
    route_table_ids     = local.accepter_subnet_groups_route_table_ids
    vpc_domain_zone_ids = local.accepter_vpc_domain_zone_ids
  }
}
