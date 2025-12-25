# Clinical Trials Analytics Pipeline (AWS Serverless)

## Objective
To implement an automated, serverless data analytics pipeline that ingests public clinical trial data from the **ClinicalTrials.gov API**, transforms it into an analysis-ready dataset, and produces daily summary analytics.

This pipeline is designed to mimic real-world analytics workflows, emphasizing reproducibility, automation, and data quality.

## Architecture
```
EventBridge (schedule)
        ↓
Ingest Lambda
        ↓
S3 (raw data)
        ↓
Transform Lambda
        ↓
S3 (curated CSV)
        ↓
Metrics Lambda
        ↓
S3 (analytics reports)
```
