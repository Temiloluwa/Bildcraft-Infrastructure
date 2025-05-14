module "s3_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  name       = var.project_code
  attributes = [var.prefix]
  context    = var.context
}

# docs: https://github.com/cloudposse/terraform-aws-s3-bucket
module "upload_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.10.0"
  name    = "${module.s3_label.id}-uploads"

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = false

  # bucket policy to define access for additional priviledge pricipalles
  privileged_principal_actions = var.privileged_principal_actions
  privileged_principal_arns    = var.privileged_principal_arns
  event_notification_details   = var.event_notification_details
  cors_configuration           = var.cors_configuration
}