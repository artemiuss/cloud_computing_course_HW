import os
import logging
import boto3
import uuid

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #print(event)

    kinesis_stream = os.environ['KINESIS_STREAM']

    kinesis_client = boto3.client('kinesis')

    response = kinesis_client.put_record(
        StreamName=kinesis_stream,
        Data=event['body'],
        PartitionKey=uuid.uuid4())

    return {
        'statusCode': 200,
        'headers': {"Content-Type": "application/json"},
        'body': response
    }
