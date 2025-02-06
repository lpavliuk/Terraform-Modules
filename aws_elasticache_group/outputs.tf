output "id" {
  value       = aws_elasticache_replication_group.this.id
  sensitive   = false
  description = "ElastiCache Replication Group ID"
}

output "arn" {
  value       = aws_elasticache_replication_group.this.arn
  sensitive   = false
  description = "ElastiCache Replication Group ARN"
}

output "name" {
  value       = aws_elasticache_replication_group.this.id
  sensitive   = false
  description = "Cache Name"
}

output "host" {
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
  sensitive   = false
  description = "Cache Host"
}

output "port" {
  value       = aws_elasticache_replication_group.this.port
  sensitive   = false
  description = "Cache Port"
}

output "instance_type" {
  value       = aws_elasticache_replication_group.this.node_type
  sensitive   = false
  description = "ElastiCache Replication Group Instance Class"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "Security Group ID of the ElastiCache"
}

output "user_group_id" {
  value       = aws_elasticache_user_group.this.id
  sensitive   = false
  description = "User Group ID of the ElastiCache"
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.this.name
  sensitive   = false
  description = "CloudWatch Log Group"
}
