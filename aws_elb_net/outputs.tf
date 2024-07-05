output "arn" {
  value       = aws_lb.this.arn
  sensitive   = false
  description = "NLB ARN"
}

output "name" {
  value       = aws_lb.this.name
  sensitive   = false
  description = "NLB Name"
}

output "dns_name" {
  value       = aws_lb.this.dns_name
  sensitive   = false
  description = "NLB DNS Name"
}

output "zone_id" {
  value       = aws_lb.this.zone_id
  sensitive   = false
  description = "Zone ID the NLB provisioned in"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "Security Group ID of the NLB"
}
