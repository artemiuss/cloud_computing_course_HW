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

#
# Lambda
#
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
  filename         = "aws_lambda_functions/ingest_event.zip"
  function_name    = "ingest_event"
  source_code_hash = data.archive_file.ingest_event.output_base64sha256
  handler          = "ingest_event.lambda_handler"
  runtime          = "python3.9"
  timeout          = 5
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      KINESIS_STREAM = var.kinesis_stream
    }
  }
}

resource "aws_lambda_function" "store_event" {
  filename         = "aws_lambda_functions/store_event.zip"
  function_name    = "store_event"
  source_code_hash = data.archive_file.store_event.output_base64sha256
  handler          = "store_event.lambda_handler"
  runtime          = "python3.9"
  timeout          = 20
  role             = aws_iam_role.lambda_role.arn

  layers = [
    aws_lambda_layer_version.lambda_psycopg2_layer.arn
  ]

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.s3_bucket.id
      #SECRET_NAME = aws_secretsmanager_secret.rds_secret.name
      USERNAME = aws_db_instance.pg_db.username
      PASSWORD = aws_db_instance.pg_db.password
      ENDPOINT = aws_db_instance.pg_db.endpoint
      DB       = aws_db_instance.pg_db.db_name
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [
    aws_lambda_layer_version.lambda_psycopg2_layer,
    aws_s3_bucket.s3_bucket,
    aws_db_instance.pg_db
  ]
}

#
# Lambda Layers
#
data "archive_file" "lambda_psycopg2_layer_archive" {
  type        = "zip"
  source_dir  = "layers/psycopg2"
  output_path = "lambda-python-psycopg2-layer.zip"
}

resource "aws_lambda_layer_version" "lambda_psycopg2_layer" {
  filename   = data.archive_file.lambda_psycopg2_layer_archive.output_path
  layer_name = "lambda_psycopg2_layer"
}

#
# Lambda URL
#
resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.ingest_event.function_name
  authorization_type = "AWS_IAM"
}

#
# Kinesis
#
resource "aws_kinesis_stream" "kinesis_stream" {
  name             = var.kinesis_stream
  shard_count      = 1
  retention_period = 24
  
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_lambda_function_event_invoke_config" "kinesis_trigger" {
  function_name                = aws_lambda_function.store_event.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}

resource "aws_lambda_event_source_mapping" "kinesis_to_s3_mapping" {
  event_source_arn  = aws_kinesis_stream.kinesis_stream.arn
  function_name     = aws_lambda_function.store_event.arn
  starting_position = "LATEST"
}

#
# S3
#
resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = var.s3_bucket_prefix
}

resource "aws_s3_bucket_public_access_block" "access_s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#
# Secret Manager
#
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

#
# RDS
#
resource "aws_db_instance" "pg_db" {
  allocated_storage    = 10
  apply_immediately    = true
  db_name              = "hw_db"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = "lambda"
  password             = random_password.db_password.result
  skip_final_snapshot  = true

  #publicly_accessible    = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.lambda_sg.id]
}

#
# Neteorking
#
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
}

resource "aws_security_group" "lambda_sg" {
  name   = "lambda_sg"
  description = "Security group for AWS lambda and AWS RDS connection"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["127.0.0.1/32"]
    self = true
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

#
# IAM
#
resource "aws_iam_role" "lambda_role" {
  name = "lambda-vpc-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
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

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:*",
          "cloudwatch:*",
          "kinesis:*",
          "s3:*",
          "ec2:*",
          "secretsmanager:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment_2" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
