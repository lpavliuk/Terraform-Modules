output "id" {
  value       = aws_cloudfront_distribution.this.id
  sensitive   = false
  description = "CloudFront Distribution ID"
}

output "arn" {
  value       = aws_cloudfront_distribution.this.arn
  sensitive   = false
  description = "CloudFront Distribution ARN"
}

output "domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  sensitive   = false
  description = "CloudFront Distribution Domain Name"
}

output "hosted_zone_id" {
  value       = aws_cloudfront_distribution.this.hosted_zone_id
  sensitive   = false
  description = "CloudFront Distribution Hosted Zone ID"
}
