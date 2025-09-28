# ========== CloudWatch Logs retention ==========

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.fetch_api.function_name}"
  retention_in_days = 14 # keep logs for 14 days
}

# ========== CloudWatch Alarm for Lambda Errors ==========

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda_api_fetch_errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm if Lambda has any errors for 5 minutes"
  dimensions = {
    FunctionName = aws_lambda_function.fetch_api.function_name
  }
  treat_missing_data = "notBreaching"
}

