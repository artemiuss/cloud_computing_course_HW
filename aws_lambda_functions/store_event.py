import os
import json
import logging
import base64
import psycopg2
import boto3
import botocore 
import botocore.session 
from aws_secretsmanager_caching import SecretCache, SecretCacheConfig 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #print(event)

    print("Getting parameters")
    secret_name = os.environ['SECRET_NAME']
    s3_bucket = os.environ['S3_BUCKET']

    print("Getting secret")
    client = botocore.session.get_session().create_client('secretsmanager')
    cache_config = SecretCacheConfig()
    cache = SecretCache( config = cache_config, client = client)
    secret = cache.get_secret_string(secret_name)

    print("Connecting to S3")
    s3_client = boto3.client('s3')

    print("Connecting to database")
    conn = psycopg2.connect(user=secret["username"], password=secret["password"], host=secret["host"], port=int(secret["port"]), database=secret["dbname"])
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS events (id serial PRIMARY KEY, event JSON NOT NULL, ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);")

    print("Processing records")
    for record in event['Records']:
        payload = base64.b64decode(record["kinesis"]["data"]).decode("utf-8")
        payload_json = json.loads(payload)
        requestId = payload_json['requestContext']['requestId']

        s3_client.put_object(Bucket= s3_bucket, Key=requestId + '.json', Body=payload_json)

        cur.execute("INSERT INTO events (event, ts) VALUES (%s)", (payload_json))

    conn.commit()
    cur.close()
    conn.close()

    return {
        'statusCode': 200,
        'headers': {"Content-Type": "application/json"},
        'body': 'Event stored'
    }


