output "id" {
  value       = aws_ses_domain_identity.this.id
  sensitive   = false
  description = "Identity ID"
}

output "arn" {
  value       = aws_ses_domain_identity.this.arn
  sensitive   = false
  description = "Identity ARN"
}
