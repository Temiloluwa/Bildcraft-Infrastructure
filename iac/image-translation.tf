module "image_translation_lambda" {
  source                                   = "./modules/lambda_fns"
  project_code                             = "blc"
  name_prefix                              = "image-translation"
  lambda_description                       = "BildCraft Image translation Lambda function"
  context                                  = module.global.context
  lambda_function_name                     = "processor-fn"
  lambda_handler                           = "lambda_entrypoint.lambda_handler"
  lambda_runtime                           = "python3.12"
  lambda_memory_size                       = 256
  lambda_reserved_concurrent_excurrentions = 3
  lambda_role_name                         = "processor-role"
  lambda_s3_bucket                         = module.lambda_source_codes.bucket_id
  lambda_s3_key                            = "blc/image-translation/image-translation-source-codes.zip"
  lambda_timeout                           = 300
  lambda_environment_variables = {
    variables = {
      "UPLOADS_BUCKET"            = module.image_translation_s3_uploads.uploads_s3_bucket
      "RESULTS_BUCKET"            = module.image_translation_s3_results.results_s3_bucket
      "UPLOADS_QUEUE_URL"         = module.image_translation_sqs.queue_url
      "STATUS_TABLE_NAME"         = module.image_translation_status_table.table_name
      "OCR_MODEL_API_KEY"         = data.aws_ssm_parameter.ocr_model_api_key.value
      "TRANSLATION_MODEL_API_KEY" = data.aws_ssm_parameter.translation_model_api_key.value
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
      "s3:ListBucket",
      "s3:HeadObject"
    ]
    resources = [
      module.image_translation_s3_uploads.uploads_s3_bucket_arn,
      "${module.image_translation_s3_uploads.uploads_s3_bucket_arn}/*"
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
      module.image_translation_s3_results.results_s3_bucket_arn,
      "${module.image_translation_s3_results.results_s3_bucket_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [
      module.image_translation_sqs.queue_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      module.image_translation_status_table.table_arn,
      "${module.image_translation_status_table.table_arn}/*"
    ]
  }
}

module "image_translation_s3_uploads" {
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
}

module "image_translation_s3_results" {
  source       = "./modules/s3_buckets"
  project_code = "blc"
  name_prefix  = "image-translation"
  context      = module.global.context
}

module "image_translation_sqs" {
  source                     = "./modules/sqs_queues"
  project_code               = "blc"
  name_prefix                = "image-translation"
  context                    = module.global.context
  visibility_timeout_seconds = 310
  fifo_queue                 = false
}

resource "aws_sqs_queue_policy" "image_translation_sqs_policy" {
  queue_url = module.image_translation_sqs.queue_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = module.image_translation_sqs.queue_arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = module.image_translation_s3_uploads.uploads_s3_bucket_arn
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = module.image_translation_sqs.queue_arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "image_translation_lambda_sqs" {
  event_source_arn = module.image_translation_sqs.queue_arn
  function_name    = module.image_translation_lambda.lambda_function_arn
  enabled          = true
  batch_size       = 5
}

module "image_translation_status_table" {
  source       = "./modules/dynamodb_tables"
  project_code = "blc"
  name_prefix  = "image-translation-status"
  context      = module.global.context
  hash_key     = "filename"
  range_key    = "uuid"
  attributes = [
    { name = "filename", type = "S" },
    { name = "uuid", type = "S" }
  ]
}

data "aws_ssm_parameter" "ocr_model_api_key" {
  name            = "/image-translation/ocr-model-api-key"
  with_decryption = true
}

data "aws_ssm_parameter" "translation_model_api_key" {
  name            = "/image-translation/translation-model-api-key"
  with_decryption = true
}

