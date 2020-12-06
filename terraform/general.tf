# General AWS Provider
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}


/*

# CloudFront Certificates
provider "aws" {
  alias = "acm"
  region = "us-east-1"
}

# Remote State (S3)
terraform {
  backend "s3" {
    bucket = "..."
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

*/