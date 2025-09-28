# ========== EventBridge schedule for the Lambda ==========

# 1) EventBridge rule: run every 15 minutes
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda_api_fetch_every_15m"
  description         = "Invoke lambda_api_fetch every 15 minutes"
  schedule_expression = "rate(15 minutes)"
  # Example if you want a cron instead:
  # schedule_expression = "cron(0 * * * ? *)" # top of every hour
  tags = {
    Project = "aws-lambda-api-dump"
  }
}

# 2) EventBridge target: wire the rule to your Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda_api_fetch_target"
  arn       = aws_lambda_function.fetch_api.arn
}

# 3) Lambda permission: allow EventBridge to invoke the function
resource "aws_lambda_permission" "allow_events_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_api.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# (Optional) Make the schedule easy to toggle via a variable later.
# For now we keep it always-enabled; you can disable the rule in console or with CLI if needed.

