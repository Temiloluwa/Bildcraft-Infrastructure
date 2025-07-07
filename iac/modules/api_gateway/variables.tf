variable "project_code" {
  description = "Project code or name for labeling resources. Used as a prefix for all resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to be added to resource names. Used for grouping related resources."
  type        = string
}

variable "context" {
  description = "Context object for CloudPosse label module."
  type        = any
}

variable "openapi_config" {
  description = "OpenAPI configuration for the API Gateway. Should be passed from the parent module."
  type        = any
}

variable "api_key_name" {
  description = "Name for the API Gateway API key."
  type        = string
  default     = null
}
