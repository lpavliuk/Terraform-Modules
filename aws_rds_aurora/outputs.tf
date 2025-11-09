output "id" {
  value       = aws_rds_cluster.this.id
  sensitive   = false
  description = "RDS Cluster ID"
}

output "arn" {
  value       = aws_rds_cluster.this.arn
  sensitive   = false
  description = "RDS Cluster ARN"
}

output "name" {
  value       = aws_rds_cluster.this.cluster_identifier
  sensitive   = false
  description = "RDS Cluster Name"
}

output "resource_id" {
  value       = aws_rds_cluster.this.cluster_resource_id
  sensitive   = false
  description = "RDS Cluster Resource ID"
}

output "master_user" {
  value       = aws_rds_cluster.this.master_username
  sensitive   = false
  description = "Database Master Username"
}

output "master_user_secret" {
  value       = var.manage_master_user_pswd ? lookup(aws_rds_cluster.this, "master_user_secret", [{}])[0] : null
  sensitive   = false
  description = "AWS Secret Manager secret details where Database Master Password is stored"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "Security Group ID of the RDS Cluster"
}

output "writer_endpoint" {
  value       = aws_rds_cluster.this.endpoint
  sensitive   = false
  description = "Write Endpoint of the RDS Cluster"
}

output "reader_endpoint" {
  value       = aws_rds_cluster.this.reader_endpoint
  sensitive   = false
  description = "Read Endpoint of the RDS Cluster"
}

output "instances" {
  value = [for instance in aws_rds_cluster_instance.this :
    {
      id                = instance.id
      name              = instance.identifier
      arn               = instance.arn
      endpoint          = instance.endpoint
      instance_class    = instance.instance_class
      availability_zone = instance.availability_zone
    }
  ]
  sensitive   = false
  description = "List of RDS Cluster Instances"
}
