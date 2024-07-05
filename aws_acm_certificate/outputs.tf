output "certificate_arn" {
  value       = aws_acm_certificate.this.arn
  sensitive   = false
  description = "ACM Certificate ARN"
}
