logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    print(event)
    return {
        'statusCode': 200,
        'headers': {"Content-Type": "application/json"},
        'body': 'Event stored'
    }
