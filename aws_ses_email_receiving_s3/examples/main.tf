# main.tf
module "email_receiving_registry" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_ses_email_receiving_s3"

  codename          = "registry"
  email_domain_name = "registry.${data.aws_route53_zone.public.name}"
  is_active         = true
  domain_zone_id    = data.aws_route53_zone.public.zone_id

  rules = [
    {
      enabled       = true,
      codename      = "files",
      emails_prefix = ["files@"],
      s3_bucket     = module.s3_bucket.name,
    }
  ]
}

