# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = var.name
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  default_root_object = var.default_root_object
  aliases             = var.alternate_domain_names

  dynamic "origin" {
    for_each = { for e in var.origins: e.id => e }

    content {
      origin_id                = origin.value.id
      domain_name              = origin.value.domain_name
      origin_access_control_id = origin.value.access_control_id

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [1] : []

        content {
          http_port                = lookup(origin.value.custom_origin_config, "http_port", 80)
          https_port               = lookup(origin.value.custom_origin_config, "https_port", 443)
          origin_protocol_policy   = origin.value.custom_origin_config.protocol_policy
          origin_ssl_protocols     = lookup(origin.value.custom_origin_config, "ssl_protocols", ["TLSv1.2"])
          origin_keepalive_timeout = lookup(origin.value.custom_origin_config, "keepalive_timeout", 5)
          origin_read_timeout      = lookup(origin.value.custom_origin_config, "read_timeout", 30)
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers != null ? origin.value.custom_headers : []

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = length(var.alternate_domain_names) != 0 ? var.acm_certificate_arn : null
    cloudfront_default_certificate = length(var.alternate_domain_names) != 0 ? false : true
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restrictions != null ? var.geo_restrictions.restriction_type : "none"
      locations        = var.geo_restrictions != null ? var.geo_restrictions.locations : []
    }
  }

  dynamic "default_cache_behavior" {
    for_each = { for e in var.cache_behaviors: e.name => e if e.default == true }

    content {
      target_origin_id           = lookup(default_cache_behavior.value, "target_origin_id", null)
      allowed_methods            = lookup(default_cache_behavior.value, "allowed_methods", ["GET", "HEAD"])
      cached_methods             = lookup(default_cache_behavior.value, "cache_methods", ["GET", "HEAD"])
      cache_policy_id            = aws_cloudfront_cache_policy.this[default_cache_behavior.value.name].id
      response_headers_policy_id = lookup(default_cache_behavior.value, "response_headers_policy_id", null)
      compress                   = lookup(default_cache_behavior.value, "encoding_gzip", null)
      viewer_protocol_policy     = lookup(default_cache_behavior.value, "viewer_protocol_policy", null)
      default_ttl                = lookup(default_cache_behavior.value, "default_ttl", null)
      max_ttl                    = lookup(default_cache_behavior.value, "max_ttl", null)
      min_ttl                    = lookup(default_cache_behavior.value, "min_ttl", null)

      dynamic "function_association" {
        for_each = { for f in default_cache_behavior.value.functions: f.event_type => f if f.is_lambda == false }

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      dynamic "lambda_function_association" {
        for_each = { for f in default_cache_behavior.value.functions: f.event_type => f if f.is_lambda == true }

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.function_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = { for e in var.cache_behaviors: e.name => e if e.default != true }

    content {
      target_origin_id           = lookup(ordered_cache_behavior.value, "target_origin_id", null)
      path_pattern               = lookup(ordered_cache_behavior.value, "path_pattern", null)
      allowed_methods            = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD"])
      cached_methods             = lookup(ordered_cache_behavior.value, "cache_methods", ["GET", "HEAD"])
      cache_policy_id            = aws_cloudfront_cache_policy.this[ordered_cache_behavior.value.name].id
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)
      compress                   = lookup(ordered_cache_behavior.value, "encoding_gzip", null)
      viewer_protocol_policy     = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", null)
      default_ttl                = lookup(ordered_cache_behavior.value, "default_ttl", null)
      max_ttl                    = lookup(ordered_cache_behavior.value, "max_ttl", null)
      min_ttl                    = lookup(ordered_cache_behavior.value, "min_ttl", null)

      dynamic "function_association" {
        for_each = { for f in ordered_cache_behavior.value.functions: f.event_type => f if f.is_lambda == false }

        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }

      dynamic "lambda_function_association" {
        for_each = { for f in ordered_cache_behavior.value.functions: f.event_type => f if f.is_lambda == true }

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.function_arn
          include_body = lambda_function_association.value.include_body
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = { for r in var.custom_error_responses: r.error_code => r }

    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.alternate_domain_names) != 0 && var.acm_certificate_arn != null
      error_message = "If alternate_domain_names are provided, acm_certificate_arn is required!"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy
resource "aws_cloudfront_cache_policy" "this" {
  for_each = { for e in var.cache_behaviors: e.name => e }

  name        = "${var.name}-${each.value.name}-cache-policy"
  comment     = "${each.value.name} CloudFront Cache Policy for ${var.name}"

  # [!] NOTE: There is no way of setting a default cache-control value for an S3 bucket.
  # (You can only set it for individual files; if override is not set, the default, immutable,
  # value of 604800 will be used for new files or files that do not have a custom value set.)
  # Therefore, we set 'Cache-Control' header with aws_cloudfront_response_headers_policy.
  default_ttl = lookup(each.value, "default_ttl", null)
  max_ttl     = lookup(each.value, "max_ttl", null)
  min_ttl     = lookup(each.value, "min_ttl", null)

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = each.value.cache_cookies != null ? each.value.cache_cookies.behaviour : "none"

      cookies {
        items = each.value.cache_cookies != null ? each.value.cache_cookies.items : null
      }
    }

    headers_config {
      header_behavior = each.value.cache_headers != null ? each.value.cache_headers.behaviour : "none"

      headers {
        items = each.value.cache_headers != null ? each.value.cache_headers.items : null
      }
    }

    query_strings_config {
      query_string_behavior = each.value.cache_query_strings != null ? each.value.cache_query_strings.behaviour : "none"

      query_strings {
        items = each.value.cache_query_strings != null ? each.value.cache_query_strings.items : null
      }
    }

    enable_accept_encoding_brotli = lookup(each.value, "encoding_brotli", true)
    enable_accept_encoding_gzip   = lookup(each.value, "encoding_gzip", true)
  }
}
