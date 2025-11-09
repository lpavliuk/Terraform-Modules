# main.tf
module "rds-proxy" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_rds_proxy"

  name               = local.codename
  vpc_subnet_ids     = data.aws_subnets.selected.ids
  security_group_ids = [aws_security_group.this.id]

  target_rds_instance_name = module.rds_instance.name

  users = [
    {
      username = "UserName"
      password = ""
      iam_auth = true
    }
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG RDS Proxy - ${local.codename}"
  vpc_id      = data.aws_vpc.selected.id
}
