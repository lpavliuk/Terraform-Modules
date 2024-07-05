# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "this" {
  ami                     = var.ami
  instance_type           = var.type
  subnet_id               = var.subnet_id
  iam_instance_profile    = aws_iam_instance_profile.this_instance.name

  vpc_security_group_ids  = concat([var.security_group_id], var.extra_sg_ids)

  user_data   = var.user_data

  //noinspection HCLUnknownBlockType
  private_dns_name_options {
    enable_resource_name_dns_a_record = true
  }

  tags        = { Name = var.name }
  volume_tags = { Name = var.name }

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "this" {
  count = var.has_elastic_ip ? 1 : 0

  domain                    = "vpc"
  instance                  = aws_instance.this.id
  associate_with_private_ip = aws_instance.this.private_ip

  tags = { Name = var.name }
}

# ================================================
# Instance's IAM Role:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "this_instance" {
  name_prefix = "ec2-"
  role = aws_iam_role.this_instance.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "this_instance" {
  name_prefix        = "ec2-role-"
  description        = "EC2 - ${var.name}"
  assume_role_policy = data.aws_iam_policy_document.this_instance.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "this_instance" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

