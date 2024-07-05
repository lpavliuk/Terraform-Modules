# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "this" {
  url             = var.client_url
  client_id_list  = [var.client_id]
  thumbprint_list = [var.client_tls_sha1_fingerprint]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.this.url}:${var.match_field}"
      values   = var.match_values
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "client_role" {
  name_prefix         = "client-openid-connect-"
  description         = "Client URL: ${var.client_url}, Client ID: ${var.client_id}"
  assume_role_policy  = data.aws_iam_policy_document.assume-role-policy.json
}

