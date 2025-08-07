-- Step 0: Initial Exploration
DESCRIBE ds_jobs;
SELECT COUNT(*) FROM ds_jobs; -- The data contains 672 rows.

-- Step 1: Handling Duplicates and MIssing Values
-- i. check for duplicates
SELECT
  `Job Title`,
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
FROM ds_jobs
GROUP BY
  `Job Title`,
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
HAVING count > 1; -- ther are 18 duplicate rows

-- ii. delete duplicates based on the specified columns, keeping the row with the maximum index
-- Delete duplicates based on the specified columns, keeping the row with the maximum index
DELETE u1
FROM ds_jobs u1
LEFT JOIN (
   SELECT MAX(`index`) AS max_index
   FROM ds_jobs
   GROUP BY 
       `Job Title`,
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
) u2 ON u1.`index` = u2.max_index
WHERE u2.max_index IS NULL;

-- Check the number of rows after removing duplicates
SELECT COUNT(*) FROM ds_jobs; -- After deleting duplicates, there are 659 rows remaining

-- iii. Check for missing values... we can see that 'Unknown', '-1', and null are used as placeholders for missing values
SELECT DISTINCT(`Job Title`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Job Title` LIKE '%Unknown%' OR `Job Title` IS NULL OR `Job Title` = -1
GROUP BY `Job Title`
ORDER BY count DESC;
-- Job Title contains 0 missing values

SELECT DISTINCT(`Salary Estimate`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Salary Estimate` LIKE '%Unknown%' OR `Salary Estimate` IS NULL OR `Salary Estimate` = -1
GROUP BY `Salary Estimate`
ORDER BY count DESC;
-- Salary Estimate contains 0 missing values

SELECT DISTINCT(`Job Description`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Job Description` LIKE '%Unknown%' OR `Job Description` IS NULL OR `Job Description` = -1
GROUP BY `Job Description`
ORDER BY count DESC;
-- Job Description contains 0 missing values

SELECT DISTINCT(`Rating`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Rating` LIKE '%Unknown%' OR `Rating` IS NULL OR `Rating` = -1
GROUP BY `Rating`
ORDER BY count DESC;
-- Rating contains 39 '-1's.

SELECT DISTINCT(`Company Name`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Company Name` LIKE '%Unknown%' OR `Company Name` IS NULL OR `Company Name` = -1
GROUP BY `Company Name`
ORDER BY count DESC;
-- Company Name contains 0 missing values

SELECT DISTINCT(`Location`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Location` LIKE '%Unknown%' OR `Location` IS NULL OR `Location` = -1
GROUP BY `Location`
ORDER BY count DESC;
-- Location contains 0 missing values

SELECT DISTINCT(`Headquarters`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Headquarters` LIKE '%Unknown%' OR `Headquarters` IS NULL OR `Headquarters` = -1
GROUP BY `Headquarters`
ORDER BY count DESC;
-- Headquarters contains 20 '-1's

SELECT DISTINCT(`Size`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Size` LIKE '%Unknown%' OR `Size` IS NULL OR `Size` = -1
GROUP BY `Size`
ORDER BY count DESC;
-- Size contains 16 '-1's, 17 unknown... a total of 33 missing values

SELECT DISTINCT(`Founded`),
   COUNT(*) as count
FROM ds_jobs
WHERE `Founded` LIKE '%Unknown%' OR `Founded` IS NULL OR `Founded` = -1
GROUP BY `Founded`
ORDER BY count DESC;
-- Founded contains 107 '-1's

SELECT DISTINCT(`Type of Ownership`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Type of Ownership` LIKE '%Unknown%' OR `Type of Ownership` IS NULL OR `Type of Ownership` = -1
GROUP BY `Type of Ownership`
ORDER BY count DESC;
-- Type of Ownership contains 16 '-1's, and 4 Unknown

SELECT DISTINCT(`Industry`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Industry` LIKE '%Unknown%' OR `Industry` IS NULL OR `Industry` = -1
GROUP BY `Industry`
ORDER BY count desc;
-- Industry contains 60 '-1's

SELECT DISTINCT(`Sector`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Sector` LIKE '%Unknown%' OR `Sector` IS NULL OR `Sector` = -1
GROUP BY `Sector`
ORDER BY count DESC;
-- Sector contains 60 '-1's

SELECT DISTINCT(`Revenue`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Revenue` LIKE '%Unknown%' OR `Revenue` IS NULL OR `Revenue` = -1
GROUP BY `Revenue`
ORDER BY count DESC;
-- Revenue contains 212 'Unknown/Non-Applicable' and 16 '-1's

SELECT DISTINCT(`Competitors`),
   COUNT(*) AS count
FROM ds_jobs
WHERE `Competitors` LIKE '%Unknown%' OR `Competitors` IS NULL OR `Competitors` = -1
GROUP BY `Competitors`
ORDER BY count DESC;
-- Competitors contains 488 '-1's

-- Step 2: Transform all missing values into null values
UPDATE ds_jobs
SET
   `Rating` = CASE WHEN `Rating` = '-1' THEN NULL ELSE `Rating` END,
   `Headquarters` = CASE WHEN `Headquarters` = '-1' THEN NULL ELSE `Headquarters` END,
   `Size` = CASE WHEN `Size` = '-1' OR `Size` LIKE '%Unknown%' THEN NULL ELSE `Size` END,
   `Founded` = CASE WHEN `Founded` = '-1' THEN NULL ELSE `Founded` END,
   `Type of ownership` = CASE WHEN `Type of ownership` = '-1' OR `Type of ownership` LIKE '%Unknown%' THEN NULL ELSE `Type of ownership` END,
   `Industry` = CASE WHEN `Industry` = '-1' THEN NULL ELSE `Industry` END,
   `Sector` = CASE WHEN `Sector` = '-1' THEN NULL ELSE `Sector` END,
   `Revenue` = CASE WHEN `Revenue` = '-1' OR `Revenue` LIKE '%Unknown%' THEN NULL ELSE `Revenue` END,
   `Competitors` = CASE WHEN `Competitors` = '-1' THEN NULL ELSE `Competitors` END;
   
-- Let's see how much of our data is missing now.
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN `Rating` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Headquarters` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Size` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Founded` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Type of ownership` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Industry` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Sector` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Revenue` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100,
    SUM(CASE WHEN `Competitors` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100
FROM ds_jobs; -- Competitors is mussing more than 70% and Revenue is missing over 30%

-- Step 3: Correcting Company Name
SELECT `Company Name`
FROM ds_jobs LIMIT 5; -- `Company Name` contains mixed values... the rating is appended to the company name... let's fix it.

UPDATE ds_jobs
SET `Company Name` = REGEXP_REPLACE(`Company Name`, '[0-9]+(\.[0-9]+)?', '');

-- Step 4: Creating new Salary columns
-- The `Salary Estimate` column contains strings.
-- need to extract
	-- i. min_salary
    -- ii. max_salary
    -- iii. avg_salary
    -- iv. salary_clean
ALTER TABLE ds_jobs ADD COLUMN min_salaryK INT;
ALTER TABLE ds_jobs ADD COLUMN max_salaryK INT;
ALTER TABLE ds_jobs ADD COLUMN avg_salaryK INT;
ALTER TABLE ds_jobs ADD COLUMN salary_cleanK TEXT;
-- We need to remove the '$' and the non-numeric values
UPDATE ds_jobs
SET min_salaryK = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(`Salary Estimate`, '-', 1), '$', -1), '[^0-9]', '') AS UNSIGNED),
   max_salaryK = CAST(REGEXP_REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(`Salary Estimate`, '-', -1), '$', -1), '[^0-9]', '') AS UNSIGNED),
   avg_salaryK = (min_salaryK + max_salaryK) / 2,
   salary_cleanK = CONCAT(min_salaryK, '-', max_salaryK);
   
select * from ds_jobs limit 5;

-- Step 5: Creating new columns from `Location`
SELECT DISTINCT(`Location`), COUNT(*)
FROM ds_jobs
GROUP BY `Location` -- We can see that most Locations list a city followed by ', (state abbrev.)'
ORDER BY `Location` ASC;

ALTER TABLE ds_jobs ADD COLUMN job_state VARCHAR(10);
UPDATE ds_jobs
SET job_state =
   CASE
   WHEN Location = 'California' THEN 'CA'
       WHEN Location = 'New Jersey' THEN 'NJ'
       WHEN Location = 'Remote' THEN 'Remote'
       WHEN Location = 'Texas' THEN 'TX'
       WHEN Location = 'United States' THEN 'Across US'
       WHEN Location = 'Utah' THEN 'UT'
       ELSE
           -- For other locations, attempt to extract state abbreviation
           CASE
               WHEN LOCATE(',', Location) > 0 THEN
                   SUBSTRING_INDEX(Location, ',', -1)  -- Get the part after the comma
               ELSE 'Unknown'
           END
   END;

-- checking for nulls
SELECT COUNT(job_state) FROM ds_jobs
WHERE job_state IS NULL;
-- there are no null values

-- Step 6: Creating new columns from `Headquarters`
-- this helps identify if headquarters are in the same state as job location
SELECT DISTINCT(`Headquarters`), COUNT(*)
FROM ds_jobs
GROUP BY `Headquarters` -- We can see that most Headquarters list a city followed by ', state'
ORDER BY `Headquarters` ASC;

ALTER TABLE ds_jobs ADD COLUMN hq_state VARCHAR(20);
UPDATE ds_jobs
SET hq_state =
   CASE
   	WHEN LOCATE(',', `Headquarters`) > 0 THEN SUBSTRING_INDEX(`Headquarters`, ',', -1)  -- Get the part after the comma
   	ELSE 'Unknown'
	END;
           
ALTER TABLE ds_jobs ADD COLUMN same_state TINYINT(1);
UPDATE ds_jobs
SET same_state = IF(job_state = hq_state, 1, 0);

-- checking for nulls
SELECT COUNT(same_state) FROM ds_jobs
WHERE same_state IS NULL;
-- there are no null values

-- Step 7: Creating new columns on Data Science skills
-- let's extract the skills from `Job Description`
ALTER TABLE ds_jobs
ADD COLUMN machine_learning TINYINT(1),
ADD COLUMN python TINYINT(1),
ADD COLUMN `sql` TINYINT(1),
ADD COLUMN excel TINYINT(1),
ADD COLUMN hadoop TINYINT(1),
ADD COLUMN spark TINYINT(1),
ADD COLUMN aws TINYINT(1),
ADD COLUMN tableau TINYINT(1),
ADD COLUMN power_bi TINYINT(1),
ADD COLUMN big_data TINYINT(1);

UPDATE ds_jobs
SET
   machine_learning = CASE WHEN `Job Description` LIKE '%machine learning%' THEN 1 ELSE 0 END,
   python = CASE WHEN `Job Description` LIKE '%python%' THEN 1 ELSE 0 END,
   `sql` = CASE WHEN `Job Description` LIKE '%sql%' THEN 1 ELSE 0 END,
   excel = CASE WHEN `Job Description` LIKE '%excel%' THEN 1 ELSE 0 END,
   hadoop = CASE WHEN `Job Description` LIKE '%hadoop%' THEN 1 ELSE 0 END,
   spark = CASE WHEN `Job Description` LIKE '%spark%' THEN 1 ELSE 0 END,
   aws = CASE WHEN `Job Description` LIKE '%aws%' THEN 1 ELSE 0 END,
   tableau = CASE WHEN `Job Description` LIKE '%tableau%' THEN 1 ELSE 0 END,
   power_bi = CASE WHEN `Job Description` LIKE '%power bi%' THEN 1 ELSE 0 END,
   big_data = CASE WHEN `Job Description` LIKE '%big data%' THEN 1 ELSE 0 END;
   
   