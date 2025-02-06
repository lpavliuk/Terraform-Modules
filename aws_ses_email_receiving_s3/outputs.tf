output "id" {
  value       = aws_ses_receipt_rule_set.this.id
  sensitive   = false
  description = "SES Receipt Rule Set ID"
}

output "arn" {
  value       = aws_ses_receipt_rule_set.this.arn
  sensitive   = false
  description = "SES Receipt Rule Set ARN"
}

output "name" {
  value       = aws_ses_receipt_rule_set.this.rule_set_name
  sensitive   = false
  description = "SES Receipt Rule Set Name"
}
