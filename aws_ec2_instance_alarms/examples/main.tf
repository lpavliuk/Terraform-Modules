# main.tf
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "this" {
  name        = "SG EC2 - ${local.name}"
  vpc_id      = local.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

module "ec2_instance" {
  source = "../../../../modules/aws_ec2_instance"

  name              = local.name
  type              = local.instance_type
  ami               = local.ami_id
  vpc_id            = local.vpc_id
  subnet_id         = local.subnet_group_subnet_id
  has_elastic_ip    = false
  security_group_id = aws_security_group.this.id
  extra_sg_ids      = [ local.vpc_sg_id ]
}

module "ec2_instance_alarms" {
  source = "../../../../modules/aws_ec2_instance_alarms"

  name_prefix           = "${local.zone}-"
  ec2_instance_id       = module.ec2_instance.id
  ec2_instance_codename = local.codename
  sns_topic_arns        = local.notification_sns_topic_arn
}
