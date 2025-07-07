module "lambda_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  name       = var.name_prefix
  attributes = [var.project_code]

  label_order = ["attributes", "name"]
  context     = var.context
}

resource "aws_api_gateway_rest_api" "this" {
  name           = "${var.project_code}-${var.name_prefix}-api"
  api_key_source = "HEADER"
  body           = jsonencode(var.openapi_config)
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "${var.project_code}-${var.name_prefix}-prod"
}

resource "aws_api_gateway_usage_plan" "this" {
  name = "${var.project_code}-${var.name_prefix}-usage-plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }
}

resource "aws_api_gateway_api_key" "this" {
  name = "${var.project_code}-${var.name_prefix}-api-key"
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}