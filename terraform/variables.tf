data "aws_caller_identity" "me" {}

variable "project_name" {
  description = "just the project name"
  type        = string
  default     = "rust-brainrot-filter"
}

variable "proxy_ip_cidr" {
  description = "should be the whitelist for IPs accessing this instance"
  type = string
}