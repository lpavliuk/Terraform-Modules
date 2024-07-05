locals {
  s3_bucket_name = "nlb-logs-${var.name}"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "network"
  internal           = var.is_private
  subnets            = var.subnet_ids
  security_groups    = concat(var.extra_sg_ids, [aws_security_group.this.id])

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone

  access_logs {
    bucket  = local.s3_bucket_name
    enabled = var.enable_logging ? true : false
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG ELB - ${var.name}"
  vpc_id      = var.vpc_id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "lb_logs" {
  count = var.enable_logging ? 1 : 0

  bucket        = local.s3_bucket_name
  force_destroy = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "allow_lb_logging" {
  count = var.enable_logging ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.lb_logs[0].arn}/AWSLogs/*"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket_policy" "allow_elb_logging" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.lb_logs[0].id
  policy = data.aws_iam_policy_document.allow_lb_logging[0].json
}

