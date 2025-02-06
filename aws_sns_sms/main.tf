# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_sms_preferences
resource "aws_sns_sms_preferences" "this" {
  monthly_spend_limit                   = var.sms_limit_usd
  default_sender_id                     = var.default_sender_id
  default_sms_type                      = var.default_sms_type
  delivery_status_iam_role_arn          = aws_iam_role.delivery_status.arn
  delivery_status_success_sampling_rate = 100
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  count = var.notification_topic_arn != "" ? 1 : 0

  alarm_name                = "aws-sns-${data.aws_caller_identity.current.account_id}-sms-spending-limit"
  alarm_description         = "Monthly SMS Limit! SMS spending has almost reached the limit: ${var.sms_limit_usd} USD"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "SMSMonthToDateSpentUSD"
  namespace                 = "AWS/SNS"
  period                    = 60 # sec
  statistic                 = "Maximum"
  threshold                 = (var.sms_limit_usd / 100) * var.sms_limit_alarm_threshold_percent
  alarm_actions             = [var.notification_topic_arn]

  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html#alarms-and-missing-data
  treat_missing_data        = "notBreaching"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "delivery_status" {
  name_prefix        = "sns-sms-delivery-status-"
  assume_role_policy = data.aws_iam_policy_document.delivery_status_assume_role.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "delivery_status_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "sns_feedback" {
  name_prefix = "SNSFeedback"
  role        = aws_iam_role.delivery_status.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsPolicy"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutMetricFilter",
          "logs:PutRetentionPolicy",
        ]
        Resource = "*"
      },
    ]
  })
}
