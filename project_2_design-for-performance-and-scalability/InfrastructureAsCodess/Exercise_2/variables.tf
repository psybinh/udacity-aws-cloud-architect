# TODO: Define the variable for aws_region
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "runtime" {
  type    = string
  default = "python3.11"
}

variable "lambda_function" {
  type    = string
  default = "greet_lambda"
}

variable "zip_file_name" {
  type    = string
  default = "greet_lambda.zip"
}

variable "lambda_handler" {
  type    = string
  default = "greet_lambda.lambda_handler"
}