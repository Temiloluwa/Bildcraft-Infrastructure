variable "context" {
  description = "The global context object for label modules."
  type        = any
}

variable "project_code" {
  description = "The project code used for naming resources."
  type        = string
}

variable "name_prefix" {
  description = "The prefix to be added to resource names."
  type        = string
}

variable "event_notification_details" {
  description = "Event notification configuration for the S3 bucket."
  type        = any
  default = {
    "enabled" : false
  }
}

variable "uploads_cors_configuration" {
  description = "CORS configuration for the uploads S3 bucket."
  type        = any
  default     = []
}

variable "results_cors_configuration" {
  description = "CORS configuration for the results S3 bucket."
  type        = any
  default     = []
}
