
/*
Project: An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
Script: 03_climate_analysis.sql

Purpose: Examine national rainfall and temperature trends, interannual variability,
and annual departures from the 1991–2020 climate averages.

Database: zambia_agriculture_db
Read-only: All statements are SELECT queries.

Limitations: Analysis is based on national annual climate summaries and does not
capture provincial or agro-ecological-zone differences, seasonal climate variability,
or localised extreme weather events. Descriptive trends and anomalies do not establish
causation or statistical significance. Climate-productivity relationships are examined
separately in 02_agricultural_trends.sql.
*/

-- 1. Long-term climate trend summary
SELECT
    climate_variable,
    annual_change,
    change_per_decade,
    r_squared,
    minimum_value,
    maximum_value,
    average_value
FROM climate.v_climate_trends
ORDER BY climate_variable;


-- 2. Annual rainfall and temperature series
SELECT
    r.year,
    r.rainfall_mm,
    t.avg_temperature_c
FROM climate.rainfall AS r
JOIN climate.temperature AS t USING (year)
WHERE r.year BETWEEN 1991 AND 2020
ORDER BY r.year;


-- 3. Interannual variability (coefficient of variation is a percentage)
SELECT
    'Rainfall' AS climate_variable,
    COUNT(rainfall_mm) AS observations,
    AVG(rainfall_mm) AS mean_value,
    STDDEV_SAMP(rainfall_mm) AS standard_deviation,
    100.0 * STDDEV_SAMP(rainfall_mm) / NULLIF(AVG(rainfall_mm), 0)
        AS coefficient_of_variation_pct
FROM climate.rainfall
WHERE year BETWEEN 1991 AND 2020

UNION ALL

SELECT
    'Temperature',
    COUNT(avg_temperature_c),
    AVG(avg_temperature_c),
    STDDEV_SAMP(avg_temperature_c),
    100.0 * STDDEV_SAMP(avg_temperature_c) / NULLIF(AVG(avg_temperature_c), 0)
FROM climate.temperature
WHERE year BETWEEN 1991 AND 2020
ORDER BY climate_variable;


-- 4. Annual climate anomalies relative to the 1991–2020 period mean
WITH rainfall_mean AS (
    SELECT AVG(rainfall_mm) AS mean_rainfall_mm
    FROM climate.rainfall
    WHERE year BETWEEN 1991 AND 2020
),
temperature_mean AS (
    SELECT AVG(avg_temperature_c) AS mean_temperature_c
    FROM climate.temperature
    WHERE year BETWEEN 1991 AND 2020
)
SELECT
    r.year,
    r.rainfall_mm,
    ROUND((r.rainfall_mm - rm.mean_rainfall_mm)::numeric, 2)
        AS rainfall_anomaly_mm,
    t.avg_temperature_c,
    ROUND((t.avg_temperature_c - tm.mean_temperature_c)::numeric, 3)
        AS temperature_anomaly_c
FROM climate.rainfall AS r
JOIN climate.temperature AS t USING (year)
CROSS JOIN rainfall_mean AS rm
CROSS JOIN temperature_mean AS tm
WHERE r.year BETWEEN 1991 AND 2020
ORDER BY r.year;


-- 5. Five wettest and five driest years
WITH ranked_rainfall AS (
    SELECT
        year,
        rainfall_mm,
        RANK() OVER (ORDER BY rainfall_mm DESC) AS wet_rank,
        RANK() OVER (ORDER BY rainfall_mm ASC) AS dry_rank
    FROM climate.rainfall
    WHERE year BETWEEN 1991 AND 2020
)
SELECT
    year,
    rainfall_mm,
    CASE
        WHEN wet_rank <= 5 THEN 'Wettest'
        WHEN dry_rank <= 5 THEN 'Driest'
    END AS rainfall_extreme
FROM ranked_rainfall
WHERE wet_rank <= 5 OR dry_rank <= 5
ORDER BY
    CASE WHEN dry_rank <= 5 THEN 1 ELSE 2 END,
    CASE WHEN dry_rank <= 5 THEN rainfall_mm END ASC,
    CASE WHEN wet_rank <= 5 THEN rainfall_mm END DESC;


-- 6. Five warmest and five coolest years
WITH ranked_temperature AS (
    SELECT
        year,
        avg_temperature_c,
        RANK() OVER (ORDER BY avg_temperature_c DESC) AS warm_rank,
        RANK() OVER (ORDER BY avg_temperature_c ASC) AS cool_rank
    FROM climate.temperature
    WHERE year BETWEEN 1991 AND 2020
)
SELECT
    year,
    avg_temperature_c,
    CASE
        WHEN warm_rank <= 5 THEN 'Warmest'
        WHEN cool_rank <= 5 THEN 'Coolest'
    END AS temperature_extreme
FROM ranked_temperature
WHERE warm_rank <= 5 OR cool_rank <= 5
ORDER BY
    CASE WHEN cool_rank <= 5 THEN 1 ELSE 2 END,
    CASE WHEN cool_rank <= 5 THEN avg_temperature_c END ASC,
    CASE WHEN warm_rank <= 5 THEN avg_temperature_c END DESC;
