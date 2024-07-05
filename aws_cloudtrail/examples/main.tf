# main.tf
locals {
  codename = "account-trail"
}

module "s3_bucket" {
  source    = "../../../../modules/aws_s3_bucket"

  bucket_prefix                      = "${local.codename}-"
  enable_versioning                  = true
  current_version_expiration_days    = 14
  noncurrent_version_expiration_days = 1

  force_destroy = true
}

module "cloudtrail" {
  source    = "../../../../modules/aws_cloudtrail"

  name                          = local.codename
  s3_bucket_name                = module.s3_bucket.name
  is_organization_trail         = false
  is_multi_region_trail         = true
  include_global_service_events = true
}
