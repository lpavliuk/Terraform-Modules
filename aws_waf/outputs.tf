output "name" {
  value       = aws_wafv2_web_acl.this.name
  sensitive   = false
  description = "WAF ACL Name"
}

output "id" {
  value       = aws_wafv2_web_acl.this.id
  sensitive   = false
  description = "WAF ACL ID"
}

output "arn" {
  value       = aws_wafv2_web_acl.this.arn
  sensitive   = false
  description = "WAF ACL ARN"
}
