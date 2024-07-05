# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.enable_image_tag_immutability ? "IMMUTABLE" : "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key = aws_kms_key.ecr_kms.arn
  }

  image_scanning_configuration {
    scan_on_push = var.enable_scanning_on_push
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "ecr_kms" {
  enable_key_rotation = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
resource "aws_ecr_repository_policy" "example" {
  count = var.repository_policy_json != null ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy_json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
resource "aws_ecr_lifecycle_policy" "this" {
  count = var.lifecycle_policy_json != null ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy_json
}
