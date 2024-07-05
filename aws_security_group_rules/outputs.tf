output "security_group_id" {
  value       = var.security_group_id
  sensitive   = false
  description = "Security Group ID"
}

#output "inbound_rules" {
#  value       = []
#  sensitive   = false
#  description = ""
#}
#
#output "outbound_rules" {
#  value       = []
#  sensitive   = false
#  description = ""
#}
