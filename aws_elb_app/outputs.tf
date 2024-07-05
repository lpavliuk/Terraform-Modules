output "arn" {
  value       = aws_lb.this.arn
  sensitive   = false
  description = "ALB ARN"
}

output "name" {
  value       = aws_lb.this.name
  sensitive   = false
  description = "ALB Name"
}

output "dns_name" {
  value       = aws_lb.this.dns_name
  sensitive   = false
  description = "ALB DNS Name"
}

output "zone_id" {
  value       = aws_lb.this.zone_id
  sensitive   = false
  description = "Zone ID the ALB provisioned in"
}

output "http_listener_arn" {
  value       = aws_lb_listener.http.arn
  sensitive   = false
  description = "ARN of the HTTP Listener attached to the ALB"
}

output "https_listener_arn" {
  value       = aws_lb_listener.https.arn
  sensitive   = false
  description = "ARN of the HTTPS Listener attached to the ALB"
}

output "waf_acl_arn" {
  value       = var.waf_acl_arn
  sensitive   = false
  description = "ARN of AWS WAF ACL attached to the ALB"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "Security Group ID of the ALB"
}
