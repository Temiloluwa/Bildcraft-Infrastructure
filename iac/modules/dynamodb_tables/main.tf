module "dynamodb_label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  name        = var.name_prefix
  attributes  = [var.project_code]
  label_order = ["attributes", "name"]
  context     = var.context
}

resource "aws_dynamodb_table" "this" {
  name         = "${module.dynamodb_label.id}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key
  range_key    = var.range_key != "" ? var.range_key : null

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  tags = module.dynamodb_label.tags
}
