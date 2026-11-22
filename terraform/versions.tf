terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.10"

  backend "s3" {
    key = "proxy/terraform.tfstate"
    region = "ap-southeast-2"
    encrypt = true
    use_lockfile = true
  }
}
