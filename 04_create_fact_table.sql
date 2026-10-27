-- 04_create_fact_table.sql
-- Clean hourly table with only the columns the analysis needs, with proper types.
-- Columns kept: Local date, Hour, Demand forecast, Demand, Net generation,
-- Sum (NG), NG: SUN (solar), Sum (Exports).

USE texas_grid;
DROP TABLE IF EXISTS fact_grid_hourly;

CREATE TABLE fact_grid_hourly (
  local_date          DATE              NOT NULL,
  hour_no             TINYINT UNSIGNED  NOT NULL,
  demand_forecast_mw  INT               NULL,
  demand_mw           INT               NOT NULL,
  net_generation_mw   INT               NULL,
  sum_ng_mw           INT               NULL,
  solar_mw            INT               NULL,
  exports_mw          INT               NULL,
  PRIMARY KEY (local_date, hour_no)
);
