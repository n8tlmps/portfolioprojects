import csv
import io
import json
import os
from datetime import datetime, timezone

import boto3

s3 = boto3.client("s3")


def _get(d, path, default=None):
    """Safely get nested dict values. path like 'a.b.c'."""
    cur = d
    for part in path.split("."):
        if isinstance(cur, dict) and part in cur:
            cur = cur[part]
        else:
            return default
    return cur


def _as_str_list(x):
    if x is None:
        return []
    if isinstance(x, list):
        return [str(v) for v in x if v is not None]
    return [str(x)]


def _pick_latest_raw_key_for_today(bucket: str, dt: str) -> str:
    """
    Find latest raw studies.json under:
    raw/clinicaltrials/dt=YYYY-MM-DD/run_id=.../studies.json
    """
    prefix = f"raw/clinicaltrials/dt={dt}/"
    paginator = s3.get_paginator("list_objects_v2")

    candidates = []
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            if key.endswith("/studies.json"):
                candidates.append((obj["LastModified"], key))

    if not candidates:
        raise RuntimeError(f"No raw studies.json found under s3://{bucket}/{prefix}")

    candidates.sort(key=lambda x: x[0], reverse=True)
    return candidates[0][1]


def lambda_handler(event, context):
    bucket = os.environ["BUCKET_NAME"]

    now = datetime.now(timezone.utc)
    dt = now.strftime("%Y-%m-%d")
    ts = now.strftime("%Y-%m-%dT%H-%M-%SZ")

    # 1) Find latest raw file for today
    raw_key = _pick_latest_raw_key_for_today(bucket, dt)

    # 2) Download raw JSON
    raw_obj = s3.get_object(Bucket=bucket, Key=raw_key)
    raw_text = raw_obj["Body"].read().decode("utf-8")
    payload = json.loads(raw_text)

    studies = payload.get("studies", [])
    if not isinstance(studies, list):
        raise RuntimeError("Unexpected payload shape: 'studies' is not a list")

    # 3) Flatten into CSV rows
    # Keep the first version of the schema small + biostats-friendly.
    columns = [
        "nct_id",
        "overall_status",
        "phase",
        "enrollment",
        "start_date",
        "completion_date",
        "study_type",
        "conditions",
    ]

    out = io.StringIO()
    writer = csv.DictWriter(out, fieldnames=columns)
    writer.writeheader()

    for st in studies:
        nct_id = _get(st, "protocolSection.identificationModule.nctId")
        overall_status = _get(st, "protocolSection.statusModule.overallStatus")

        # phase is often a list; join nicely
        phases = _as_str_list(_get(st, "protocolSection.designModule.phases"))
        phase = ";".join(phases) if phases else None

        # enrollment can appear in different places; handle both
        enrollment = _get(st, "protocolSection.designModule.enrollmentInfo.count")
        if enrollment is None:
            enrollment = _get(st, "protocolSection.designModule.enrollmentInfo.enrollmentCount")

        # dates are nested structs in v2; try common spots
        start_date = _get(st, "protocolSection.statusModule.startDateStruct.date")
        completion_date = _get(st, "protocolSection.statusModule.completionDateStruct.date")

        study_type = _get(st, "protocolSection.designModule.studyType")

        # conditions is a list
        conds = _as_str_list(_get(st, "protocolSection.conditionsModule.conditions"))
        conditions = ";".join(conds) if conds else None

        writer.writerow({
            "nct_id": nct_id,
            "overall_status": overall_status,
            "phase": phase,
            "enrollment": enrollment,
            "start_date": start_date,
            "completion_date": completion_date,
            "study_type": study_type,
            "conditions": conditions,
        })

    csv_bytes = out.getvalue().encode("utf-8")

    # 4) Save curated CSV
    curated_key = f"curated/clinicaltrials/dt={dt}/trials.csv"
    s3.put_object(
        Bucket=bucket,
        Key=curated_key,
        Body=csv_bytes,
        ContentType="text/csv"
    )

    # Optional: manifest for transform
    manifest_key = f"manifests/clinicaltrials_transform/dt={dt}/run_{ts}.json"
    manifest = {
        "timestamp_utc": ts,
        "raw_s3_path": f"s3://{bucket}/{raw_key}",
        "curated_s3_path": f"s3://{bucket}/{curated_key}",
        "n_rows": len(studies),
        "columns": columns,
    }
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
            "curated_s3_path": f"s3://{bucket}/{curated_key}",
            "n_rows": len(studies),
        })
    }
