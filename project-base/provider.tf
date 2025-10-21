terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region_default
}

#provider "aws" {
#  alias = "sp"
#  region = "sa-east-1"
#}
