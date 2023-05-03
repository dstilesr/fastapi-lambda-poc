
resource "aws_api_gateway_rest_api" "mangum_api" {
  name        = "MangumExampleAPI"
  description = "Example API to try Mangum + FastAPI!"
}


resource "aws_api_gateway_resource" "base_api_resource" {
  parent_id   = aws_api_gateway_rest_api.mangum_api.root_resource_id
  path_part   = "api"
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
}

#################################################
# API Endpoints Integration
#################################################
resource "aws_api_gateway_resource" "api_get" {
  parent_id   = aws_api_gateway_resource.base_api_resource.id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
}

resource "aws_api_gateway_method" "api_get" {
  resource_id   = aws_api_gateway_resource.api_get.id
  rest_api_id   = aws_api_gateway_rest_api.mangum_api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mangum_api.id
  resource_id             = aws_api_gateway_resource.api_get.id
  http_method             = aws_api_gateway_method.api_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.mangum_func.invoke_arn
}

#################################################
# Docs Endpoints Integration
#################################################
resource "aws_api_gateway_resource" "doc_base" {
  parent_id   = aws_api_gateway_rest_api.mangum_api.root_resource_id
  path_part   = "api-docs"
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
}

resource "aws_api_gateway_resource" "doc_get" {
  parent_id   = aws_api_gateway_resource.doc_base.id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
}

resource "aws_api_gateway_method" "doc_get" {
  resource_id   = aws_api_gateway_resource.doc_get.id
  rest_api_id   = aws_api_gateway_rest_api.mangum_api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "doc_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mangum_api.id
  resource_id             = aws_api_gateway_resource.doc_get.id
  http_method             = aws_api_gateway_method.doc_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.mangum_func.invoke_arn
}

#################################################
# Deployment + Stage + permissions
#################################################
resource "aws_api_gateway_deployment" "lambda_deploy" {
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
  description = "Deployment of function integration."

  triggers = {
    redeploy = filebase64sha256("api-gateway.tf")
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.api_get_integration,
    aws_api_gateway_integration.doc_get_integration
  ]
}

resource "aws_api_gateway_stage" "deploy_stage" {
  deployment_id = aws_api_gateway_deployment.lambda_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.mangum_api.id
  stage_name    = var.stage_name
}

resource "aws_lambda_permission" "api_invoke_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mangum_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mangum_api.execution_arn}/*/GET/*"
}