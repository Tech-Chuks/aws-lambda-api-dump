import os
import json
import boto3
import urllib.request
from datetime import datetime, timezone

s3 = boto3.client("s3")

def lambda_handler(event, context):
    # Load config from environment
    bucket_name = os.environ["BUCKET_NAME"]
    object_prefix = os.environ.get("OBJECT_PREFIX", "results/")
    target_url = os.environ.get("TARGET_URL", "https://api.open-meteo.com/v1/forecast?latitude=35&longitude=139&hourly=temperature_2m")

    try:
        # Fetch from API
        with urllib.request.urlopen(target_url, timeout=10) as response:
            data = json.loads(response.read())

        # Timestamped object key
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        key = f"{object_prefix}weather-{timestamp}.json"

        # Write to S3
        s3.put_object(
            Bucket=bucket_name,
            Key=key,
            Body=json.dumps(data),
            ContentType="application/json"
        )

        print(f"SUCCESS: Wrote object to s3://{bucket_name}/{key}")
        return {"status": "ok", "bucket": bucket_name, "key": key}

    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise

