# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    base              = 1
    weight            = 100
  }

  dynamic "load_balancer" {
    for_each = { for c in var.containers: c.name => c if c.target_group_arn != null }

    content {
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
      container_name   = lookup(load_balancer.value, "name", null)
      container_port   = lookup(load_balancer.value, "port", null)
    }
  }

  ordered_placement_strategy { # https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_PlacementStrategy.html
    type  = lookup(var.ordered_placement_strategy, "type", null)
    field = lookup(var.ordered_placement_strategy, "field", null)
  }

  dynamic "network_configuration" {
    for_each = var.task_network_mode == "awsvpc" ? [1] : []

    content {
      security_groups = lookup(var.network_configuration, "security_groups", null)
      subnets         = lookup(var.network_configuration, "subnet_ids", null)
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ================================================
# ECS Task Definition:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "this" {
  # AWS Doc - Task definition parameters:
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  family             = var.name
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = var.task_network_mode
  cpu                = var.task_cpu
  memory             = var.task_memory

  container_definitions = jsonencode([for container in var.containers: {
    name                   = lookup(container, "name", "")
    essential              = lookup(container, "essential", true)
    # Image:
    image                  = lookup(container, "image", "")
    repositoryCredentials  = lookup(container, "private_registry_credentials", null) == null ? null : {
      credentialsParameter = aws_secretsmanager_secret.private_registry_credentials[container.name].arn
    }
    # Ports:
    portMappings           = [{
      containerPort      = lookup(container, "port", 0)
      containerPortRange = lookup(container, "port_range", null)
      hostPort           = lookup(container, "host_port", 0)
      hostPortRange      = lookup(container, "host_port_range", null)
      protocol           = "tcp"
    }]
    # Usage:
    cpu                    = lookup(container, "cpu", 0)
    gpu                    = lookup(container, "gpu", 0)
    memory                 = lookup(container, "memory", 0)
    memoryReservation      = lookup(container, "memory_reservation", 0)
    # Environment:
    environment            = [for v in lookup(container, "env", []): {
      name  = v.name
      value = v.value
    }]
    environmentFiles       = [for f in lookup(container, "env_files", []): {
      value = f.s3_object_arn
      type  = "s3"
    }]
    secrets                = [for s in lookup(container, "secret_vars", []): {
      name      = s.name
      valueFrom = s.secret_arn
    }]
    # Health Check:
    healthCheck            = lookup(container, "health_check", null) == null ? null : {
      command     = [ # https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html#API_HealthCheck_Contents
        "CMD-SHELL",
        "curl -f http://localhost:${container.port}${container.health_check.endpoint} || exit 1"
      ],
      interval    = lookup(container.health_check, "interval", 30),
      retries     = lookup(container.health_check, "retries", 3),
      timeout     = lookup(container.health_check, "timeout", 5),
      startPeriod = lookup(container.health_check, "start_period", 0)
    }

    hostname               = lookup(container, "hostname", null)
    extraHosts             = [for e in lookup(container, "etc_hosts", []): {
      hostname  = e.hostname,
      ipAddress = e.ip_address
    }]
    disableNetworking      = lookup(container, "disable_networking", false)

    volumesFrom    = []
    mountPoints    = []
    systemControls = []

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = data.aws_region.current.name,
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_task.name,
        "awslogs-stream-prefix" = container.name
      }
    }
  }])

  requires_compatibilities = []
  tags                     = var.task_tags != null ? var.task_tags : {}
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "ecs_task" {
  name              = "/ecs/task/${var.name}"
  retention_in_days = var.task_log_group_retention_days
}

# ================================================
# ECS Task/Exec Role:
# ================================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "ecs-task-${var.name}-"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "ecs-exec-${var.name}-"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "task_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ================================================
# AWS Doc - Private Registry Credentials:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
# ================================================
# https://www.terraform.io/docs/providers/aws/r/iam_role_policy
resource "aws_iam_role_policy" "private_registry_credentials" {
  count = length({ for c in var.containers: c.name => c if c.private_registry_credentials != null }) > 0 ? 1 : 0

  name_prefix = "private-registry-credentials-"
  role        = aws_iam_role.ecs_exec_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [{
      Effect: "Allow",
      Action: [
        "kms:Decrypt",
        "secretsmanager:GetSecretValue"
      ],
      Resource: [ for c in var.containers: aws_secretsmanager_secret.private_registry_credentials[c.name].arn
        if lookup(c, "private_registry_credentials", null) != null
      ]
    }]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
resource "aws_secretsmanager_secret" "private_registry_credentials" {
  for_each = { for c in var.containers: c.name => c if c.private_registry_credentials != null }

  name_prefix = "private-registry-credentials-"
  description = "Private Registry Credentials for Container Image: ${each.value.image}"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
resource "aws_secretsmanager_secret_version" "private_registry_credentials" {
  for_each = { for c in var.containers: c.name => c if c.private_registry_credentials != null }

  secret_id     = aws_secretsmanager_secret.private_registry_credentials[each.key].id
  secret_string = jsonencode(each.value.private_registry_credentials)
}
