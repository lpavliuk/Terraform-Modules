# main.tf
module "subnet_group" {
  source = "../../../../modules/aws_vpc_subnet_group"

  name                  = "public"
  cidr                  = "10.0.0.0/18"
  vpc_id                = local.vpc_id
  vpc_name              = local.vpc_name
  auto_assign_public_ip = true
}
