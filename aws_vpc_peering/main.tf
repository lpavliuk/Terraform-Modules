# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection
resource "aws_vpc_peering_connection" "this" {
  provider = aws.requester

  vpc_id        = var.requester_vpc.id
  peer_owner_id = var.accepter_vpc.account_id
  peer_vpc_id   = var.accepter_vpc.id
  peer_region   = var.accepter_vpc.account_id != var.requester_vpc.account_id ? var.accepter_vpc.region : ""
  auto_accept   = var.accepter_vpc.account_id != var.requester_vpc.account_id ? false : true

  tags = {
    Name = "${var.accepter_vpc.name}-vpc"
    Side = "Requester"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "requester_vpc_route" {
  provider = aws.requester
  for_each = toset(var.requester_vpc.route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.accepter_vpc.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# ============================================
# Accepter Resources:
# ============================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter
resource "aws_vpc_peering_connection_accepter" "this" {
  provider = aws.accepter
  count    = var.accepter_vpc.account_id != var.requester_vpc.account_id ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true

  tags = {
    Name = "${var.requester_vpc.name}-vpc"
    Side = "Accepter"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "accepter_vpc_route" {
  provider = aws.accepter
  for_each = toset(var.accepter_vpc.route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.requester_vpc.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# ============================================
# VPC Hosted Zone: Requester => Accepter
# ============================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization
resource "aws_route53_vpc_association_authorization" "accepter_auth" {
  provider = aws.requester
  for_each = toset(var.requester_vpc.vpc_domain_zone_ids)

  vpc_id  = var.accepter_vpc.id
  zone_id = each.key
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization
resource "aws_route53_zone_association" "accepter_connect" {
  provider = aws.accepter
  for_each = toset(var.requester_vpc.vpc_domain_zone_ids)

  vpc_id  = var.accepter_vpc.id
  zone_id = each.key

  depends_on = [aws_route53_vpc_association_authorization.accepter_auth]
}

# ============================================
# VPC Hosted Zone: Accepter => Requester
# ============================================
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization
resource "aws_route53_vpc_association_authorization" "requester_auth" {
  provider = aws.accepter
  for_each = toset(var.accepter_vpc.vpc_domain_zone_ids)

  vpc_id  = var.requester_vpc.id
  zone_id = each.key
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization
resource "aws_route53_zone_association" "requester_connect" {
  provider = aws.requester
  for_each = toset(var.accepter_vpc.vpc_domain_zone_ids)

  vpc_id  = var.requester_vpc.id
  zone_id = each.key

  depends_on = [aws_route53_vpc_association_authorization.requester_auth]
}
