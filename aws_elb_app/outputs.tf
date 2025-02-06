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
  description = "ARN of the HTTP (:80) Listener attached to the ALB"
}

output "https_listener_arn" {
  value       = var.https_certificate_arn == null ? null : aws_lb_listener.https[0].arn
  sensitive   = false
  description = "ARN of the HTTPS (:443) Listener attached to the ALB"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  sensitive   = false
  description = "Security Group ID of the ALB"
}
