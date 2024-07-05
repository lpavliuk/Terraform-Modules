# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider
resource "aws_ecs_capacity_provider" "this" {
  name = "ec2-ecs-${var.name}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    base              = 1
    weight            = 100
  }
}

# ================================================
# Auto Scaling Group:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "ecs" {
  name_prefix               = "ecs-${var.name}-cluster-"
  vpc_zone_identifier       = var.subnet_ids
  min_size                  = var.node_min_count
  max_size                  = var.node_max_count != null ? var.node_max_count : var.node_min_count
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_node.id
    version = aws_launch_template.ecs_node.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      auto_rollback          = true
    }
  }

  tag {
    key                 = "Name"
    value               = "ecs-${var.name}-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged" # Required for ECS Capacity Provider to manage the ASG
    value               = aws_ecs_cluster.this.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.node_extra_tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "ecs_node" {
  name_prefix            = "ecs-node-${var.name}-"
  image_id               = var.node_image_id
  instance_type          = var.node_instance_type
  vpc_security_group_ids = var.node_security_group_ids

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_node.arn
  }

  monitoring {
    enabled = true
  }

  # [!] It is required to pass ECS cluster name, so AWS can register EC2 instance as node of ECS cluster.
  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

# ================================================
# EC2 Node Role:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "ecs-${var.name}-node-"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ecs_node" {
  name_prefix        = "ecs-${var.name}-node-"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_role_policy.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "ecs_node_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "this_iam_role" {
  role       = aws_iam_role.ecs_node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
