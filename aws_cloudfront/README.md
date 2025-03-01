# AWS CloudFront Module

This module creates [AWS CloudFront](https://aws.amazon.com/cloudfront/) distribution and S3 bucket as an origin.

**Note!** The CloudFront service has so many configurations that the module might not cover all.
Therefore, consider using the straightforward resource:
```hcl
resource "aws_cloudfront_distribution" "this" {}
```

<!-- Next block is generated by terraform-docs following .terraform-docs.yml config -->
<!-- BEGIN_TF_DOCS -->
## Example

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | < 2.0.0, >= 1.6.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | < 6.0, >= 5.22 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the CloudFront distribution.<br/><br/>**NOTE!** Must contain alphanumeric characters or hyphens (`-`). | `string` | n/a | yes |
| <a name="input_alternate_domain_names"></a> [alternate\_domain\_names](#input\_alternate\_domain\_names) | Alternate Domain Names (CNAME) of the distribution | `list(string)` | `[]` | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the ACM Certificate for `alternate_domain_names`.<br/><br/>**NOTE!** It is required if `alternate_domain_name` is defined.<br/>**NOTE!** The ACM certificate must be in `US-EAST-1` region! | `string` | `null` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Default Root Object of the CloudFront | `string` | `"index.html"` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | Maximum HTTP version to support on the CloudFront. [Available values.](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#http_version) | `string` | `"http2and3"` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | Enable IPv6 support | `bool` | `false` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | CloudFront edge locations are grouped into geographic regions, and AWS grouped regions into price classes.<br/><br/>[Choosing the price class for a CloudFront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html)<br/><br/>**NOTE!** Australia is only in `PriceClass_All`. | `string` | `"PriceClass_All"` | no |
| <a name="input_geo_restrictions"></a> [geo\_restrictions](#input\_geo\_restrictions) | Geo Location Restrictions for the distribution.<br/><br/>Available `restriction_type` values:<br/>  - `"whitelist"`<br/>  - `"blacklist"`<br/><br/>`locations` values must be defined in [ISO 3166-1-alpha-2 code](http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm) format.<br/>e.g. `["AU", "NZ", "GB"]`<br/><br/>[Browse Country Codes](https://www.iso.org/obp/ui/#search) | <pre>object({<br/>    restriction_type = string<br/>    locations        = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | Origins of the distribution | <pre>list(object({<br/>    id                   = string<br/>    domain_name          = string<br/>    access_control_id    = optional(string)<br/>    custom_origin_config = optional(object({<br/>      http_port         = optional(number, 80)<br/>      https_port        = optional(number, 443)<br/>      protocol_policy   = string<br/>      ssl_protocols     = optional(list(string), ["TLSv1.2"])<br/>      keepalive_timeout = optional(number, 5)<br/>      read_timeout      = optional(number, 30)<br/>    }))<br/>    custom_headers       = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })))<br/>  }))</pre> | n/a | yes |
| <a name="input_cache_behaviors"></a> [cache\_behaviors](#input\_cache\_behaviors) | Cache Behaviours of the distribution.<br/><br/>**NOTE!** It is not allowed to have more than one `default` behaviour.<br/><br/>**NOTE!** `path_pattern` is required if a behaviour is not default, otherwise it is ignored.<br/><br/>[Available values for `viewer_protocol_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer_protocol_policy)<br/><br/>### `functions` config:<br/>**NOTE!** You can associate a single function per `event_type`.<br/><br/>Available values for `event_type`:<br/>  - `"viewer-request"`<br/>  - `"viewer-response"`<br/>  - `"origin-request"`  - is ignored if `is_lambda` is `false`<br/>  - `"origin-response"` - is ignored if `is_lambda` is `false`<br/><br/>`function_arn` is an ARN of the CloudFront or Lambda Function.<br/>`include_body` is ignored if `is_lambda` is `false` | <pre>list(object({<br/>    name                       = string<br/>    default                    = bool<br/>    path_pattern               = optional(string, "*")<br/>    target_origin_id           = string<br/>    allowed_methods            = optional(list(string), ["GET", "HEAD"])<br/>    cache_methods              = optional(list(string), ["GET", "HEAD"])<br/>    viewer_protocol_policy     = optional(string, "redirect-to-https")<br/>    default_ttl                = optional(number, 2592000) # 30 days<br/>    max_ttl                    = optional(number, 2592000) # 30 days<br/>    min_ttl                    = optional(number, 5)       # 5 mins<br/>    cache_cookies              = optional(object({<br/>      behaviour = string<br/>      items     = optional(list(string))<br/>    }))<br/>    cache_headers              = optional(object({<br/>      behaviour = string<br/>      items     = optional(list(string))<br/>    }))<br/>    cache_query_strings        = optional(object({<br/>      behaviour = string<br/>      items     = optional(list(string))<br/>    }))<br/>    encoding_gzip              = optional(bool, true)<br/>    encoding_brotli            = optional(bool, true)<br/>    field_level_encryption_id  = optional(string)<br/>    response_headers_policy_id = optional(string)<br/>    origin_request_policy_id   = optional(string)<br/>    functions                  = optional(list(object({<br/>      event_type   = string<br/>      is_lambda    = bool<br/>      function_arn = string<br/>      include_body = optional(bool, false)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_error_responses"></a> [custom\_error\_responses](#input\_custom\_error\_responses) | Custom Error Responses.<br/><br/>**NOTE!** `response_page_path` attribute must begin with `/`. | <pre>list(object({<br/>    error_code            = number<br/>    response_code         = number<br/>    response_page_path    = string<br/>    error_caching_min_ttl = optional(number)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | CloudFront Distribution ID |
| <a name="output_arn"></a> [arn](#output\_arn) | CloudFront Distribution ARN |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | CloudFront Distribution Domain Name |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | CloudFront Distribution Hosted Zone ID |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
<!-- END_TF_DOCS -->