# main.tf
module "openid_connect" {
  source = "../../../../modules/aws_iam_openid_connect"

  client_url                  = "https://example.gitlab.com"
  client_id                   = "example.gitlab.com"
  client_tls_sha1_fingerprint = data.tls_certificate.client.certificates[0].sha1_fingerprint
  match_values                = [
    "https://example.gitlab.com/frontend-group/fe-webserver:ref_type:branch:ref:develop"
  ]
}

# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate
data "tls_certificate" "client" {
  url = "tls://example.gitlab.com:443"
}
