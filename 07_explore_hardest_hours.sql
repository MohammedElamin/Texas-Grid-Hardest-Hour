-- 07_explore_hardest_hours.sql
-- Exploration before building the view.
-- Net load = demand - solar. The "hardest hour" of a day is the hour with the highest net load.
-- Hours are hour-ending (hour 21 = 8-9 PM).

USE texas_grid;

-- The 10 days with the highest net load, and the hour it happened
-- ROW_NUMBER() ranks the hours inside each day; rn = 1 is the hardest hour of that day.
WITH Ranked AS
(
  SELECT local_date, hour_no, solar_mw,
         demand_mw - solar_mw AS net_load_mw,
         ROW_NUMBER() OVER (PARTITION BY local_date
                            ORDER BY demand_mw - solar_mw DESC) AS rn
  FROM fact_grid_hourly
)
SELECT local_date, hour_no, solar_mw, net_load_mw, rn
FROM Ranked
WHERE rn = 1
ORDER BY net_load_mw DESC
LIMIT 10;

-- A regular solar day: average solar output by hour
-- (used to check the hour convention: solar should be zero at night)
SELECT hour_no, ROUND(AVG(solar_mw)) AS avg_solar_mw
FROM fact_grid_hourly
GROUP BY hour_no
ORDER BY hour_no;
