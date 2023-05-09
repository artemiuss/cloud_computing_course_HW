output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.id
}

output "lambda_function_url" {
  value = aws_lambda_function_url.lambda_url.function_url
}

output "db_endpoint" {
  value = aws_db_instance.pg_db.endpoint
}

output "db_user" {
  value = aws_db_instance.pg_db.username
}

output "db_password" {
  value = aws_db_instance.pg_db.password
  sensitive = true
}

