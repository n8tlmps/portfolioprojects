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
## Lambda Functions
The pipeline is implemented using three purpose-built AWS Lambda functions, each responsible for a single stage of the analytics workflow. Separating responsibilities in this way improves reliability, debuggability, and scalability.

### 1. Ingest Lambda (`ctgov-ingest`)
This function is responsible for data acquisition.
- Triggered on a schedule via Amazon EventBridge
- Calls the ClinicalTrials.gov API
- Retrieves a batch of clinical trial records
- Writes the raw, unmodified JSON response to Amazon S3
- Generates a lightweight manifest file containing metadata about the run (timestamp, record count, source)

This design preserves raw data for reproducibility and allows downstream processing to be rerun without re-ingesting the source data.

### 2. Transform Lambda (`ctgov-transform-csv`)
This function performs data preparation and standardization.
- Triggered automatically on the same schedule as ingestion
- Reads the most recent raw JSON file from S3
- Flattens nested API fields into a tabular structure
- Performs light cleaning and normalization
- Writes an analysis-ready CSV to the curated S3 layer

The output of this function serves as the primary dataset for downstream analytics and modeling.

### 3. Metrics Lambda (`ctgov-metrics`)
This function generates analytics outputs.
- Triggered on a schedule after data transformation
- Reads the curated CSV dataset from S3
- Computes summary statistics and quality checks, including:
  - Trial status distributions
  - Termination rates (overall and by phase)
  - Enrollment statistics
  - Missingness metrics for key fields
- Writes a structured JSON analytics report to the S3 analytics layer.

This step demonstrates how automated pipelines can produce insight-ready outputs without manual analysis.

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

## Automated Analytics
A scheduled analytics step computes:
- Total number of trials
- Trial status distribution (Completed, Terminated, Recruiting, etc.)
- Termination rate overall and by phase
- Enrollment statistics (min, max, mean, median)
- Missingness metrics for key fields

These metrics are written to:
```
analytics/clinicaltrials/dt=YYYY-MM-DD/summary.json
```

## Scheduling & Automation
- The pipeline is orchestrated using **EventBridge**.
- During development, jobs run every 5 minutes
- In production, the schedule can be reduced to daily runs.

# Summary and Takeaways
Learning about data migration and the tools used to build an effective scheduled batch analytics pipeline felt very important to me as a statistics and data science student. Data science, analytics, and informatics relies on reliable and repeatable data ingestion, so it was relieving to discover that minimial infrastructure can still implement scalable analytics systems with tools like AWS Lambda, S3, and EventBridge.

