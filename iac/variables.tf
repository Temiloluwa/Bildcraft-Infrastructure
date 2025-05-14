variable "region" {
  description = "AWS region to deploy resources."
  type        = string
}

variable "environment" {
  description = "The environment/stage for resource naming (e.g., dev, prod)."
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
}