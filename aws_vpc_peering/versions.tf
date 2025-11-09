terraform {
  required_version = "< 2.0.0, >= 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 7.0, >= 5.22"
      configuration_aliases = [
        aws.requester,
        aws.accepter
      ]
    }
  }
}
