provider "aws" {
  region = var.region
  profile = "default"
}

data "archive_file" "archive" {
  type = "zip"
  source_file = "greet_lambda.py"
  output_path = var.zip_file_name
}

resource "aws_iam_role" "lambda_iam" {
  name = "lambda_iam"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "log_iam" {
  name = "log_iam"
  path = "/"
  description = ""
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.log_iam.arn
}

resource "aws_cloudwatch_log_group" "greeting_lambda_log_group" {
  name = "/aws/lambda/greet_lambda"
  retention_in_days = 30
}

resource "aws_lambda_function" "greet_lambda" {
  filename = var.zip_file_name
  function_name = var.lambda_function
  role = aws_iam_role.lambda_iam.arn
  handler = var.lambda_handler

  source_code_hash = data.archive_file.archive.output_base64sha256

  runtime = var.runtime

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.greeting_lambda_log_group
  ]

  environment {
    variables = {
      greeting = "Hello world"
    }
  }
}

