# Texas-Grid-Hardest-Hour

# Texas Grid: Peak Net Load and Solar (2019–2026)

## Question
On hot summer days (June to September), which hour is the hardest for Texas power plants, and has it moved later in the day as solar generation grew?

**Net load = demand − solar.** It is the demand that other power plants still have to cover once solar has supplied its share. The hardest hour of a day is the hour with the highest net load.

## Data
- Hourly ERCOT (Texas) electricity demand and generation by source, from the U.S. EIA (EIA-930).
- Period: June to September, 2019 to 2026.
- The raw file is not included in this repo. It is public on the EIA website.

## Tools
MySQL (data cleaning and analysis), Power BI (report, in progress).

## How it works
Raw file → staging table (all text) → clean hourly fact table (typed) → view of the hardest hour per day → Power BI.

## SQL files (run in order)
| File | What it does |
|---|---|
| `01_create_database.sql` | Creates the `texas_grid` database |
| `02_create_staging_table.sql` | Creates the staging table; the CSV is then loaded with the Table Data Import Wizard |
| `03_check_staging_data.sql` | Checks that the raw file loaded correctly |
| `04_create_fact_table.sql` | Creates the clean hourly table |
| `05_load_fact_table.sql` | Cleans the staging data and loads it (commas removed, empty text to NULL, text dates to real dates, June–September only) |
| `06_quality_checks.sql` | Row counts (2,928 hours and 122 days per year), NULL check, min/max check |
| `07_explore_hardest_hours.sql` | Exploration: hardest hours and the solar profile by hour |
| `08_view_hardest_hour.sql` | View `v_hardest_hour`: the hardest hour of each day (window function inside a CTE), 976 rows |

## Notes and limits
- Hours are **hour-ending**: hour 21 means 8–9 PM. I confirmed this from the solar profile, which is zero overnight.
- Rooftop solar is not included in the EIA data, so net load here is based on utility-scale solar only.
- Daylight saving days (23- and 25-hour days) fall outside June to September, so they do not affect the data used.
- This project looks at patterns that **coincide with** solar growth. It does not show that solar caused them. Hotter summers and rising demand can also play a part.

## Status
SQL cleaning and analysis are complete. The Power BI report (three pages: one hot day, how the hardest hour moved, stress days) is in progress.
