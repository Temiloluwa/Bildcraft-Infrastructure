module "global" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "hyc"
  stage     = var.environment
  delimiter = "-"

  label_order = ["namespace", "stage"]

  tags = {
    "environment" = var.environment
    "owner"       = "hifeyinc"
    "managedBy"   = "terraform"
  }
}


module "lambda_source_codes" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.10.0"
  name    = "${module.global.id}-lambda-source-codes"
  tags    = module.global.tags

  s3_object_ownership = "BucketOwnerEnforced"
  enabled             = true
  user_enabled        = false
  versioning_enabled  = false
}