module "global" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "hyc"
  stage     = var.environment
  delimiter = "-"

  label_order = ["namespace", "stage"]

  tags = {
    "projectName" = var.project_name
    "environment" = var.environment
    "owner"       = "hifeyinc"
    "managedBy"   = "terraform"
  }
}

