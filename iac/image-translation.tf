# Image processing lambda
module "image_translation_lambda" {
  source                                = "./modules/lambda_fns"
  project_code                          = "blc"
  name_prefix                           = "image-translation"
  lambda_description                    = "BildCraft Image translation Lambda function"
  context                               = module.global.context
  lambda_function_name                  = "processor-fn"
  lambda_handler                        = "lambda_entrypoint.lambda_handler"
  lambda_runtime                        = "python3.12"
  lambda_memory_size                    = 256
  lambda_reserved_concurrent_executions = 3
  lambda_role_name                      = "processor-role"
  lambda_s3_bucket                      = module.lambda_source_codes.bucket_id
  lambda_s3_key                         = "blc/image-translation/image-translation-source-codes.zip"
  lambda_timeout                        = 300
  lambda_environment_variables = {
    variables = {
      "UPLOADS_BUCKET"            = module.image_translation_s3.uploads_s3_bucket
      "RESULTS_BUCKET"            = module.image_translation_s3.results_s3_bucket
      "UPLOADS_QUEUE_URL"         = module.image_translation_sqs.queue_url
      "STATUS_TABLE_NAME"         = module.image_translation_status_table.table_name
      "OCR_MODEL_API_KEY"         = data.aws_ssm_parameter.ocr_model_api_key.value
      "TRANSLATION_MODEL_API_KEY" = data.aws_ssm_parameter.translation_model_api_key.value
    }
  }

  lambda_iam_policy_statements = data.aws_iam_policy_document.image_translation_lambda_inline.json
}

# S3 buckets (uploads and results handled in one module)
module "image_translation_s3" {
  source       = "./modules/s3_buckets"
  project_code = "blc"
  name_prefix  = "image-translation"
  context      = module.global.context

  event_notification_details = {
    enabled = true
    queue_list = [
      {
        queue_arn     = module.image_translation_sqs.queue_arn
        events        = ["s3:ObjectCreated:*"]
        filter_prefix = ""
        filter_suffix = ""
      }
    ]
  }

  uploads_cors_configuration = [{
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }]

  results_cors_configuration = [{
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }]
}

# Image uploads SQS queue
module "image_translation_sqs" {
  source                     = "./modules/sqs_queues"
  project_code               = "blc"
  name_prefix                = "image-translation"
  context                    = module.global.context
  visibility_timeout_seconds = 310
  fifo_queue                 = false
  s3_bucket_arn              = module.image_translation_s3.uploads_s3_bucket_arn
}

resource "aws_lambda_event_source_mapping" "image_translation_lambda_sqs" {
  event_source_arn = module.image_translation_sqs.queue_arn
  function_name    = module.image_translation_lambda.lambda_function_arn
  enabled          = true
  batch_size       = 5
}

# Image DynamoDB table
module "image_translation_status_table" {
  source       = "./modules/dynamodb_tables"
  project_code = "blc"
  name_prefix  = "image-translation-status"
  context      = module.global.context
  hash_key     = "filename"
  range_key    = "updated_at"
  attributes = [
    { name = "filename", type = "S" },
    { name = "updated_at", type = "S" }
  ]
}

# Image Translation API Lambda
module "image_translation_api_lambda" {
  source                                = "./modules/lambda_fns"
  project_code                          = "blc"
  name_prefix                           = "image-translation"
  lambda_description                    = "BildCraft Image Translation API Gateway Lambda proxy handler"
  context                               = module.global.context
  lambda_function_name                  = "api-gateway-proxy-fn"
  lambda_handler                        = "lambda_entrypoint.lambda_handler"
  lambda_runtime                        = "python3.12"
  lambda_memory_size                    = 256
  lambda_reserved_concurrent_executions = 3
  lambda_role_name                      = "api-gateway-proxy-role"
  lambda_s3_bucket                      = module.lambda_source_codes.bucket_id
  lambda_s3_key                         = "blc/image-translation/api-gateway-proxy-source-codes.zip"
  lambda_timeout                        = 60
  lambda_environment_variables = {
    variables = {
      "UPLOADS_BUCKET"    = module.image_translation_s3.uploads_s3_bucket
      "RESULTS_BUCKET"    = module.image_translation_s3.results_s3_bucket
      "STATUS_TABLE_NAME" = module.image_translation_status_table.table_name
    }
  }
  lambda_iam_policy_statements = data.aws_iam_policy_document.image_translation_api_lambda_inline.json
}

# Image Translation API Gateway
module "image_translation_api_gateway" {
  source         = "./modules/api_gateway"
  project_code   = "blc"
  name_prefix    = "image-translation"
  openapi_config = local.image_translation_api_openapi_config
  context        = module.global.context
}

# Image Translation API Gateway Lambda Permission
resource "aws_lambda_permission" "image_translation_api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.image_translation_api_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
}