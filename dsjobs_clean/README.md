# Data Cleaning & Transformation

## Goal
The goal of this project is to clean and prepare data from the `uncleaned_ds_jobs` table for analysis.

## Step-by-Step Data Cleaning Process

### Step 0: Initial Exploration
- **Description of Dataset**: Checked column names, data types, and number of rows.
  ```sql
  DESCRIBE uncleaned_ds_jobs;
  SELECT COUNT(*) FROM uncleaned_ds_jobs; -- The data contains 672 rows.
