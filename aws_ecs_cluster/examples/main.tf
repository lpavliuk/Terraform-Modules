# main.tf
module "ecs_cluster" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_ecs_cluster"

  name        = "example"
  subnet_ids  = var.subnet_group_subnets_ids

  node_image_id           = data.aws_ssm_parameter.ecs_node_ami.value
  node_instance_type      = "t4g.micro"
  node_min_count          = 2
  node_security_group_ids = [ aws_security_group.ecs_node.id ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "ecs_node" {
  name_prefix = "ecs-node-example-"
  vpc_id      = var.vpc_id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter
data "aws_ssm_parameter" "ecs_node_ami" {
  # Retrieving Amazon ECS-Optimized AMI metadata:
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended/image_id"
}
