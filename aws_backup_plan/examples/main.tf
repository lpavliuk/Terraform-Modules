# main.tf
module "backup_plan" {
  source = "../../../../modules/aws_backup_plan"

  name = local.codename

  backup_resources      = []
  backup_not_resources  = [
    # For the following resources separate backup plans are used:
    "arn:aws:s3:::*"
  ]
  backup_selection_tags = [{
    type  = "STRINGEQUALS"
    key   = "backup-plan:${local.codename}"
    value = "true"
  }]

  rules = [
    { # Run at 14:00 UTC (01:00 Sydney AEDT) every day
      name                   = "daily"
      schedule_cron          = "0 14 ? * * *"
      start_window_mins      = 120 # 2 hours
      completion_window_mins = 240 # 4 hours
      lifecycle              = {
        delete_after_days = 30
      }
      copy_action = {
        destination_vault_arn = local.cross_region_backup_vault_arn
        lifecycle             = {
          delete_after_days = 30
        }
      }
    }
  ]

  notifications_sns_topic_arn = local.notifications_sns_topic_arn
  notifications_events        = [
    "BACKUP_JOB_FAILED",
    "COPY_JOB_FAILED",
  ]
}
