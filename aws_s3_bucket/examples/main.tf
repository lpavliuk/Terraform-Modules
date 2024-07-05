# main.tf
module "s3_bucket" {
  source    = "../../../../modules/aws_s3_bucket"

  bucket_prefix                      = "bucket-name-"
  enable_versioning                  = true
  create_iam_policies                = false

  noncurrent_version_expiration_days = 14
}
