variable "name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Name of the CloudFront distribution.

    **NOTE!** Must contain alphanumeric characters or hyphens (`-`).
  EOF

  validation {
    condition     = can(regex(
      "[0-9a-zA-Z$_]+",
      var.name
    ))
    error_message = <<-EOF
      Must contain alphanumeric characters or hyphens (-).
    EOF
  }
}

variable "alternate_domain_names" {
  type        = list(string)
  default     = []
  description = "Alternate Domain Names (CNAME) of the distribution"
}

variable "acm_certificate_arn" {
  type        = string
  default     = null
  description = <<-EOF
    ARN of the ACM Certificate for `alternate_domain_names`.

    **NOTE!** It is required if `alternate_domain_name` is defined.
    **NOTE!** The ACM certificate must be in `US-EAST-1` region!
  EOF
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default Root Object of the CloudFront"
}

variable "http_version" {
  type        = string
  default     = "http2and3"
  description = <<-EOF
    Maximum HTTP version to support on the CloudFront. [Available values.](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#http_version)
  EOF
}

variable "is_ipv6_enabled" {
  type        = bool
  default     = false
  description = "Enable IPv6 support"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_All"
  description = <<-EOF
    CloudFront edge locations are grouped into geographic regions, and AWS grouped regions into price classes.

    [Choosing the price class for a CloudFront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html)

    **NOTE!** Australia is only in `PriceClass_All`.
  EOF
}

variable "geo_restrictions" {
  type        = object({
    restriction_type = string
    locations        = list(string)
  })
  default     = null
  description = <<-EOF
    Geo Location Restrictions for the distribution.

    Available `restriction_type` values:
      - `"whitelist"`
      - `"blacklist"`

    `locations` values must be defined in [ISO 3166-1-alpha-2 code](http://www.iso.org/iso/country_codes/iso_3166_code_lists/country_names_and_code_elements.htm) format.
    e.g. `["AU", "NZ", "GB"]`

    [Browse Country Codes](https://www.iso.org/obp/ui/#search)
  EOF
}

variable "origins" {
  type        = list(object({
    id                   = string
    domain_name          = string
    access_control_id    = optional(string)
    custom_origin_config = optional(object({
      http_port         = optional(number, 80)
      https_port        = optional(number, 443)
      protocol_policy   = string
      ssl_protocols     = optional(list(string), ["TLSv1.2"])
      keepalive_timeout = optional(number, 5)
      read_timeout      = optional(number, 30)
    }))
    custom_headers       = optional(list(object({
      name  = string
      value = string
    })))
  }))
  nullable    = false
  description = "Origins of the distribution"
}

variable "cache_behaviors" {
  type        = list(object({
    name                       = string
    default                    = bool
    path_pattern               = optional(string, "*")
    target_origin_id           = string
    allowed_methods            = optional(list(string), ["GET", "HEAD"])
    cache_methods              = optional(list(string), ["GET", "HEAD"])
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    default_ttl                = optional(number, 2592000) # 30 days
    max_ttl                    = optional(number, 2592000) # 30 days
    min_ttl                    = optional(number, 5)       # 5 mins
    cache_cookies              = optional(object({
      behaviour = string
      items     = optional(list(string))
    }))
    cache_headers              = optional(object({
      behaviour = string
      items     = optional(list(string))
    }))
    cache_query_strings        = optional(object({
      behaviour = string
      items     = optional(list(string))
    }))
    encoding_gzip              = optional(bool, true)
    encoding_brotli            = optional(bool, true)
    field_level_encryption_id  = optional(string)
    response_headers_policy_id = optional(string)
    origin_request_policy_id   = optional(string)
    functions                  = optional(list(object({
      event_type   = string
      is_lambda    = bool
      function_arn = string
      include_body = optional(bool, false)
    })), [])
  }))
  default     = []
  description = <<-EOF
    Cache Behaviours of the distribution.

    **NOTE!** It is not allowed to have more than one `default` behaviour.

    **NOTE!** `path_pattern` is required if a behaviour is not default, otherwise it is ignored.

    [Available values for `viewer_protocol_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#viewer_protocol_policy)

    ### `functions` config:
    **NOTE!** You can associate a single function per `event_type`.

    Available values for `event_type`:
      - `"viewer-request"`
      - `"viewer-response"`
      - `"origin-request"`  - is ignored if `is_lambda` is `false`
      - `"origin-response"` - is ignored if `is_lambda` is `false`

    `function_arn` is an ARN of the CloudFront or Lambda Function.
    `include_body` is ignored if `is_lambda` is `false`
  EOF

  validation {
    condition     = length([for e in var.cache_behaviors: e.name if e.default == true]) < 2
    error_message = "It is not allowed to have more than one `default` behaviour!"
  }
}

variable "custom_error_responses" {
  type        = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = optional(number)
  }))
  default     = []
  description = <<-EOF
    Custom Error Responses.

    **NOTE!** `response_page_path` attribute must begin with `/`.
  EOF
}
