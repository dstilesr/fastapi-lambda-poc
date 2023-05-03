
locals {
  function_file = "../lambda-src.zip"
}

resource "aws_iam_role" "mangum_func_role" {
  name = "MangumFunctionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
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
}

resource "aws_iam_policy" "write_logs" {
  name = "MangumLogsPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logs_attach" {
  policy_arn = aws_iam_policy.write_logs.arn
  role       = aws_iam_role.mangum_func_role.name
}
