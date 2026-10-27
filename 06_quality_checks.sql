-- 06_quality_checks.sql
-- Checks the clean table after loading.

USE texas_grid;

-- Look at the first rows
SELECT *
FROM fact_grid_hourly
LIMIT 10;

-- All rows loaded? Each year should have 2,928 hours (122 days x 24 hours)
SELECT YEAR(local_date) AS yr, COUNT(*) AS hours, COUNT(DISTINCT local_date) AS days
FROM fact_grid_hourly
GROUP BY yr
ORDER BY yr;

-- Missing values
SELECT SUM(solar_mw IS NULL)           AS null_solar,
       SUM(demand_forecast_mw IS NULL) AS null_forecast,
       SUM(exports_mw IS NULL)         AS null_exports
FROM fact_grid_hourly;

-- Odd values (minimum and maximum)
SELECT MIN(demand_mw), MAX(demand_mw), MIN(solar_mw), MAX(solar_mw)
FROM fact_grid_hourly;
