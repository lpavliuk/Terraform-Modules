# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group
resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${var.name}-cluster"
  description                = "ElastiCache Cluster for ${var.name}"
  num_cache_clusters         = var.num_cache_cluster
  automatic_failover_enabled = var.num_cache_cluster > 1 ? true : false
  multi_az_enabled           = var.num_cache_cluster > 1 ? true : false
  auth_token                 = var.auth_token != "" ? var.auth_token : null
  auth_token_update_strategy = var.auth_token != "" ? var.auth_token_update_strategy : null

  node_type                  = var.node_type
  port                       = var.port
  engine                     = var.engine
  engine_version             = var.engine_version
  parameter_group_name       = var.parameter_group_name
  subnet_group_name          = var.elasticache_subnet_group_id
  security_group_ids         = [aws_security_group.this.id]
  maintenance_window         = var.maintenance_window_utc_period
  auto_minor_version_upgrade = var.enable_auto_minor_version_upgrade
  at_rest_encryption_enabled = var.enable_at_rest_encryption
  transit_encryption_enabled = var.enable_transit_encryption
  apply_immediately          = true

  user_group_ids             = [aws_elasticache_user_group.this.user_group_id] # Allowed only ONE!

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.this.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.this.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "engine-log"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG ElastiCache - ${var.name}"
  vpc_id      = var.vpc_id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/elasticache/${var.name}"
  retention_in_days = var.cloudwatch_logs_retention_period_days
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user_group
resource "aws_elasticache_user_group" "this" {
  engine        = var.engine
  user_group_id = var.name
  user_ids      = [aws_elasticache_user.default.user_id] # Requires to have a default user

  lifecycle {
    ignore_changes = [user_ids]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user
resource "aws_elasticache_user" "default" {
  user_id              = "${var.name}-default"
  user_name            = "default"
  access_string        = "on ~app::* -@all" # https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Clusters.RBAC.html
  engine               = var.engine
  no_password_required = true
}

