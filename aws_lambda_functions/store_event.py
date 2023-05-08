import os
import json
import logging
import base64
import psycopg2
import boto3
import uuid
from aws_lambda_powertools.utilities import parameters

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #print(event)

    secret_name = os.environ['SECRET_NAME']
    s3_bucket = os.environ['S3_BUCKET']

    secret = parameters.get_secret(secret_name)

    s3 = boto3.resource('s3')

    conn= psycopg2.connect(user=secret["username"], password=secret["password"], host=secret["host"], port=int(secret["port"]), database=secret["dbname"])
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS events (id serial PRIMARY KEY, event json NOT NULL, ts timestamp);")

    #for record in event['Records']:
    
        #s3_object = s3.put_object(Bucket= s3_bucket, Key=(uuid.uuid4()) + '.json', Body=event['body'])

        #r = json.loads(base64.b64decode(record['kinesis']['data']).decode('utf-8'))
        #cur.execute("INSERT INTO events (id, text, date) VALUES (%s, %s, DATE %s)",
        #            (r['id'], r['text'], parse(r['date'])))

        #cur.execute("INSERT INTO events (event, ts) VALUES (%s, %s)", (record['body'], record['attributes']['SentTimestamp']))

    conn.commit()
    cur.close()
    conn.close()

    return {
        'statusCode': 200,
        'headers': {"Content-Type": "application/json"},
        'body': 'Event stored'
    }


