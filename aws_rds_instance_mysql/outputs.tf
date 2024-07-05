output "id" {
  value       = aws_db_instance.this.id
  sensitive   = false
  description = "RDS Instance ID"
}

output "arn" {
  value       = aws_db_instance.this.arn
  sensitive   = false
  description = "RDS Instance ARN"
}

output "name" {
  value       = aws_db_instance.this.identifier
  sensitive   = false
  description = "RDS Instance Name"
}

output "host" {
  value       = aws_db_instance.this.address
  sensitive   = false
  description = "Database Host"
}

output "port" {
  value       = aws_db_instance.this.port
  sensitive   = false
  description = "Database Port"
}

output "instance_class" {
  value       = aws_db_instance.this.instance_class
  sensitive   = false
  description = "RDS Instance Class"
}

output "master_user" {
  value       = aws_db_instance.this.username
  sensitive   = false
  description = "Database Master Username"
}

output "master_user_secret" {
  value       = var.manage_master_user_pswd ? lookup(aws_db_instance.this, "master_user_secret", [{}])[0] : null
  sensitive   = false
  description = "AWS Secret Manager secret details where Database Master Password is stored"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "Security Group ID of the RDS Instance"
}
