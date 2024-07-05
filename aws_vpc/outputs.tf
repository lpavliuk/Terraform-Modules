output "name" {
  value       = var.name
  sensitive   = false
  description = "VPC Name"
}

output "id" {
  value       = aws_vpc.this.id
  sensitive   = false
  description = "VPC ID"
}

output "cidr" {
  value       = aws_vpc.this.cidr_block
  sensitive   = false
  description = "VPC CIDR Block"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this_vpc.id
  sensitive   = false
  description = "VPC Internet Gateway ID"
}

output "prefix_list_id" {
  value       = aws_ec2_managed_prefix_list.this_vpc.id
  sensitive   = false
  description = "VPC Prefix List ID"
}

output "security_group_id" {
  value       = aws_security_group.this_vpc.id
  sensitive   = false
  description = "VPC Security Group ID"
}

output "account_id" {
  value       = data.aws_caller_identity.this.account_id
  sensitive   = false
  description = "VPC AWS Account ID"
}

output "region" {
  value       = data.aws_region.current.name
  sensitive   = false
  description = "VPC AWS Region Name"
}

output "domain_zone_id" {
  value       = var.domain_zone_name != null ? aws_route53_zone.this[0].zone_id : null
  sensitive   = false
  description = "Route53 Private Hosted Zone ID"
}

output "domain_zone_name" {
  value       = var.domain_zone_name != null ? aws_route53_zone.this[0].name : null
  sensitive   = false
  description = "Route53 Private Hosted Zone Name"
}
