# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system
resource "aws_efs_file_system" "this" {
  creation_token   = var.name
  encrypted        = var.is_encrypted
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  tags = { Name = var.name }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target
resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.key
  security_groups = [aws_security_group.this.id]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG EFS - ${var.name}"
  vpc_id      = var.vpc_id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = var.enable_backup ? "ENABLED" : "DISABLED"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_replication_configuration
resource "aws_efs_replication_configuration" "replica" {
  count = var.replica_region != "" ? 1 : 0

  source_file_system_id = aws_efs_file_system.this.id

  destination {
    region = var.replica_region
  }
}
