# DAX measures

All measures live in a `Key_Metrics` table. Tables: `fact_grid_hourly` (hourly), `v_hardest_hour` (one row per day), `dim_date` (one row per day, with `Year`, `Month Number`).

## Page 1: one hot day
```dax
Peak Net Load = MAX( v_hardest_hour[net_load_mw] )

Peak Solar = MAX( fact_grid_hourly[solar_mw] )

-- Meaningful for one selected day
Hardest Hour (Selected Day) = MAX( v_hardest_hour[hardest_hour] )

Solar at Hardest Hour =
VAR h = [Hardest Hour (Selected Day)]
RETURN CALCULATE( MAX( fact_grid_hourly[solar_mw] ), fact_grid_hourly[hour_no] = h )

-- Averages, so the numbers stay correct for any slicer selection
AVG Net Load = AVERAGE( fact_grid_hourly[demand_mw] ) - AVERAGE( fact_grid_hourly[solar_mw] )

Hot Days Analyzed = DISTINCTCOUNT( dim_date[local_date] )

Forecast Error at Hardest Hour =
VAR h = [Hardest Hour (Selected Day)]
VAR forecast = CALCULATE( MAX( fact_grid_hourly[demand_forecast_mw] ), fact_grid_hourly[hour_no] = h )
VAR actual = CALCULATE( MAX( fact_grid_hourly[demand_mw] ), fact_grid_hourly[hour_no] = h )
RETURN forecast - actual
```

### Unit conversions (MW to GW, for readable axes and cards)
```dax
Demand (GW) = AVERAGE( fact_grid_hourly[demand_mw] ) / 1000
Solar (GW) = AVERAGE( fact_grid_hourly[solar_mw] ) / 1000
AVG Net Load (GW) = DIVIDE( [AVG Net Load], 1000, 0 )
Peak Net Load (GW) = [Peak Net Load] / 1000
Peak Solar (GW) = [Peak Solar] / 1000
Solar at Hardest Hour (GW) = [Solar at Hardest Hour] / 1000
Forecast Error (GW) = DIVIDE( [Forecast Error at Hardest Hour], 1000 )
Stress Threshold (GW) = DIVIDE( [Stress Threshold], 1000 )   -- [Stress Threshold] is defined on page 3 below
```

## Page 2: how the hardest hour moved
```dax
Most Common Hardest Hour =
VAR HourCounts =
    ADDCOLUMNS(
        VALUES( v_hardest_hour[hardest_hour] ),
        "DAYS", CALCULATE( COUNTROWS( v_hardest_hour ) )
    )
RETURN
    MAXX( TOPN( 1, HourCounts, [DAYS], DESC ), v_hardest_hour[hardest_hour] )   -- ties: TOPN keeps them, MAXX returns the later hour

Most Common Hardest Hour (2019) = CALCULATE( [Most Common Hardest Hour], dim_date[Year] = 2019 )
Most Common Hardest Hour (2026) = CALCULATE( [Most Common Hardest Hour], dim_date[Year] = 2026 )

Shift (Hours) = [Most Common Hardest Hour (2026)] - [Most Common Hardest Hour (2019)]

Share of Days =
DIVIDE(
    COUNTROWS( v_hardest_hour ),
    CALCULATE( COUNTROWS( v_hardest_hour ), ALL( v_hardest_hour[hardest_hour] ) )
)

-- Shows 0 instead of blank, so empty heatmap cells display a dot
Share of Days (heatmap) = COALESCE( [Share of Days], 0 )
```

## Page 3: stress days
```dax
-- Fixed across all years on purpose, so years are compared against the same bar
Stress Threshold =
CALCULATE( PERCENTILE.INC( v_hardest_hour[net_load_mw], 0.95 ), ALL( v_hardest_hour ) )

Stress Days Count =
VAR threshold = [Stress Threshold]
RETURN
    CALCULATE(
        COUNTROWS( v_hardest_hour ),
        FILTER( v_hardest_hour, v_hardest_hour[net_load_mw] >= threshold )
    )

August Stress Share =
DIVIDE(
    CALCULATE( [Stress Days Count], FILTER( dim_date, dim_date[Month Number] = 8 ) ),
    [Stress Days Count]
)

Most Common Hardest Hour (Stress) =
VAR threshold = [Stress Threshold]
RETURN
    CALCULATE(
        [Most Common Hardest Hour],
        FILTER( v_hardest_hour, v_hardest_hour[net_load_mw] >= threshold )
    )
```
