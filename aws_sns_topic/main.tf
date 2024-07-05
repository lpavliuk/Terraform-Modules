# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic
resource "aws_sns_topic" "this" {
  name_prefix  = "${var.name}-"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription
resource "aws_sns_topic_subscription" "this" {
  for_each = { for sub in var.subscriptions : sub.endpoint => sub }

  topic_arn = aws_sns_topic.this.arn
  protocol  = lookup(each.value, "protocol", null)
  endpoint  = lookup(each.value, "endpoint", null)
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy
resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid       = lookup(statement.value, "sid", null )
      actions   = lookup(statement.value, "actions", [])
      effect    = lookup(statement.value, "effect", null)
      resources = [aws_sns_topic.this.arn]

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", null) != null ? [true] : []

        content {
          type        = lookup(statement.value.principals, "type", null)
          identifiers = lookup(statement.value.principals, "identifiers", [])
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", null) != null ? [true] : []

        content {
          test     = lookup(statement.value.condition, "test", null)
          variable = lookup(statement.value.condition, "variable", null)
          values   = lookup(statement.value.condition, "values", [])
        }
      }
    }
  }
}
