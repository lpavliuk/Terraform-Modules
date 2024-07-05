# main.tf
module "subnet_group" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_vpc_subnet_group"

  name                  = "public"
  cidr                  = "10.0.0.0/18"
  vpc_id                = local.vpc_id
  vpc_name              = local.vpc_name
  auto_assign_public_ip = true
}
