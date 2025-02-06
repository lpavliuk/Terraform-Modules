variable "codename" {
  type        = string
  nullable    = false
  description = "Codename for the rule set"
}

variable "is_active" {
  type        = bool
  nullable    = true
  description = "Whether the rule set is active or not"
}

variable "domain_zone_id" {
  type        = string
  nullable    = false
  description = "Domain zone ID"
}

variable "email_domain_name" {
  type        = string
  nullable    = false
  description = "Email domain name"
}

variable "rules" {
  type        = list(object({
    enabled          = optional(bool, true)
    codename         = string
    emails_prefix    = list(string)
    scan             = optional(bool, true)
    s3_bucket        = string
    s3_bucket_prefix = optional(string, "")
  }))
  nullable    = false
  description = "List of rules"
}
