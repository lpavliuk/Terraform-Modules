# main.tf
module "waf" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_waf"

  name = "example-codename"
}
