output "id" {
  value       = aws_sns_topic.this.id
  sensitive   = false
  description = "Topic ID"
}

output "arn" {
  value       = aws_sns_topic.this.arn
  sensitive   = false
  description = "Topic ARN"
}

output "name" {
  value       = aws_sns_topic.this.name
  sensitive   = false
  description = "Topic Name"
}

output "subscriptions" {
  value       = var.subscriptions
  sensitive   = false
  description = "Topic Subscriptions"
}