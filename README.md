# Cloud Computing Homerowk Project

This project consists from several homeworks that gradually build a single project composed of several cloud services:

- Event Stream
- Object Store
- Database
- Function as a Service to glue everything together.

Based on: https://github.com/v1r7u/cloud_computing_course/tree/main/homeworks

The project implements an HTTP-triggered AWS Lambda Function, which ingests events to the AWS Kinesis data stream. In addition, another lambda function is automatically triggered on new events in the Kinesis stream and stores event content in an AWS S3 Storage as JSON file and the AWS RDS PostgreSQL database.

## Usage notes

1. Clone this repository
2. Run `terraform init`
3. Check what terraform going to do with `terraform plan`
4. Build infrastructure with `terraform apply`

After successfully building terraform will output http endpoint url, you can visit it and see that everything built correctly. In addition, AWS S3 bucket name and AWS RDS database endpoint and credentials will be returned.

## Cleanup

Run `terraform destroy`
