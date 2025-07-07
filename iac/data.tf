# Get the current AWS region
data "aws_region" "current" {}

# Fetch the OCR model API key from SSM Parameter Store
data "aws_ssm_parameter" "ocr_model_api_key" {
  name            = "/image-translation/ocr-model-api-key"
  with_decryption = true
}

# Fetch the translation model API key from SSM Parameter Store
data "aws_ssm_parameter" "translation_model_api_key" {
  name            = "/image-translation/translation-model-api-key"
  with_decryption = true
}

# IAM policy for deployment user to manage Lambda code and S3 objects
data "aws_iam_policy_document" "iam_deployment_user_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]
    resources = [
      module.lambda_source_codes.bucket_arn,
      "${module.lambda_source_codes.bucket_arn}/*"
    ]
  }
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:PublishVersion",
      "lambda:CreateAlias",
      "lambda:UpdateAlias",
      "lambda:GetFunction"
    ]
    resources = [
      module.image_translation_lambda.lambda_function_arn,
      module.image_translation_api_lambda.lambda_function_arn
    ]
  }
}

# IAM policy for the image translation Lambda function
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
      module.image_translation_s3.uploads_s3_bucket_arn,
      "${module.image_translation_s3.uploads_s3_bucket_arn}/*"
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
      module.image_translation_s3.results_s3_bucket_arn,
      "${module.image_translation_s3.results_s3_bucket_arn}/*"
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

# IAM policy for the image translation API Lambda function
data "aws_iam_policy_document" "image_translation_api_lambda_inline" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:HeadObject"
    ]
    resources = [
      module.image_translation_s3.uploads_s3_bucket_arn,
      "${module.image_translation_s3.uploads_s3_bucket_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:HeadObject"
    ]
    resources = [
      module.image_translation_s3.results_s3_bucket_arn,
      "${module.image_translation_s3.results_s3_bucket_arn}/*"
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