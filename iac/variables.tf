variable "environment" {
  description = "The environment/stage for resource naming (e.g., dev, prod)."
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
}

variable "account_id" {
  description = "The AWS Account ID allowed to use this provider."
  type        = string
}
