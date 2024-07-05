# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition
data "aws_partition" "current" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}
