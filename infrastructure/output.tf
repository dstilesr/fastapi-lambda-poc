
output "lambda_arn" {
  value = aws_lambda_function.mangum_func.arn
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.mangum_api.id
}

output "invoke_url" {
  value = aws_api_gateway_deployment.lambda_deploy.invoke_url
}