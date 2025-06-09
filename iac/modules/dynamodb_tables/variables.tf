variable "project_code" {
  description = "Project code for resource naming."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "context" {
  description = "Context object for tagging and other purposes."
  type        = any
}

variable "hash_key" {
  description = "Hash key attribute name."
  type        = string
}

variable "range_key" {
  description = "Range key attribute name (optional)."
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions."
  type = list(object({
    name = string
    type = string
  }))
}
