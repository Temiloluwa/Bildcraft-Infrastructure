module "lambda_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  name       = var.name_prefix
  attributes = [var.project_code]

  label_order = ["attributes", "name"]
  context     = var.context
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${module.lambda_label.id}-${var.lambda_role_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = module.lambda_label.tags
}

# Inline policy using aws_iam_role_policy
resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${module.lambda_label.id}-${var.lambda_role_name}-inline-policy"
  role   = aws_iam_role.lambda.id
  policy = var.lambda_iam_policy_statements
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "processing" {
  function_name = "${module.lambda_label.id}-${var.lambda_function_name}"
  description   = var.lambda_description
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.lambda_s3_key

  architectures                  = var.lambda_architectures
  memory_size                    = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  timeout                        = var.lambda_timeout
  role                           = aws_iam_role.lambda.arn

  environment {
    variables = var.lambda_environment_variables != null ? var.lambda_environment_variables.variables : {}
  }

  tags = module.lambda_label.tags
}

