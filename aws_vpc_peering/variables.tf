variable "requester_vpc" {
  type        = object({
    id                  = string
    name                = string
    account_id          = string
    region              = string
    cidr                = string
    route_table_ids     = list(string)
    vpc_domain_zone_ids = optional(list(string), [])
  })
  nullable    = false
  description = "VPC Details of the Requester"
}

variable "accepter_vpc" {
  type        = object({
    id                  = string
    name                = string
    account_id          = string
    region              = string
    cidr                = string
    route_table_ids     = list(string)
    vpc_domain_zone_ids = optional(list(string), [])
  })
  nullable    = false
  description = "VPC Details of the Accepter"
}
