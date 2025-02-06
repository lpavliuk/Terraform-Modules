terraform {
  required_version = "< 2.0.0, >= 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0, >= 5.72"
    }
  }
}
