output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.id
}

output "lambda_function_url" {
  value = aws_lambda_function_url.lambda_url.function_url
}
