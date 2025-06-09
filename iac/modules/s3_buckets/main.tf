module "s3_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  name       = var.name_prefix
  attributes = [var.project_code]

  label_order = ["attributes", "name"]
  context     = var.context
}

# docs: https://github.com/cloudposse/terraform-aws-s3-bucket
module "upload_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.10.0"
  name    = "${module.s3_label.id}-uploads"
  tags    = module.s3_label.tags

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = false

  event_notification_details = var.event_notification_details
  cors_configuration         = var.cors_configuration
}

module "results_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.10.0"
  name    = "${module.s3_label.id}-results"
  tags    = module.s3_label.tags

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = false
}
