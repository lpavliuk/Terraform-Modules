output "id" {
  value       = aws_ecr_repository.this.id
  sensitive   = false
  description = "ECR Repository ID"
}

output "arn" {
  value       = aws_ecr_repository.this.arn
  sensitive   = false
  description = "ECR Repository ARN"
}

output "name" {
  value       = aws_ecr_repository.this.name
  sensitive   = false
  description = "ECR Repository Name"
}

output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  sensitive   = false
  description = "ECR Repository URL"
}

output "registry_id" {
  value       = aws_ecr_repository.this.registry_id
  sensitive   = false
  description = "ECR Registry ID"
}
