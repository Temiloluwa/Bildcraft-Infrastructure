module "image_translation_s3" {
  source       = "./modules/upload_s3"
  project_code = "blc"
  name_prefix  = "image-translation"
  context      = module.global.context

  event_notification_details = {
    enabled = true
    lambda_list = [
      {
        lambda_function_arn = module.image_translation_lambda.lambda_function_arn
        events              = ["s3:ObjectCreated:*"]
      }
    ]
  }
}

module "image_translation_lambda" {
  source                                   = "./modules/processing_lambda"
  project_code                             = "blc"
  name_prefix                              = "image-translation"
  lambda_description                       = "Image translation Lambda function"
  context                                  = module.global.context
  lambda_function_name                     = "processor-fn"
  lambda_handler                           = "lambda_entrypoint.lambda_handler"
  lambda_runtime                           = "python3.12"
  lambda_memory_size                       = 256
  lambda_reserved_concurrent_excurrentions = 3
  lambda_role_name                         = "processor-role"
  lambda_s3_bucket                         = module.lambda_source_codes.bucket_id
  lambda_s3_key                            = "blc/image-translation/image-translation.zip"
  lambda_timeout                           = 300
  lambda_environment_variables = {
    variables = {
      "S3_BUCKET_NAME" = module.image_translation_s3.s3_bucket_name
      "S3_OBJECT_KEY"  = "uploads/image-translation"
    }
  }

  lambda_iam_policy_statements = data.aws_iam_policy_document.image_translation_lambda_inline.json
}

data "aws_iam_policy_document" "image_translation_lambda_inline" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.lambda_source_codes.bucket_arn,
      "${module.lambda_source_codes.bucket_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      module.image_translation_s3.s3_bucket_arn,
      "${module.image_translation_s3.s3_bucket_arn}/*"
    ]
  }
}