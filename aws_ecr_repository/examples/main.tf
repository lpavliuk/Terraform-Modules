# main.tf
module "ecr_repository" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_ecr_repository"

  name                          = "example-repo"
  enable_image_tag_immutability = true
  enable_scanning_on_push       = true
  repository_policy_json        = data.aws_iam_policy_document.ecr_repository_policy.json
  lifecycle_policy_rules        = [
    {
      description     = "Expire untagged images older than 14 days"
      tag_status      = "untagged",
      count_type      = "sinceImagePushed",
      count_unit      = "days",
      count_number    = 14
    }
  ]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "ecr_repository_policy" {
  statement {
    sid    = "new policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}
