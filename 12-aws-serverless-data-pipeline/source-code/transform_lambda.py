import json
import boto3
import os
import logging
import urllib.parse
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
OUTPUT_BUCKET = os.environ.get('OUTPUT_BUCKET', '')


def lambda_handler(event, context):
    """
    Triggered by S3 PUT event on input bucket.
    Reads raw JSON file → transforms → writes enriched JSON to output bucket.
    """
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key    = urllib.parse.unquote_plus(record['s3']['object']['key'])

        logger.info("Processing file: s3://%s/%s", bucket, key)

        try:
            obj = s3.get_object(Bucket=bucket, Key=key)
            raw_data = json.loads(obj['Body'].read().decode('utf-8'))

            transformed = transform(raw_data)

            output_key = f"processed/{datetime.utcnow().strftime('%Y/%m/%d')}/{key.split('/')[-1]}"
            s3.put_object(
                Bucket=OUTPUT_BUCKET,
                Key=output_key,
                Body=json.dumps(transformed, indent=2),
                ContentType='application/json'
            )
            logger.info("Written to: s3://%s/%s", OUTPUT_BUCKET, output_key)

        except Exception as e:
            logger.error("Error processing %s: %s", key, str(e))
            raise

    return {'statusCode': 200, 'processed': len(event['Records'])}


def transform(data):
    """Transform raw record: normalise, enrich with metadata."""
    if isinstance(data, list):
        return [enrich(record) for record in data]
    return enrich(data)


def enrich(record):
    return {
        **record,
        'processed_at': datetime.utcnow().isoformat(),
        'pipeline_version': '1.0',
        'source': 'aws-serverless-pipeline'
    }
