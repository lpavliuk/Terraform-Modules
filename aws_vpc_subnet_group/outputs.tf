output "name" {
  value       = var.name
  sensitive   = false
  description = "Subnet Group Name"
}

output "cidr" {
  value       = var.cidr
  sensitive   = false
  description = "Subnet Group CIDR Block"
}

output "vpc_id" {
  value       = var.vpc_id
  sensitive   = false
  description = "VPC ID"
}

output "subnets" {
  value       = [for s in aws_subnet.subnets : {
    id: s.id
    name: try(s.tags["Name"], "")
    availability_zone: s.availability_zone
    cidr: s.cidr_block
    route_table_id: aws_route_table.zone[s.availability_zone].id
  }]
  sensitive   = false
  description = "List of subnets in the Subnet Group"
}

output "network_acl_id" {
  value       = aws_network_acl.this_subnet.id
  sensitive   = false
  description = "Network ACL ID"
}
