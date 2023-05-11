import os
import logging
import base64
import psycopg2

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #print(event)

    print("Getting parameters")
    #secret_name = os.environ['SECRET_NAME']

    username = os.environ['USERNAME']
    password = os.environ['PASSWORD']
    host, port= os.environ['ENDPOINT'].split(":")
    dbname = os.environ['DB']

    print("Connecting to database")
    conn = psycopg2.connect(user=username, password=password, host=host, port=int(port), database=dbname)
    cur = conn.cursor()
    print("CREATE TABLE events")
    cur.execute("CREATE TABLE IF NOT EXISTS events (id serial PRIMARY KEY, event JSON NOT NULL, ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);")

    print("Processing records")
    for record in event['Records']:
        payload = base64.b64decode(record["kinesis"]["data"]).decode("utf-8")
        print(f"payload: {payload}")

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


