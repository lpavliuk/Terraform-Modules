output "id" {
  value       = aws_db_proxy.this.id
  sensitive   = false
  description = "RDS Proxy ID"
}

output "arn" {
  value       = aws_db_proxy.this.arn
  sensitive   = false
  description = "RDS Proxy ARN"
}

output "name" {
  value       = aws_db_proxy.this.name
  sensitive   = false
  description = "RDS Proxy Name"
}

output "default_endpoint" {
  value       = aws_db_proxy.this.endpoint
  sensitive   = false
  description = "RDS Proxy Default Endpoint"
}

output "read_only_endpoint" {
  value       = var.target_rds_cluster_name != null && var.create_read_only_endpoint ? aws_db_proxy_endpoint.read_only[0].endpoint : null
  sensitive   = false
  description = "RDS Proxy Read-Only Endpoint"
}

output "security_group_ids" {
  value       = aws_db_proxy.this.vpc_security_group_ids
  sensitive   = false
  description = "Security Group IDs of the RDS Proxy"
}
