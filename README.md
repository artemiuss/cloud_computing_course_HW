# Cloud Computing Homerowk Project

This project consists from several homeworks that gradually build a single project composed of several cloud services:

- Event Stream
- Object Store
- Database
- Function as a Service to glue everything together.

Based on: https://github.com/v1r7u/cloud_computing_course/tree/main/homeworks

The project implements an HTTP-triggered AWS Lambda Function, which ingests events to the AWS Kinesis data stream. In addition, another lambda function is automatically triggered on new events in the Kinesis stream and stores event content in an AWS S3 Storage as JSON file and the AWS RDS PostgreSQL database.

## Set up
1. Clone this repository
2. Run `terraform init`
3. Check what terraform going to do with `terraform plan`
4. Build infrastructure with `terraform apply`
5. Get database password: `terraform output db_password`

After successfully building terraform will output http endpoint url, you can visit it and see that everything built correctly. In addition, AWS S3 bucket name and AWS RDS database endpoint and credentials will be returned.

## Usage notes
1. Call AWS Lambda function using the endpoint url.
Since the ingestion function URL uses the AWS_IAM auth type, you must sign each HTTP request using AWS Signature Version 4 (SigV4). Tools such as awscurl, Postman, and AWS SigV4 Proxy offer built-in ways to sign your requests with SigV4. 

    Here is an example of using the [awscurl](https://github.com/okigan/awscurl) tool to invoke the function:

    ```bash
    pip install awscurl
    
    awscurl --service lambda --region <aws_region variable value from the variables.tf file> "<lambda_function_url from the terraform output>"
    ```

2. Check AWS S3 bucket for new file
3. Check AWS RDS database for new record

## Cleanup
Run `terraform destroy`
