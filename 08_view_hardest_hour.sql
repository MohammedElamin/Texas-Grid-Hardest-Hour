-- 08_view_hardest_hour.sql
-- A saved query (view): the hardest hour of each day.
-- Power BI uses this together with the hourly fact table.

USE texas_grid;

CREATE OR REPLACE VIEW v_hardest_hour AS
WITH ranked AS (
  SELECT local_date, hour_no, solar_mw, demand_mw,
         demand_mw - solar_mw AS net_load_mw,
         ROW_NUMBER() OVER (PARTITION BY local_date
                            ORDER BY demand_mw - solar_mw DESC) AS rn
  FROM fact_grid_hourly
)
SELECT local_date, YEAR(local_date) AS yr, hour_no AS hardest_hour, net_load_mw
FROM ranked
WHERE rn = 1;

-- Check: should return 976 rows (122 summer days x 8 years)
SELECT COUNT(*)
FROM v_hardest_hour;
