variable "project_code" {
  description = "The project code used for naming resources."
  type        = string
}

variable "name_prefix" {
  description = "The prefix to be added to resource names."
  type        = string
}

variable "context" {
  description = "The global context object for label modules."
  type        = any
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue."
  type        = number
  default     = 30
}

variable "fifo_queue" {
  description = "Boolean to create a FIFO queue."
  type        = bool
  default     = false
}

variable "policy" {
  description = "The JSON policy for the SQS queue."
  type        = string
  default     = null
}
