import os
import json
import logging
import base64
import psycopg2
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #print(event)

    print("Getting parameters")
    #secret_name = os.environ['SECRET_NAME']
    s3_bucket = os.environ['S3_BUCKET']

    username = os.environ['USERNAME']
    password = os.environ['PASSWORD']
    host, port= os.environ['ENDPOINT'].split(":")
    dbname = os.environ['DB']

    print("Connecting to S3")
    s3_client = boto3.client('s3')

    print("Connecting to database")
    try:
        conn = psycopg2.connect(user=username, password=password, host=host, port=int(port), database=dbname)
    except Exception as e:
        print("Unable to connect to database")
        print(e)
        return {
            'statusCode': 500,
            'headers': {"Content-Type": "application/json"},
            'body': 'Unable to connect to database'
        }
    cur = conn.cursor()
    print("CREATE TABLE events")
    cur.execute("CREATE TABLE IF NOT EXISTS events (id serial PRIMARY KEY, event JSON NOT NULL, ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);")

    print("Processing records")
    for record in event['Records']:
        payload = base64.b64decode(record["kinesis"]["data"]).decode("utf-8")
        print(f"payload: {payload}")
        payload_json = json.loads(payload)
        print(f"payload_json: {payload_json}")
        requestId = payload_json['requestContext']['requestId']
        print(f"requestId: {requestId}")

        print("S3 put object")
        s3_client.put_object(Bucket= s3_bucket, Key=requestId + '.json', Body=payload)

        print("DB insert record")
        cur.execute("INSERT INTO events (event, ts) VALUES (%s)", (payload))

    conn.commit()
    cur.close()
    conn.close()

    return {
        'statusCode': 200,
        'headers': {"Content-Type": "application/json"},
        'body': 'Event stored'
    }


