
resource "aws_api_gateway_rest_api" "mangum_api" {
  name        = "MangumExampleAPI"
  description = "Example API to try Mangum + FastAPI!"
}

resource "aws_api_gateway_resource" "api_endpoints_resource" {
  parent_id   = aws_api_gateway_rest_api.mangum_api.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
}

resource "aws_api_gateway_method" "get_method" {
  resource_id   = aws_api_gateway_resource.api_endpoints_resource.id
  rest_api_id   = aws_api_gateway_rest_api.mangum_api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mangum_api.id
  resource_id             = aws_api_gateway_resource.api_endpoints_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.mangum_func.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda_deploy" {
  rest_api_id = aws_api_gateway_rest_api.mangum_api.id
  description = "Deployment of function integration."

  triggers = {
    redeploy = filebase64sha256("api-gateway.tf")
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}

resource "aws_lambda_permission" "api_invoke_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mangum_func.function_name
  principal     = "apigateway.amazonaws.com"
}