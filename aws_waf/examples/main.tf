# main.tf
module "waf" {
  source = "../../../../modules/aws_waf"

  name = "example-codename"
}
