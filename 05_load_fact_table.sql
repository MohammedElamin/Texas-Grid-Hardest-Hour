-- 05_load_fact_table.sql
-- Cleans the staging data and loads it into fact_grid_hourly:
--   * removes thousands commas, trims spaces, turns empty text into NULL, casts to numbers
--   * converts the text date ('15Jun2025') into a real DATE
--   * keeps only June to September, 2019 to 2026

USE texas_grid;

INSERT INTO fact_grid_hourly
  (local_date, hour_no, demand_forecast_mw, demand_mw,
   net_generation_mw, sum_ng_mw, solar_mw, exports_mw)
SELECT
  d                                                          AS local_date,
  CAST(`Hour` AS UNSIGNED)                                   AS hour_no,
  CAST(NULLIF(TRIM(REPLACE(`Demand forecast`, ',', '')), '') AS SIGNED) AS demand_forecast_mw,
  CAST(NULLIF(TRIM(REPLACE(`Demand`,          ',', '')), '') AS SIGNED) AS demand_mw,
  CAST(NULLIF(TRIM(REPLACE(`Net generation`,  ',', '')), '') AS SIGNED) AS net_generation_mw,
  CAST(NULLIF(TRIM(REPLACE(`Sum (NG)`,        ',', '')), '') AS SIGNED) AS sum_ng_mw,
  CAST(NULLIF(TRIM(REPLACE(`NG: SUN`,         ',', '')), '') AS SIGNED) AS solar_mw,
  CAST(NULLIF(TRIM(REPLACE(`Sum (Exports)`,   ',', '')), '') AS SIGNED) AS exports_mw
FROM (
  SELECT s.*, STR_TO_DATE(`Local date`, '%d%b%Y') AS d   -- text '15Jun2025' -> real date
  FROM stg_grid s
) t
WHERE MONTH(d) BETWEEN 6 AND 9          -- June to September
  AND YEAR(d)  BETWEEN 2019 AND 2026;   -- first full solar summer to now
