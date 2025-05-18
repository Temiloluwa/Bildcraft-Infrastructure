output "lambda_function_arn" {
  value = module.processing_lambda.arn
}

output "lambda_function_name" {
  value = module.processing_lambda.function_name
}

output "lambda_function_invoke_arn" {
  value = module.processing_lambda.invoke_arn
}
