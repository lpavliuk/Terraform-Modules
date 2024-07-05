# main.tf
module "efs_artefacts" {
  source = "../../../../modules/aws_efs"

  name           = "${local.codename}-artefacts"
  vpc_id         = local.subnet_group_vpc_id
  subnet_ids     = local.subnet_group_subnet_ids
  is_encrypted   = true
  enable_backup  = false
  # replica_region = local.account_config.aws_secondary_region_name
}