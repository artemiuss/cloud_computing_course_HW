import os
import json
import logging
import base64
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #print(event)

    print("Getting parameters")
    s3_bucket = os.environ['S3_BUCKET']

    print("Connecting to S3")
    s3_client = boto3.client('s3')

    print("Processing records")
    for record in event['Records']:
        payload = base64.b64decode(record["kinesis"]["data"]).decode("utf-8")
        print(f"payload: {payload}")
        payload_json = json.loads(payload)
        requestId = payload_json['requestContext']['requestId']
        print(f"requestId: {requestId}")

        print("S3 put object")
        s3_client.put_object(Bucket=s3_bucket, Key=requestId + '.json', Body=payload)

    return {
        'statusCode': 200,
        'headers': {"Content-Type": "application/json"},
        'body': 'Event stored'
    }


