# main.tf
module "sns_topic" {
  source = "../../../../modules/aws_sns_topic"

  name              = "slack-channel"
  subscriptions     = [
    { # Slack channel : "infra-alerts"
      protocol = "email"
      endpoint = "example@slack.com"
    }
  ]

  policy_statements = [
    {
      sid     = "AllowManageSNS"
      effect  = "Allow"
      actions = [
        "SNS:Subscribe",
        "SNS:Publish",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes"
      ]
      principals = {
        type        = "AWS"
        identifiers = ["*"]
      }
      condition  = {
        test     = "StringEquals"
        variable = "AWS:SourceOwner"
        values   = ["<AWS_ACCOUNT_ID>"]
      }
    },
    {
      sid     = "AllowBackupSNS"
      effect  = "Allow"
      actions = [
        "SNS:Publish",
      ]
      principals = {
        type        = "Service"
        identifiers = ["backup.amazonaws.com"]
      }
    }
  ]
}

