
locals {
  function_file = "../lambda-src.zip"
}

resource "aws_lambda_function" "mangum_func" {
  function_name    = "mangum-example-function"
  role             = aws_iam_role.mangum_func_role.arn
  runtime          = "python3.9"
  package_type     = "Zip"
  filename         = local.function_file
  source_code_hash = filebase64sha256(local.function_file)
  memory_size      = var.lambda_memory
  handler          = "main.lambda_handler"

  environment {
    variables = {
      STAGE_NAME = var.stage_name
    }
  }
}
