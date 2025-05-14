variable "context" {
  description = "The global context object for label modules."
  type        = any
}

variable "project_code" {
  description = "The project code used for naming resources."
  type        = string
}

variable "prefix" {
  description = "The prefix to be added to resource names."
  type        = string
}

variable "privileged_principal_arns" {
  description = "List of ARNs for privileged principals with access to the S3 bucket."
  type        = list
  default     = []
}

variable "privileged_principal_actions" {
  description = "List of S3 actions allowed for privileged principals."
  type        = list
  default     = []
}

variable "event_notification_details" {
  description = "Event notification configuration for the S3 bucket."
  type        = any
  default     = {
  "enabled": false
}
}

variable "cors_configuration" {
  description = "CORS configuration for the S3 bucket."
  type        = any
  default     = []
}
