import csv
import json
import os
from datetime import datetime, timezone
from statistics import mean, median

import boto3

s3 = boto3.client("s3")


def _list_keys(bucket: str, prefix: str):
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            yield obj


def _latest_key(bucket: str, prefix: str, suffix: str):
    candidates = []
    for obj in _list_keys(bucket, prefix):
        key = obj["Key"]
        if key.endswith(suffix):
            candidates.append((obj["LastModified"], key))
    if not candidates:
        return None
    candidates.sort(key=lambda x: x[0], reverse=True)
    return candidates[0][1]


def _to_int(x):
    if x is None:
        return None
    s = str(x).strip()
    if s == "":
        return None
    try:
        return int(float(s))
    except Exception:
        return None


def lambda_handler(event, context):
    bucket = os.environ["BUCKET_NAME"]

    now = datetime.now(timezone.utc)
    dt = now.strftime("%Y-%m-%d")
    ts = now.strftime("%Y-%m-%dT%H-%M-%SZ")

    # Find the latest curated CSV for today (or latest available if today missing)
    prefix_today = f"curated/clinicaltrials/dt={dt}/"
    curated_key = _latest_key(bucket, prefix_today, "trials.csv")

    if curated_key is None:
        # fallback: find latest trials.csv anywhere under curated/clinicaltrials/
        curated_key = _latest_key(bucket, "curated/clinicaltrials/", "trials.csv")

    if curated_key is None:
        raise RuntimeError("No curated trials.csv found in S3. Run transform first.")

    obj = s3.get_object(Bucket=bucket, Key=curated_key)
    text = obj["Body"].read().decode("utf-8")

    reader = csv.DictReader(text.splitlines())
    rows = list(reader)

    n = len(rows)
    if n == 0:
        raise RuntimeError("Curated CSV has 0 rows.")

    # Columns we expect from your transform step
    key_cols = ["nct_id", "overall_status", "phase", "enrollment", "start_date", "completion_date", "study_type", "conditions"]

    # Missingness
    missing = {c: 0 for c in key_cols}
    for r in rows:
        for c in key_cols:
            v = r.get(c)
            if v is None or str(v).strip() == "":
                missing[c] += 1

    missing_pct = {c: round(missing[c] / n * 100, 2) for c in key_cols}

    # Status breakdown
    status_counts = {}
    for r in rows:
        s = (r.get("overall_status") or "").strip() or "UNKNOWN"
        status_counts[s] = status_counts.get(s, 0) + 1
    status_pct = {k: round(v / n * 100, 2) for k, v in status_counts.items()}

    # Termination rate overall (simple)
    terminated = status_counts.get("TERMINATED", 0)
    term_rate = terminated / n

    # Termination rate by phase
    by_phase = {}
    for r in rows:
        ph = (r.get("phase") or "").strip() or "UNKNOWN"
        st = (r.get("overall_status") or "").strip() or "UNKNOWN"
        d = by_phase.setdefault(ph, {"n": 0, "terminated": 0})
        d["n"] += 1
        if st == "TERMINATED":
            d["terminated"] += 1

    term_rate_by_phase = {}
    for ph, d in by_phase.items():
        term_rate_by_phase[ph] = round(d["terminated"] / d["n"], 4) if d["n"] else None

    # Enrollment stats (numeric where possible)
    enroll_vals = []
    for r in rows:
        iv = _to_int(r.get("enrollment"))
        if iv is not None:
            enroll_vals.append(iv)

    enrollment_stats = None
    if enroll_vals:
        enroll_vals_sorted = sorted(enroll_vals)
        enrollment_stats = {
            "n_nonnull": len(enroll_vals),
            "min": enroll_vals_sorted[0],
            "max": enroll_vals_sorted[-1],
            "mean": round(mean(enroll_vals), 2),
            "median": median(enroll_vals),
        }

    summary = {
        "timestamp_utc": ts,
        "source_curated_csv": f"s3://{bucket}/{curated_key}",
        "n_trials": n,
        "status_counts": status_counts,
        "status_pct": status_pct,
        "termination_rate": round(term_rate, 4),
        "termination_rate_by_phase": term_rate_by_phase,
        "enrollment_stats": enrollment_stats,
        "missing_counts": missing,
        "missing_pct": missing_pct,
    }

    out_key = f"analytics/clinicaltrials/dt={dt}/summary.json"
    s3.put_object(
        Bucket=bucket,
        Key=out_key,
        Body=json.dumps(summary, indent=2).encode("utf-8"),
        ContentType="application/json",
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"ok": True, "summary_s3_path": f"s3://{bucket}/{out_key}"}),
    }
