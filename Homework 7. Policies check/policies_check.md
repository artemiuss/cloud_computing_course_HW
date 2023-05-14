# Policies check

**The goal**: check your project compliance with standard policies.

- Scan your project with [checkov](https://github.com/bridgecrewio/checkov)
- Fix at least two different failed checks

## Deliveries

### How to reproduce the results

Run `checkov -d .` in the root of the project.

### Result of initial scan

```
checkov -d .
       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By bridgecrew.io | version: 2.3.240

terraform scan results:

Passed checks: 34, Failed checks: 49, Skipped checks: 0
```

The full result of the scan can be found in the `init_scan_result.log` file.

### The checks fixed

<table style="font-size: 10px;">
<tr>
<th>Before</th>
<th>After</th>
</tr>
<tr>
<td>

```
Check: CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
	FAILED for resource: aws_lambda_function.ingest_event
	File: /main.tf:38-52
	Guide: https://docs.bridgecrew.io/docs/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq

		38 | resource "aws_lambda_function" "ingest_event" {
		39 |   filename         = "aws_lambda_functions/ingest_event.zip"
		40 |   function_name    = "ingest_event"
		41 |   source_code_hash = data.archive_file.ingest_event.output_base64sha256
		42 |   handler          = "ingest_event.lambda_handler"
		43 |   runtime          = "python3.9"
		44 |   timeout          = 5
		45 |   role             = aws_iam_role.lambda_role.arn
		46 | 
		47 |   environment {
		48 |     variables = {
		49 |       KINESIS_STREAM = var.kinesis_stream
		50 |     }
		51 |   }
		52 | }
```
</td>
<td>

```
Check: CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
	PASSED for resource: aws_lambda_function.ingest_event
	File: /main.tf:42-64
	Guide: https://docs.bridgecrew.io/docs/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq
```
</td>
</tr>
<tr>
<td>

```
Check: CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
	FAILED for resource: aws_lambda_function.store_event_to_s3
	File: /main.tf:59-78
	Guide: https://docs.bridgecrew.io/docs/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq

		59 | resource "aws_lambda_function" "store_event_to_s3" {
		60 |   filename         = "aws_lambda_functions/store_event_to_s3.zip"
		61 |   function_name    = "store_event_to_s3"
		62 |   source_code_hash = data.archive_file.store_event_to_s3.output_base64sha256
		63 |   handler          = "store_event_to_s3.lambda_handler"
		64 |   runtime          = "python3.9"
		65 |   timeout          = 20
		66 |   role             = aws_iam_role.lambda_role.arn
		67 | 
		68 |   environment {
		69 |     variables = {
		70 |       S3_BUCKET = aws_s3_bucket.s3_bucket.id
		71 |     }
		72 |   }
		73 | 
		74 |   depends_on = [
		75 |     aws_kinesis_stream.kinesis_stream,
		76 |     aws_s3_bucket.s3_bucket
		77 |   ]
		78 | }
```
</td>
<td>

```
Check: CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
	PASSED for resource: aws_lambda_function.store_event_to_s3
	File: /main.tf:75-102
	Guide: https://docs.bridgecrew.io/docs/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq
```
</td>
</tr>
<tr>
<td>

```
Check: CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
	FAILED for resource: aws_lambda_function.store_event_to_db
	File: /main.tf:80-107
	Guide: https://docs.bridgecrew.io/docs/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq

		80  | resource "aws_lambda_function" "store_event_to_db" {
		81  |   filename         = "aws_lambda_functions/store_event_to_db.zip"
		82  |   function_name    = "store_event_to_db"
		83  |   source_code_hash = data.archive_file.store_event_to_db.output_base64sha256
		84  |   handler          = "store_event_to_db.lambda_handler"
		85  |   runtime          = "python3.9"
		86  |   timeout          = 20
		87  |   role             = aws_iam_role.lambda_role.arn
		88  | 
		89  |   layers = [
		90  |     aws_lambda_layer_version.lambda_psycopg2_layer.arn
		91  |   ]
		92  | 
		93  |   environment {
		94  |     variables = {
		95  |       #SECRET_NAME = aws_secretsmanager_secret.rds_secret.name
		96  |       USERNAME = aws_db_instance.pg_db.username
		97  |       PASSWORD = aws_db_instance.pg_db.password
		98  |       ENDPOINT = aws_db_instance.pg_db.endpoint
		99  |       DB       = aws_db_instance.pg_db.db_name
		100 |     }
		101 |   }
		102 | 
		103 |   depends_on = [
		104 |     aws_lambda_layer_version.lambda_psycopg2_layer,
		105 |     aws_db_instance.pg_db
		106 |   ]
		107 | }		
```
</td>
<td>

```
Check: CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
	PASSED for resource: aws_lambda_function.store_event_to_db
	File: /main.tf:108-143
	Guide: https://docs.bridgecrew.io/docs/ensure-that-aws-lambda-function-is-configured-for-a-dead-letter-queue-dlq
```
</td>
</tr>
<tr>
<td>

```
Check: CKV_AWS_50: "X-ray tracing is enabled for Lambda"
	FAILED for resource: aws_lambda_function.ingest_event
	File: /main.tf:38-52
	Guide: https://docs.bridgecrew.io/docs/bc_aws_serverless_4

		38 | resource "aws_lambda_function" "ingest_event" {
		39 |   filename         = "aws_lambda_functions/ingest_event.zip"
		40 |   function_name    = "ingest_event"
		41 |   source_code_hash = data.archive_file.ingest_event.output_base64sha256
		42 |   handler          = "ingest_event.lambda_handler"
		43 |   runtime          = "python3.9"
		44 |   timeout          = 5
		45 |   role             = aws_iam_role.lambda_role.arn
		46 | 
		47 |   environment {
		48 |     variables = {
		49 |       KINESIS_STREAM = var.kinesis_stream
		50 |     }
		51 |   }
		52 | }
```
</td>
<td>

```
Check: CKV_AWS_50: "X-ray tracing is enabled for Lambda"
	PASSED for resource: aws_lambda_function.ingest_event
	File: /main.tf:42-64
	Guide: https://docs.bridgecrew.io/docs/bc_aws_serverless_4
```
</td>
</tr>
<tr>
<td>

```
Check: CKV_AWS_50: "X-ray tracing is enabled for Lambda"
	FAILED for resource: aws_lambda_function.store_event_to_s3
	File: /main.tf:59-78
	Guide: https://docs.bridgecrew.io/docs/bc_aws_serverless_4

		59 | resource "aws_lambda_function" "store_event_to_s3" {
		60 |   filename         = "aws_lambda_functions/store_event_to_s3.zip"
		61 |   function_name    = "store_event_to_s3"
		62 |   source_code_hash = data.archive_file.store_event_to_s3.output_base64sha256
		63 |   handler          = "store_event_to_s3.lambda_handler"
		64 |   runtime          = "python3.9"
		65 |   timeout          = 20
		66 |   role             = aws_iam_role.lambda_role.arn
		67 | 
		68 |   environment {
		69 |     variables = {
		70 |       S3_BUCKET = aws_s3_bucket.s3_bucket.id
		71 |     }
		72 |   }
		73 | 
		74 |   depends_on = [
		75 |     aws_kinesis_stream.kinesis_stream,
		76 |     aws_s3_bucket.s3_bucket
		77 |   ]
		78 | }
```
</td>
<td>

```
Check: CKV_AWS_50: "X-ray tracing is enabled for Lambda"
	PASSED for resource: aws_lambda_function.store_event_to_s3
	File: /main.tf:75-102
	Guide: https://docs.bridgecrew.io/docs/bc_aws_serverless_4
```
</td>
</tr>
<tr>
<td>

```
Check: CKV_AWS_50: "X-ray tracing is enabled for Lambda"
	FAILED for resource: aws_lambda_function.store_event_to_db
	File: /main.tf:80-107
	Guide: https://docs.bridgecrew.io/docs/bc_aws_serverless_4

		80  | resource "aws_lambda_function" "store_event_to_db" {
		81  |   filename         = "aws_lambda_functions/store_event_to_db.zip"
		82  |   function_name    = "store_event_to_db"
		83  |   source_code_hash = data.archive_file.store_event_to_db.output_base64sha256
		84  |   handler          = "store_event_to_db.lambda_handler"
		85  |   runtime          = "python3.9"
		86  |   timeout          = 20
		87  |   role             = aws_iam_role.lambda_role.arn
		88  | 
		89  |   layers = [
		90  |     aws_lambda_layer_version.lambda_psycopg2_layer.arn
		91  |   ]
		92  | 
		93  |   environment {
		94  |     variables = {
		95  |       #SECRET_NAME = aws_secretsmanager_secret.rds_secret.name
		96  |       USERNAME = aws_db_instance.pg_db.username
		97  |       PASSWORD = aws_db_instance.pg_db.password
		98  |       ENDPOINT = aws_db_instance.pg_db.endpoint
		99  |       DB       = aws_db_instance.pg_db.db_name
		100 |     }
		101 |   }
		102 | 
		103 |   depends_on = [
		104 |     aws_lambda_layer_version.lambda_psycopg2_layer,
		105 |     aws_db_instance.pg_db
		106 |   ]
		107 | }		
```
</td>
<td>

```
Check: CKV_AWS_50: "X-ray tracing is enabled for Lambda"
	PASSED for resource: aws_lambda_function.store_event_to_db
	File: /main.tf:108-143
	Guide: https://docs.bridgecrew.io/docs/bc_aws_serverless_4	
```
</td>
</tr>

</table>


### Result of scan after fixes applied

```
       _               _              
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V / 
  \___|_| |_|\___|\___|_|\_\___/ \_/  
                                      
By bridgecrew.io | version: 2.3.240 

terraform scan results:

Passed checks: 43, Failed checks: 46, Skipped checks: 0
```

The full result of the scan can be found in the `fixed_scan_result.log` file.