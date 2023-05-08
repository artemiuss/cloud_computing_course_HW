terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_cli_profile
}

data "archive_file" "ingest_event" {
  type        = "zip"
  source_file = "aws_lambda_functions/ingest_event.py"
  output_path = "aws_lambda_functions/ingest_event.zip"
}

data "archive_file" "store_event" {
  type        = "zip"
  source_file = "aws_lambda_functions/store_event.py"
  output_path = "aws_lambda_functions/store_event.zip"
}

resource "aws_lambda_function" "ingest_event" {
  filename         = "ingest_event.zip"
  function_name    = "aws_lambda_functions/ingest_event"
  source_code_hash = data.archive_file.ingest_event.output_base64sha256
  handler          = "ingest_event.lambda_handler"
  runtime          = "python3.9"
  timeout          = 5
  role             = aws_iam_role.aws_lambda_ingest_event_role.arn

  environment {
    variables = {
      KINESIS_STREAM = var.kinesis_stream
    }
  }
}

resource "aws_lambda_function" "store_event" {
  filename         = "store_event.zip"
  function_name    = "aws_lambda_functions/store_event"
  source_code_hash = data.archive_file.store_event.output_base64sha256
  handler          = "store_event.lambda_handler"
  runtime          = "python3.9"
  timeout          = 5
  role             = aws_iam_role.aws_lambda_store_event_role.arn

  environment {
    variables = {
      S3_BUCKET = var.s3_bucket
      # DB_ENDPINT  = aws_db_instance.pg_db.endpoint
      # DB_NAME     = aws_db_instance.pg_db.db_name
      # DB_USER     = aws_db_instance.pg_db.username
      # DB_PASSWORD = aws_db_instance.pg_db.password
      SECRET_NAME = aws_secretsmanager_secret.password.rds_secret.name
    }
  }
}

resource "random_password" "db_password"{
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name_prefix = "pg_rds_secret"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    "username"             = aws_db_instance.pg_db.username
    "password"             = aws_db_instance.pg_db.password
    "engine"               = aws_db_instance.pg_db.engine
    "host"                 = aws_db_instance.pg_db.address
    "port"                 = aws_db_instance.pg_db.port
    "dbInstanceIdentifier" = aws_db_instance.pg_db.id
  })
}

resource "aws_db_instance" "pg_db" {
  allocated_storage    = 10
  apply_immediately    = true
  db_name              = "db"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = "lambda"
  password             = random_password.db_password.result
  skip_final_snapshot  = true

  #publicly_accessible    = true
  #db_subnet_group_name   = 
  #vpc_security_group_ids = 
  #depends_on =
}





resource "aws_iam_role" "function_role" {
  name = "${local.function_name}-${var.env_name}"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

