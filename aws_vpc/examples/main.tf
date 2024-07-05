# main.tf
module "vpc" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_vpc"

  name             = "example"
  cidr             = "10.0.0.0/16"
  domain_zone_name = "intranet.vpc"
}
