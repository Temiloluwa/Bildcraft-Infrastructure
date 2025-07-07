module "sqs_label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  name        = var.name_prefix
  attributes  = [var.project_code]
  label_order = ["attributes", "name"]
  context     = var.context
}

resource "aws_sqs_queue" "this" {
  name                       = "${module.sqs_label.id}-uploads-queue"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  fifo_queue                 = var.fifo_queue
  tags                       = module.sqs_label.tags
}

resource "aws_sqs_queue_policy" "image_translation_sqs_policy" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.this.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = var.s3_bucket_arn
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
        Resource = aws_sqs_queue.this.arn
      }
    ]
  })
}

