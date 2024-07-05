# main.tf
module "cloudfront" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_cloudfront"

  name                   = var.codename
  alternate_domain_names = [var.web_client_host]
  acm_certificate_arn    = var.public_domain_certificate_arn

  origins = [{
    id                   = module.s3_bucket.id
    domain_name          = module.s3_bucket.domain_name
    access_control_id    = aws_cloudfront_origin_access_control.this.id
  }]

  cache_behaviors = [{
    name                       = "default"
    default                    = true
    target_origin_id           = module.s3_bucket.id
    allowed_methods            = ["GET", "HEAD"]
    default_ttl                = 2592000  # 30 days
    min_ttl                    = 86400    # 1 day
    max_ttl                    = 31536000 # 365 days
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
    cache_query_strings        = {
      behaviour = "all"
    }
    encoding_gzip              = true
    encoding_brotli            = true
    functions                  = [{
      event_type   = "viewer-request"
      is_lambda    = false
      function_arn = aws_cloudfront_function.custom_http_headers.arn
    }]
  }]

  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]
}

module "s3_bucket" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_s3_bucket"

  bucket_prefix           = "${local.codename}-cloudfront-"
  enable_versioning       = true

  current_version_expiration_days    = 1
  noncurrent_version_expiration_days = 1
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${local.codename}-oac"
  description                       = "OAC for CloudFront: ${local.codename}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy
resource "aws_cloudfront_response_headers_policy" "default" {
  name    = "${var.codename}-response-headers-policy"
  comment = "CloudFront Response Headers Policy for ${var.codename}"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = true
      value    = "max-age=2592000" // 30 days
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function
resource "aws_cloudfront_function" "custom_http_headers" {
  name    = "${var.codename}-custom-http-headers"
  runtime = "cloudfront-js-1.0"
  comment = "Custom HTTP Headers"
  publish = true
  code    = file("${path.root}/cloudfront_function.js")

  lifecycle {
    create_before_destroy = true
  }
}
