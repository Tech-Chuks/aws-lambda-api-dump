# ========== Lambda Packaging and Function ==========

# Package Lambda function as a ZIP
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/../lambda/app.zip"
}

# Lambda function resource
resource "aws_lambda_function" "fetch_api" {
  function_name = "lambda_api_fetch"

  role     = aws_iam_role.lambda_exec_role.arn
  handler  = "app.lambda_handler"
  runtime  = "python3.12"
  filename = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      BUCKET_NAME   = aws_s3_bucket.lambda_results.bucket
      OBJECT_PREFIX = "results/"
      TARGET_URL    = "https://api.open-meteo.com/v1/forecast?latitude=35&longitude=139&hourly=temperature_2m"
    }
  }

  tags = {
    Project = "aws-lambda-api-dump"
  }
}

