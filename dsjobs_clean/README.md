# Data Cleaning & Transformation

## Goal
The goal of this project is to clean and prepare data from the `uncleaned_ds_jobs` table for analysis.

## Step-by-Step Data Cleaning Process

### Step 0: Initial Exploration
- **Description of Dataset**: Checked column names, data types, and number of rows.
  ```sql
  DESCRIBE uncleaned_ds_jobs;
  SELECT COUNT(*) FROM uncleaned_ds_jobs; -- The data contains 672 rows.
  ```
### Step 1: Handling Duplicates and Missing Values
- **Checking Duplicates**: Identified and removed duplicate rows
  ```sql
  SELECT `Job Title`,
	  `Salary Estimate`,
    `Job Description`,
    `Rating`,
    `Company Name`,
    `Location`,
    `Headquarters`,
    `Size`,
    `Founded`,
    `Type of ownership`,
    `Industry`,
    `Sector`,
    `Revenue`,
    `Competitors`,
    COUNT(*) AS count
FROM uncleaned_ds_jobs
GROUP BY `Job Title`,
	`Salary Estimate`,
    `Job Description`,
    `Rating`,
    `Company Name`,
    `Location`,
    `Headquarters`,
    `Size`,
    `Founded`,
    `Type of ownership`,
    `Industry`,
    `Sector`,
    `Revenue`,
    `Competitors`
HAVING count > 1; -- The data contains 18 duplicate rows.
