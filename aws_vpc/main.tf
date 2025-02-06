# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "this" {
  cidr_block = var.cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "this_vpc" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-zone"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list
resource "aws_ec2_managed_prefix_list" "this_vpc" {
  name           = "Intranet (${var.name} VPC)"
  address_family = "IPv4"
  max_entries    = 10
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry
resource "aws_ec2_managed_prefix_list_entry" "entry" {
  prefix_list_id = aws_ec2_managed_prefix_list.this_vpc.id
  cidr           = aws_vpc.this.cidr_block
  description    = "${var.name} VPC"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this_vpc" {
  name        = "SG VPC - ${var.name}"
  vpc_id      = aws_vpc.this.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
resource "aws_route53_zone" "this" {
  count = var.domain_zone_name != null ? 1 : 0

  name = var.domain_zone_name

  vpc {
    vpc_id = aws_vpc.this.id
  }

  lifecycle {
    ignore_changes = [vpc] # as VPC Peering attaches new VPC IDs to the Hosted Zone
  }
}

# =======================================================
# ALB Logging
# =======================================================
# https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/flow_log
resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/aws_cloudwatch_log_group
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_logs_retention_in_days
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "assume_role_vpc_logs" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name_prefix        = "vpc-${var.name}-flow-logs-"
  assume_role_policy = data.aws_iam_policy_document.assume_role_vpc_logs[0].json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name_prefix = "vpc-${var.name}-flow-logs-"
  role        = aws_iam_role.flow_logs[0].id
  policy      = data.aws_iam_policy_document.flow_logs[0].json
}
