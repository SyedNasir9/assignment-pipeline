import os
import json
import boto3
from datetime import datetime, timezone
from dateutil import parser

S3_RAW_BUCKET = os.environ.get("RAW_BUCKET")
S3_REPORT_BUCKET = os.environ.get("REPORT_BUCKET")
REGION = os.environ.get("AWS_REGION", "us-east-1")

s3 = boto3.client("s3", region_name=REGION)

def list_objects_for_date(bucket, prefix):
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            yield obj["Key"]

def read_s3_object(bucket, key):
    r = s3.get_object(Bucket=bucket, Key=key)
    return r["Body"].read().decode("utf-8")

def aggregate_data(raw_text):
    # Simple aggregation: count lines / JSON objects
    # Expecting newline-separated JSON or CSV lines
    lines = [l for l in raw_text.splitlines() if l.strip()]
    return {"records": len(lines)}

def write_report(bucket, key, data):
    s3.put_object(Bucket=bucket, Key=key, Body=json.dumps(data).encode("utf-8"))

def main():
    # Use today's date (UTC) or an env override
    run_date = os.environ.get("RUN_DATE") or datetime.now(timezone.utc).strftime("%Y-%m-%d")
    prefix = f"raw-data/{run_date}/"
    print(f"Processing prefix {prefix}")
    total_records = 0
    file_count = 0
    for key in list_objects_for_date(S3_RAW_BUCKET, prefix):
        file_count += 1
        print(f"Reading {key}")
        content = read_s3_object(S3_RAW_BUCKET, key)
        agg = aggregate_data(content)
        total_records += agg["records"]

    report = {
        "date": run_date,
        "file_count": file_count,
        "total_records": total_records,
        "generated_at": datetime.now(timezone.utc).isoformat()
    }
    report_key = f"reports/{run_date}.json"
    write_report(S3_REPORT_BUCKET, report_key, report)
    print("Report written to", report_key)
    print(report)

if __name__ == "__main__":
    main()
