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

module "lambda_deployment_iam_user" {
  source  = "cloudposse/iam-system-user/aws"
  version = "1.2.1"
  name    = "${module.global.id}-lambda-deployment-user"
  tags    = module.global.tags

  ssm_base_path = "/${module.global.id}/lambda-deployment-user"
  inline_policies_map = {
    s3 = data.aws_iam_policy_document.iam_deployment_user_policy.json
  }
}

