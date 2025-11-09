# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy
resource "aws_db_proxy" "this" {
  name                   = var.name
  debug_logging          = false
  engine_family          = var.engine
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.this.arn
  vpc_security_group_ids = var.security_group_ids
  vpc_subnet_ids         = var.vpc_subnet_ids

  dynamic "auth" {
    for_each = { for e in var.users: e.username => e }

    content {
      auth_scheme = "SECRETS"
      description = "${auth.value.username} User"
      iam_auth    = auth.value.iam_auth ? "REQUIRED" : "DISABLED"
      secret_arn  = aws_secretsmanager_secret.user[auth.value.username].arn
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_default_target_group
resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    # init_query                   = "SET x=1, y=2"
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_target
resource "aws_db_proxy_target" "this" {
  db_instance_identifier = var.target_rds_instance_name
  db_cluster_identifier  = var.target_rds_cluster_name
  db_proxy_name          = aws_db_proxy.this.name
  target_group_name      = aws_db_proxy_default_target_group.this.name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_proxy_endpoint
resource "aws_db_proxy_endpoint" "read_only" {
  count = var.target_rds_cluster_name != null && var.create_read_only_endpoint ? 1 : 0

  db_proxy_name          = aws_db_proxy.this.name
  db_proxy_endpoint_name = "${var.name}-read-only"
  vpc_security_group_ids = var.security_group_ids
  vpc_subnet_ids         = var.vpc_subnet_ids
  target_role            = "READ_ONLY"
}

# =============================
# IAM Role for the DB Proxy
# =============================
resource "aws_iam_role" "this" {
  name_prefix = "${var.name}-proxy-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "permissions" {
  depends_on = [aws_secretsmanager_secret.user]

  name_prefix = "proxy-permissions-"
  role        = aws_iam_role.this.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": [for user in var.users: aws_secretsmanager_secret.user[user.username].arn]
      },
      # {
      #   "Effect": "Allow",
      #   "Action": "kms:Decrypt",
      #   "Resource": [for user in var.users: lookup(user, "kms_key_id", null)]
      #   "Condition": {
      #     "StringEquals": {
      #       "kms:ViaService": "secretsmanager.${data.aws_region.current.region}.amazonaws.com"
      #     }
      #   }
      # }
    ]
  })
}

# =============================
# Users Secrets:
# =============================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
resource "aws_secretsmanager_secret" "user" {
  for_each = { for e in var.users: e.username => e }

  name_prefix = "rds-proxy-${var.name}-DBUser-${each.value.username}-"
  # kms_key_id = lookup(each.value, "kms_key_id", null)
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
resource "aws_secretsmanager_secret_version" "user" {
  for_each = { for e in var.users: e.username => e }

  secret_id = aws_secretsmanager_secret.user[each.value.username].id
  secret_string = jsonencode({
    username = each.value.username
    password = each.value.password
  })
}
