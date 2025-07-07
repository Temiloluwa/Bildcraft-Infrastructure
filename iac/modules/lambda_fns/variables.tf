variable "project_code" {
  type        = string
  description = "Project code or name for labeling resources."
}
variable "name_prefix" {
  type        = string
  description = "Prefix to be added to resource names."
}

variable "context" {
  type        = any
  description = "Context object for CloudPosse label module."
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function."
}

variable "lambda_handler" {
  type        = string
  description = "Handler for the Lambda function (e.g., index.handler)."
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime for the Lambda function (e.g., python3.12)."
}

variable "lambda_architectures" {
  type        = list(string)
  default     = ["x86_64"]
  description = "Instruction set architecture for the Lambda function (e.g., [\"x86_64\"], [\"arm64\"])."
}

variable "lambda_memory_size" {
  type        = number
  default     = 128
  description = "Amount of memory in MB for the Lambda function."
}

variable "lambda_reserved_concurrent_executions" {
  type        = number
  default     = -1
  description = "Number of reserved concurrent executions for the Lambda function. Use -1 for unreserved."
}

variable "lambda_role_name" {
  type        = string
  description = "Name of the IAM role for the Lambda function."
}

variable "lambda_s3_bucket" {
  type        = string
  default     = null
  description = "S3 bucket containing the Lambda deployment package."
}

variable "lambda_s3_key" {
  type        = string
  default     = null
  description = "S3 key for the Lambda deployment package."
}

variable "lambda_description" {
  type        = string
  default     = ""
  description = "Description of the Lambda function."
}

variable "lambda_timeout" {
  type        = number
  default     = 3
  description = "Timeout in seconds for the Lambda function."
}

variable "lambda_environment_variables" {
  type = object({
    variables = map(string)
  })
  default     = null
  description = "Object containing a map of environment variables for the Lambda function."
}

variable "lambda_iam_policy_statements" {
  type        = string
  description = "IAM policy document (JSON) to attach to the Lambda function as an inline policy."
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

variable "lambda_invoke_permissions" {
  type = list(object({
    principal  = string
    source_arn = string
  }))
  description = "IAM policy statements to allow external services (e.g., S3) to invoke the Lambda function."
  default     = []
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to apply to resources."
}
