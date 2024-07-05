# main.tf
module "vpc" {
  source = "../../../../modules/aws_vpc"

  name             = "example"
  cidr             = "10.0.0.0/16"
  domain_zone_name = "intranet.vpc"
}
