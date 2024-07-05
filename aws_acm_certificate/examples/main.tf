# main.tf
resource "aws_route53_zone" "this" {
  name = local.domain_name
}

module "acm_certificate" {
  source = "../../../../modules/aws_acm_certificate"

  domain_name = aws_route53_zone.this.name
  zone_id     = aws_route53_zone.this.zone_id

  subject_alternative_names = [
    "*.subdomain1.${aws_route53_zone.this.name}",
    "*.subdomain2.${aws_route53_zone.this.name}"
  ]
}
