variable "name" {
  type        = string
  nullable    = false
  description = "Topic Name"
}

variable "policy_statements" {
  type        = list(object({
    sid        = string
    actions    = list(string)
    effect     = string
    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    condition  = optional(object({
      test     = string
      variable = string
      values   = list(string)
    }))
  }))
  nullable    = false
  description = "Policy Statements of the SNS Topic"
}

variable "subscriptions" {
  type        = list(object({
    protocol = string
    endpoint = string
  }))
  default     = []
  description = <<-EOT
    Subscriptions for the SNS Topic. Available `protocol` values:
      - `sqs`
      - `sms`
      - `lambda`
      - `firehose`
      - `application`
      - `email`
      - `email-json`
      - `http`
      - `https`

    [More details...](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol)
  EOT

  validation {
    condition = alltrue([
      for tag in var.subscriptions : contains([
        "sqs",
        "sms",
        "lambda",
        "firehose",
        "application",
        "email",
        "email-json",
        "http",
        "https"
      ], tag.protocol)
    ])
    error_message = <<-EOF
      Only the following 'protocol' values are available:
        - `sqs`,
        - `sms`,
        - `lambda`,
        - `firehose`,
        - `application`,
        - `email`,
        - `email-json`,
        - `http`,
        - `https`
    EOF
  }
}
