terraform {
  required_providers {
    aws = {
      version = "~> 6.15"
      source  = "hashicorp/aws"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }

  }
  required_version = "~> 1.10"
}
