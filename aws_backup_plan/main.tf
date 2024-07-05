# AWS Backup:
# Feature availability by AWS Region: https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html#features-by-resource
#
locals {
  custom_events       = ["BACKUP_JOB_FAILED"]
  backup_vault_events = setsubtract(var.notifications_events, local.custom_events)
  iam_role_policies   = [
    "service-role/AWSBackupServiceRolePolicyForBackup",
    "service-role/AWSBackupServiceRolePolicyForRestores",
    "AWSBackupServiceRolePolicyForS3Backup",
    "AWSBackupServiceRolePolicyForS3Restore"
  ]
}
# ============================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan
resource "aws_backup_plan" "this" {
  name = "${var.name}-plan"

  dynamic "rule" {
    for_each = var.rules

    content {
      rule_name                = lookup(rule.value, "name", null)
      target_vault_name        = aws_backup_vault.this.name
      schedule                 = lookup(rule.value, "schedule_cron", null) != null ? "cron(${rule.value.schedule_cron})" : null
      start_window             = lookup(rule.value, "start_window_mins", null)
      completion_window        = lookup(rule.value, "completion_window_mins", null)
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", null)
      recovery_point_tags      = lookup(rule.value, "recovery_point_tags", [])

      dynamic "lifecycle" {
        for_each = lookup(rule.value, "lifecycle", null) != null ? [true] : []

        content {
          cold_storage_after = lookup(rule.value.lifecycle, "cold_storage_after_days", null)
          delete_after       = lookup(rule.value.lifecycle, "delete_after_days", null)
        }
      }

      dynamic "copy_action" {
        for_each = try(lookup(rule.value.copy_action, "destination_vault_arn", null), null) != null ? [true] : []

        content {
          destination_vault_arn = lookup(rule.value.copy_action, "destination_vault_arn", null)

          dynamic "lifecycle" {
            for_each = lookup(rule.value.copy_action, "lifecycle", null) != null != null ? [true] : []

            content {
              cold_storage_after = lookup(rule.value.copy_action.lifecycle, "cold_storage_after_days", null)
              delete_after       = lookup(rule.value.copy_action.lifecycle, "delete_after_days", null)
            }
          }
        }
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault
resource "aws_backup_vault" "this" {
  name        = "${var.name}-vault"
  kms_key_arn = null # Default one is used
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection
resource "aws_backup_selection" "this" {
  name          = "${var.name}-selection"
  iam_role_arn  = aws_iam_role.this.arn
  plan_id       = aws_backup_plan.this.id
  resources     = var.backup_resources
  not_resources = var.backup_not_resources

  dynamic "selection_tag" {
    for_each = var.backup_selection_tags

    content {
      type  = selection_tag.value["type"]
      key   = selection_tag.value["key"]
      value = selection_tag.value["value"]
    }
  }
}

# https://www.terraform.io/docs/providers/aws/d/iam_policy_document
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "this" {
  name_prefix        = "backup-plan-${var.name}-"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy { # requires for EC2 Instances restore: https://docs.aws.amazon.com/aws-backup/latest/devguide/restoring-ec2.html
    name = "PassRole"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid = "PassRole"
        Effect = "Allow"
        Action =  [
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
        ],
        Condition = {
          "StringEquals" = {
            "iam:PassedToService": "ec2.amazonaws.com"
          }
        }
      }]
    })
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "this_iam_role" {
  for_each = toset(local.iam_role_policies)

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/${each.value}"
  role       = aws_iam_role.this.name
}

# ================================================
# Notifications and Alarms:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications
resource "aws_backup_vault_notifications" "this" {
  count = var.notifications_sns_topic_arn != "" ? 1 : 0

  backup_vault_name   = aws_backup_vault.this.name
  sns_topic_arn       = var.notifications_sns_topic_arn
  backup_vault_events = local.backup_vault_events

  lifecycle {
    precondition {
      condition     = var.notifications_sns_topic_arn != "" && length(var.notifications_events) > 0
      error_message = "If 'notifications_sns_topic_arn' is defined, 'notifications_events' is required!"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "backup_jobs_failed" {
  count = contains(var.notifications_events, "BACKUP_JOB_FAILED") ? 1 : 0

  alarm_name                = "aws-backup-${var.name}-plan-backupJobsFailed"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "NumberOfBackupJobsFailed"
  namespace                 = "AWS/Backup"
  period                    = 3600 # 1 hour
  statistic                 = "Average"
  threshold                 = 0
  alarm_description         = "Some AWS Backup Jobs have failed over the last hour. For more details, go to AWS Console => AWS Backup => Jobs."
  alarm_actions             = [var.notifications_sns_topic_arn]
  ok_actions                = []
  insufficient_data_actions = []
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-missing-data
  treat_missing_data        = "notBreaching"

  dimensions = { # https://docs.aws.amazon.com/aws-backup/latest/devguide/cloudwatch.html
    BackupVaultName = aws_backup_vault.this.name
  }
}
