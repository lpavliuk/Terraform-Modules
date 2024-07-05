# main.tf
module "nlb" {
  source = "../../../../modules/aws_elb_net"

  name                  = local.codename
  vpc_id                = local.vpc_id
  subnet_ids            = local.subnet_group_subnets_ids
  extra_sg_ids          = [ local.vpc_sg_id ]
  is_private            = false
  enable_cross_zone     = true

  enable_deletion_protection = true
}
