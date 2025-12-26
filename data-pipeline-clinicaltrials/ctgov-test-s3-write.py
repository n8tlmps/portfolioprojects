import json
import os
from datetime import datetime, timezone
from urllib.request import Request, urlopen

import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):
    bucket = os.environ["BUCKET_NAME"]

    now = datetime.now(timezone.utc)
    dt = now.strftime("%Y-%m-%d")
    ts = now.strftime("%Y-%m-%dT%H-%M-%SZ")
    run_id = ts

    # NOTE: This is a simple “proof it works” API call.
    # We fetch a small number of studies to keep it fast.
    #
    # If ClinicalTrials.gov changes their API path/params, you'll get an HTTP error.
    # In that case, paste the error here and I’ll adjust the URL.

    url = (
        "https://clinicaltrials.gov/api/v2/studies?"
        "pageSize=25"
    )

    req = Request(url, headers={"User-Agent": "ctgov-lambda/1.0"})
    with urlopen(req, timeout=20) as resp:
        body = resp.read().decode("utf-8")

    # Save raw
    raw_key = f"raw/clinicaltrials/dt={dt}/run_id={run_id}/studies.json"
    s3.put_object(
        Bucket=bucket,
        Key=raw_key,
        Body=body.encode("utf-8"),
        ContentType="application/json"
    )

    # Create a small manifest
    parsed = json.loads(body)
    n_studies = len(parsed.get("studies", [])) if isinstance(parsed, dict) else None

    manifest = {
        "timestamp_utc": ts,
        "source": "clinicaltrials.gov",
        "url": url,
        "raw_s3_path": f"s3://{bucket}/{raw_key}",
        "n_studies_in_payload": n_studies,
    }

    manifest_key = f"manifests/clinicaltrials/dt={dt}/run_{run_id}.json"
    s3.put_object(
        Bucket=bucket,
        Key=manifest_key,
        Body=json.dumps(manifest, indent=2).encode("utf-8"),
        ContentType="application/json"
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "ok": True,
            "raw_s3_path": f"s3://{bucket}/{raw_key}",
            "manifest_s3_path": f"s3://{bucket}/{manifest_key}",
            "n_studies_in_payload": n_studies,
        })
    }
