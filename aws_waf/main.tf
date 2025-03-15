# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl
resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = var.scope

  tags = {
    Name = var.name
  }

  dynamic "default_action" {
    for_each = var.default_action == "Allow" ? [var.default_action] : []
    content {
      allow {}
    }
  }

  dynamic "default_action" {
    for_each = var.default_action == "Block" ? [var.default_action] : []
    content {
      block {
        custom_response {
          response_code = 403
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      none {
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

#        rule_action_override {
#          action_to_use {
#            allow {}
#          }
#
#          name = "NoUserAgent_HEADER"
#        }

#        scope_down_statement {
#          geo_match_statement {
#            country_codes = ["AU", "GB", "US", "NZ"]
#          }
#        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "X2_AWSRateBasedRuleDomesticDOS"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["AU", "GB", "US", "NZ"]
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "X2_AWSRateBasedRuleDomesticDOS"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "X2_AWSRateBasedRuleGlobalDOS"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 500
        aggregate_key_type = "IP"

        scope_down_statement {
          not_statement {
            statement {
              geo_match_statement {
                country_codes = ["AU", "GB", "US", "NZ"]
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "X2_AWSRateBasedRuleGlobalDOS"
      sampled_requests_enabled   = true
    }
  }

}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [aws_cloudwatch_log_group.this.arn]
  resource_arn            = aws_wafv2_web_acl.this.arn
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "this" {
  # NOTE! Required to be named aws-waf-logs-<name> for WAF to work
  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.logs_retention_in_days
}
