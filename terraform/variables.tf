data "aws_caller_identity" "me" {}

variable "project_name" {
  description = "just the project name"
  type        = string
  default     = "rust-brainrot-filter"
}