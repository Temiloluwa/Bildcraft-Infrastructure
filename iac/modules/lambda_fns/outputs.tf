output "lambda_function_arn" {
  value = aws_lambda_function.processing.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.processing.function_name
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.processing.invoke_arn
}
