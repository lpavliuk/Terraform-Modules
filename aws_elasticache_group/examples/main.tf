# main.tf
module "elasticache_group" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_elasticache_group"

  name                        = local.codename
  num_cache_cluster           = 1
  node_type                   = "cache.t4g.micro"

  engine                      = "redis"
  vpc_id                      = data.aws_vpc.selected.id
  elasticache_subnet_group_id = aws_elasticache_subnet_group.this.id
}

# https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/elasticache_subnet_group
resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.codename}-cluster"
  subnet_ids = data.aws_subnets.elasticache.ids
}
