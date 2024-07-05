variable "domain_name" {
  type        = string
  nullable    = false
  description = "Public domain name. Must have a hosted zone in AWS Route 53"
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "SANs in the issued certificate. **NOTE!** The `domain_name` is already included"
}

variable "zone_id" {
  type        = string
  nullable    = false
  description = "Zone ID of the Route 53 Hosted Zone. Used for validation"
}
