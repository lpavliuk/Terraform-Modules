# main.tf
module "alb" {
  source = "../../../../modules/aws_elb_app"

  name                  = local.codename
  vpc_id                = local.vpc_id
  subnet_ids            = local.subnet_group_subnets_ids
  https_certificate_arn = local.public_domain_certificate_arn
  extra_sg_ids          = [ local.vpc_sg_id ]
  is_private            = false
  waf_acl_arn           = local.waf_arn

  enable_deletion_protection = true
}