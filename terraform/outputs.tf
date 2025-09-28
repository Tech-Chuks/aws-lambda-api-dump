output "bucket_name" {
  value = aws_s3_bucket.lambda_results.bucket
}

output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}

