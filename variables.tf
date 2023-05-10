variable "aws_region" {
  description = "The AWS region where the lambda code needs to be deployed"
  default     = "eu-central-1"
}

variable "aws_cli_profile" {
  description = "The AWS CLI profile terraform should use to authenticate with AWS"
  default     = "default"
}

variable "kinesis_stream" {
  description = "Kinesis stream"
  type        = string
  default     = "stream_auto"
}

variable "s3_bucket_prefix" {
  description = "S3 bucket to store data"
  type        = string
  default     = "cloudcomputingcoursehw"
}
