-- 03_check_staging_data.sql
-- Checks that the import wizard loaded the raw file correctly.

USE texas_grid;

-- Total number of rows loaded
SELECT COUNT(*)
FROM stg_grid;

-- Column names and types
DESCRIBE stg_grid;

-- First rows
SELECT *
FROM stg_grid
LIMIT 5;

-- A few key columns
SELECT Region, `Local time`, Demand, `NG: Sun`
FROM stg_grid
LIMIT 10;

-- Rows per year (the year is the last 4 characters of the text date, e.g. 15Jun2025)
SELECT RIGHT(`Local date`, 4) AS yr, COUNT(*)
FROM stg_grid
GROUP BY yr
ORDER BY yr;

-- Spot check: one month
SELECT *
FROM stg_grid
WHERE RIGHT(`Local date`, 7) = 'Jun2025'
LIMIT 25;
