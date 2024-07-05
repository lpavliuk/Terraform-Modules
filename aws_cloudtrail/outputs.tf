output "arn" {
  value       = aws_cloudtrail.this.arn
  sensitive   = false
  description = "CloudTrail ARN"
}

output "id" {
  value       = aws_cloudtrail.this.id
  sensitive   = false
  description = "CloudTrail ID"
}

output "name" {
  value       = aws_cloudtrail.this.name
  sensitive   = false
  description = "CloudTrail Name"
}

output "s3_bucket" {
  value       = aws_cloudtrail.this.s3_bucket_name
  sensitive   = false
  description = "S3 Bucket Name where the logs are stored"
}

output "s3_bucket_key_prefix" {
  value       = aws_cloudtrail.this.s3_key_prefix != "" ? aws_cloudtrail.this.s3_key_prefix : null
  sensitive   = false
  description = "S3 Bucket Key Prefix where the logs are stored"
}

output "cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.cloudtrail.arn
  sensitive   = false
  description = "CloudWatch Log Group ARN"
}

output "cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.cloudtrail.name
  sensitive   = false
  description = "CloudWatch Log Group Name"
}

output "kms_key_id" {
  value       = aws_kms_key.cloudtrail.id
  sensitive   = false
  description = "KMS Key ID the logs are encrypted with"
}

output "kms_key_arn" {
  value       = aws_kms_key.cloudtrail.arn
  sensitive   = false
  description = "KMS Key ARN the logs are encrypted with"
}

output "kms_key_alias" {
  value       = aws_kms_alias.cloudtrail.name
  sensitive   = false
  description = "KMS Key Alias the logs are encrypted with"
}
