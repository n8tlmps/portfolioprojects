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

## AWS Services Used
- **AWS Lambda** - stateless compute for ingestion, transformation, and analytics
- **Amazon S3** - versioned data lake (raw, curated, analytics layers)
- **Amazon EventBridge** - scheduled orchestration
- **Amazon CloudWatch** - logging and monitoring

## Data Source
- ClinicalTrials.gov API (v2)
- Public, openly metadata on registered clinical trials

Each pipeline run retrieves a subset of trials and updates downstream datasets automatically.

## Data Layers
The project follows a standard analytics data-lake pattern:

### Raw Layer (`raw/`)
- Immutable snapshots of API responses
- Stored as JSON
- Preserves original structure for reproducibility and auditing

### Curated Layer (`curated/`)
- Flattened, analysis-ready table (CSV)
- One row per clinical trial
- Cleaned and standardized fields

Key columns include:
- `nct_id`
- `overall_status`
- `phase`
- `enrollment`
- `start_date`
- `completion_date`
- `study_date`
- `conditions`

### Analytics Layer (`analytics/`)
- Automatically generated summary reports (JSON)
- Designed for downstream dashboards or notebooks
