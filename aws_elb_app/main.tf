# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = var.is_private
  subnets            = var.subnet_ids
  security_groups    = concat(var.extra_sg_ids, [aws_security_group.this.id])

  enable_deletion_protection       = var.enable_deletion_protection
  preserve_host_header             = var.preserve_host_header
  xff_header_processing_mode       = var.xff_header_processing_mode
  enable_cross_zone_load_balancing = true # For application load balancer this feature is always enabled (true) and cannot be disabled
  enable_zonal_shift               = true

  dynamic "access_logs" {
    for_each = var.enable_logging ? [true] : []

    content {
      bucket  = aws_s3_bucket.alb_logs[0].id
      enabled = var.enable_logging ? true : false
    }
  }

  dynamic "connection_logs" {
    for_each = var.enable_logging ? [true] : []

    content {
      bucket  = aws_s3_bucket.alb_logs[0].id
      enabled = var.enable_logging ? true : false
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  dynamic "default_action" { # When HTTPS Listener is not created
    for_each = var.https_certificate_arn == null ? [true] : []

    content {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "503 Service Temporarily Unavailable"
        status_code  = "503"
      }
    }
  }

  dynamic "default_action" { # When HTTPS Listener is created
    for_each = var.https_certificate_arn == null ? [] : [true]

    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "https" {
  count = var.https_certificate_arn == null ? 0 : 1

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.https_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "503 Service Temporarily Unavailable"
      status_code  = "503"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG ELB - ${var.name}"
  vpc_id      = var.vpc_id
}

# =======================================================
# ALB Logging
# =======================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "allow_alb_logging" {
  count = var.enable_logging ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs[0].arn}/*"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "allow_elb_logging" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id
  policy = data.aws_iam_policy_document.allow_alb_logging[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "alb_logs" {
  count = var.enable_logging ? 1 : 0

  bucket_prefix = "alb-logs-${var.name}-"
  force_destroy = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "all_objects"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    expiration {
      days = var.logs_expiration_days != 0 ? var.logs_expiration_days : null
    }

    status = var.enable_logging ? "Enabled" : "Disabled"
  }
}
