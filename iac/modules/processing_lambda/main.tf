module "lambda_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  name       = var.name_prefix
  attributes = [var.project_code]

  label_order = ["attributes", "name"]
  context     = var.context
}

module "processing_lambda" {
  source      = "cloudposse/lambda-function/aws"
  version     = "0.6.1"
  description = var.lambda_description
  tags        = module.lambda_label.tags

  function_name                  = "${module.lambda_label.id}-${var.lambda_function_name}"
  handler                        = var.lambda_handler
  runtime                        = var.lambda_runtime
  architectures                  = var.lambda_architectures
  memory_size                    = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_excurrentions
  role_name                      = "${module.lambda_label.id}-${var.lambda_role_name}"
  s3_bucket                      = var.lambda_s3_bucket
  s3_key                         = var.lambda_s3_key
  timeout                        = var.lambda_timeout
  lambda_environment             = var.lambda_environment_variables
  inline_iam_policy              = var.lambda_iam_policy_statements
}


