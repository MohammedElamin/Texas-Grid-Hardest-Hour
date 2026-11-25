# Texas Grid: Which Hour Is the Hardest?

On hot summer days in Texas, which hour is the hardest for the power plants to supply, and has it moved as solar grew?

**Short answer:** in 2019 the hardest hour was most often 4–5 PM (about 65% of days). By 2026 it was 8–9 PM (about 78% of days), four hours later. This coincides with the growth of solar, but this analysis cannot show that solar caused it.

![Page 2: how the hardest hour moved](images/page2.png)

## The question and the metric

- **Net load** = demand − solar generation. It is the part of demand that the other power plants must cover.
- **Hardest hour of a day** = the hour with the highest net load that day.
- **Stress days** = the 5% of days with the highest daily peak net load (above the 95th percentile, 78.6 GW). The threshold is calculated once over all years, so years are compared against the same bar.
- **Scope:** June to September, 2019 to 2026 (122 days × 8 years = 976 days).

## Key findings

| Finding | Result |
|---|---|
| Most common hardest hour, 2019 | Hour 17 (4–5 PM), about 65% of days |
| Most common hardest hour, 2026 | Hour 21 (8–9 PM), about 78% of days |
| Stress days (top 5%) | 49 days, threshold 78.6 GW |
| Stress days in August | 30 of 49 (61%) |
| Stress days in 2026 | 43 of 49 |

Hours use the "hour ending" convention: hour 21 means 8–9 PM.

## Dashboard

| Page 1: one hot day | Page 3: stress days |
|---|---|
| ![Page 1](images/page1.png) | ![Page 3](images/page3.png) |

1. **One hot day:** demand, solar and net load by hour, the hardest hour, and the 3 hardest hours of the selected day.
2. **How the hardest hour moved:** a heatmap of how often each hour was the hardest, by year, plus 2019 vs 2026.
3. **Stress days:** the threshold, the number of stress days per year and per month, and the 10 hardest days.

## Data

- **Source:** U.S. Energy Information Administration (EIA-930 Hourly Electric Grid Monitor), ERCOT region (Electric Reliability Council of Texas).
- **Fields used:** hourly demand, solar generation, total generation, forecast demand and interchange (imports/exports).

## How it was built

**1. MySQL** (see the `sql/` folder)
- A staging table holds the raw data as text, exactly as it arrived.
- A clean, typed fact table is loaded from it (`TRIM`, `REPLACE`, `NULLIF`, `CAST`, `STR_TO_DATE`) and filtered to June–September, 2019–2026.
- A view, `v_hardest_hour`, uses a window function (`ROW_NUMBER() OVER (PARTITION BY local_date ORDER BY demand_mw - solar_mw DESC)`) to keep each day's hardest hour.

**2. Power BI**
- Star schema: a date table (`dim_date`, with year and month) linked one-to-many to the hourly fact table and one-to-one to the daily view.
- The measures are written in DAX. See [`DAX_measures.md`](DAX_measures.md).

## Checks

- The view returns exactly **976 rows**, one per day (122 days × 8 years).
- Hour numbers run from **1 to 24**, which confirms the hour-ending convention.
- Power BI results were cross-checked against SQL queries. A mismatch in the 2026 hardest hour was traced to a filter in one of my measures and fixed.

## Limitations

- **Coincides, not caused.** Data centers, hotter summers and population and industry growth could also push demand into the evening. The dataset has no temperature or consumer detail, so these cannot be separated.
- **Rooftop solar is not counted.** Net load here uses utility-scale solar only, so it is not the same as the grid operator's own net load figure.
- **One grid, one period.** The results describe ERCOT in summer, 2019–2026.
- **Descriptive only.** This is an analysis of what happened, not a forecast.

## Reproduce it

1. Download the EIA-930 hourly data for ERCOT.
2. Run the files in `sql/` in order to create the staging table, the clean table and the view. Check that the view returns 976 rows.
3. Open the Power BI report and refresh it against your MySQL database.

## Contact

I'm happy to collaborate with anyone working on a question that needs data analysis.

Mohammed Elamin
