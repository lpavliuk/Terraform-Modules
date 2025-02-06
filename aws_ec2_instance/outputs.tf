output "id" {
  value       = aws_instance.this.id
  sensitive   = false
  description = "Instance ID"
}

output "name" {
  value       = try(aws_instance.this.tags["Name"], "")
  sensitive   = false
  description = "Instance Name"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  sensitive   = false
  description = "Instance's Private IP Address"
}

output "root_volume_id" {
  value       = aws_instance.this.root_block_device[0].volume_id
  sensitive   = false
  description = "Instance's EBS Volume ID (Root)"
}

output "type" {
  value       = aws_instance.this.instance_type
  sensitive   = false
  description = "Instance Type"
}

output "security_group_id" {
  value       = var.security_group_id
  sensitive   = false
  description = "Instance's default Security Group ID"
}

output "vpc_security_group_ids" {
  value       = aws_instance.this.vpc_security_group_ids
  sensitive   = false
  description = "Security Group IDs attached to the Instance"
}

output "availability_zone" {
  value       = aws_instance.this.availability_zone
  sensitive   = false
  description = "Availability Zone the Instance launched in"
}

output "iam_role_name" {
  value       = aws_iam_role.this_instance.name
  sensitive   = false
  description = "IAM Role attached to the Instance"
}

output "iam_profile" {
  value       = aws_instance.this.iam_instance_profile
  sensitive   = false
  description = "IAM Profile Name attached to the Instance"
}

output "iam_profile_arn" {
  value       = aws_iam_instance_profile.this_instance.arn
  sensitive   = false
  description = "IAM Profile ARN attached to the Instance"
}
