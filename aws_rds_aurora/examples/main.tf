# main.tf
module "rds_instance_aurora" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_rds_aurora"

  name                       = local.codename
  instance_class             = local.instance_type
  engine                     = "aurora-mysql"
  engine_version             = "8.0.mysql_aurora.3.10.0"
  vpc_id                     = local.vpc_id
  rds_subnet_group_id        = local.rds_subnet_group_id

  master_username                   = "masteruser"
  manage_master_user_pswd           = true
  is_private                        = true
  enable_enhanced_monitoring        = true
  backup_retention_period_days      = 0                     # [!] Disabled as AWS Backup is used!
  backup_window_utc_period          = "14:00-16:00"         # UTC => 01:00-03:00 Sydney AEDT
  maintenance_window_utc_period     = "Sat:16:00-Sat:18:00" # UTC => Sun 03:00-05:00 Sydney AEDT

  cloudwatch_logs_exports               = ["error"]
  cloudwatch_logs_retention_period_days = 30
}
