output "id" {
  value       = aws_backup_plan.this.id
  sensitive   = false
  description = "Backup Plan ID"
}

output "arn" {
  value       = aws_backup_plan.this.arn
  sensitive   = false
  description = "Backup Plan ARN"
}

output "name" {
  value       = aws_backup_plan.this.name
  sensitive   = false
  description = "Backup Plan Name"
}

output "backup_vault_id" {
  value       = aws_backup_vault.this.id
  sensitive   = false
  description = "Backup Vault ID"
}

output "backup_vault_arn" {
  value       = aws_backup_vault.this.arn
  sensitive   = false
  description = "Backup Vault ARN"
}

output "backup_vault_name" {
  value       = aws_backup_vault.this.name
  sensitive   = false
  description = "Backup Vault Name"
}
