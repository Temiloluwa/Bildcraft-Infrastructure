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
  policy                     = var.policy
  tags                       = module.sqs_label.tags
}
