provider "aws" {
  region = "ap-southeast-2"

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform-local"
    }
  }
}