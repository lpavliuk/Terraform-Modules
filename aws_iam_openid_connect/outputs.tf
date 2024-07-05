output "client_role_arn" {
  value       = aws_iam_role.client_role.arn
  sensitive   = false
  description = "Client Role ARN"
}
