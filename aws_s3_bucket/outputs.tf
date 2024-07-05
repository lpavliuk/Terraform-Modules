output "id" {
  value       = aws_s3_bucket.this.id
  sensitive   = false
  description = "Bucket ID"
}

output "arn" {
  value       = aws_s3_bucket.this.arn
  sensitive   = false
  description = "Bucket ARN"
}

output "name" {
  value       = aws_s3_bucket.this.bucket
  sensitive   = false
  description = "Bucket Name"
}

output "domain_name" {
  value       = aws_s3_bucket.this.bucket_regional_domain_name
  sensitive   = false
  description = "Bucket Regional Domain Name"
}

output "cross_region_replication" {
  value       = var.enable_replication
  sensitive   = false
  description = "Bucket replication enabled status"
}

output "replica_bucket_arn" {
  value       = var.enable_replication ? var.replica_bucket_arn : null
  sensitive   = false
  description = "Replica bucket ARN that objects are replicated to"
}

output "iam_policy_read_only_arn" {
  value       = var.create_iam_policies ? aws_iam_policy.read_only[0].arn : null
  sensitive   = false
  description = "Custom Read Only IAM Policy ARN"
}

output "iam_policy_write_read_only_arn" {
  value       = var.create_iam_policies ? aws_iam_policy.write_read_only[0].arn : null
  sensitive   = false
  description = "Custom Write and Read Only IAM Policy ARN"
}

output "iam_policy_full_access_arn" {
  value       = var.create_iam_policies ? aws_iam_policy.full_access[0].arn : null
  sensitive   = false
  description = "Custom Full Access IAM Policy ARN"
}
