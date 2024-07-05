output "id" {
  value       = aws_efs_file_system.this.id
  sensitive   = false
  description = "EFS ID"
}

output "name" {
  value       = var.name
  sensitive   = false
  description = "EFS Name"
}

output "dns_name" {
  value       = aws_efs_file_system.this.dns_name
  sensitive   = false
  description = "EFS DNS Name"
}

output "is_encrypted" {
  value       = aws_efs_file_system.this.encrypted
  sensitive   = false
  description = "EFS Encryption Status"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "EFS Security Group ID"
}

output "replica_region" {
  value       = var.replica_region
  sensitive   = false
  description = "Region of the replicated EFS"
}

output "replica_id" {
  value       = var.replica_region != "" ? aws_efs_replication_configuration.replica[0].destination[0].file_system_id : null
  sensitive   = false
  description = "ID of the replicated EFS"
}
