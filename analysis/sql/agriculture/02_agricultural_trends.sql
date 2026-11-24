/*
Project: An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
Script: 02_agricultural_trends.sql
Purpose: Describe crop-yield and aggregate agricultural-productivity trends for 1991–2020.
Database: zambia_agriculture_db (PostgreSQL)

Interpretation notes:
- These are descriptive associations and trends, not causal estimates.
- The source yield table is recorded in kg/ha; conversions below produce t/ha.
- Aggregate productivity is total crop production divided by total harvested area.
- Check units and category definitions in the source data before interpreting results.
*/

-- 1. Crop-specific yield: compare first and last available year and estimate linear trend.
-- Output slope is in tonnes per hectare per year.
WITH annual_crop_yield AS (
    SELECT c.crop_name,
           y.year,
           AVG(y.value) / 1000.0 AS yield_t_per_ha
    FROM agriculture.yields AS y
    JOIN agriculture.crops AS c ON c.crop_id = y.crop_id
    WHERE y.year BETWEEN 1991 AND 2020
      AND y.value IS NOT NULL
    GROUP BY c.crop_name, y.year
), trend AS (
    SELECT crop_name,
           REGR_SLOPE(yield_t_per_ha, year) AS slope_t_per_ha_per_year,
           REGR_R2(yield_t_per_ha, year) AS r_squared,
           COUNT(*) AS years_observed
    FROM annual_crop_yield
    GROUP BY crop_name
), endpoints AS (
    SELECT crop_name,
           MIN(year) AS first_year,
           (ARRAY_AGG(yield_t_per_ha ORDER BY year))[1] AS first_yield_t_per_ha,
           MAX(year) AS last_year,
           (ARRAY_AGG(yield_t_per_ha ORDER BY year DESC))[1] AS last_yield_t_per_ha
    FROM annual_crop_yield
    GROUP BY crop_name
)
SELECT e.crop_name,
       e.first_year,
       ROUND(e.first_yield_t_per_ha::numeric, 3) AS first_yield_t_per_ha,
       e.last_year,
       ROUND(e.last_yield_t_per_ha::numeric, 3) AS last_yield_t_per_ha,
       ROUND((e.last_yield_t_per_ha - e.first_yield_t_per_ha)::numeric, 3) AS endpoint_change_t_per_ha,
       ROUND(t.slope_t_per_ha_per_year::numeric, 5) AS slope_t_per_ha_per_year,
       ROUND(t.r_squared::numeric, 4) AS r_squared,
       t.years_observed
FROM endpoints AS e
JOIN trend AS t USING (crop_name)
ORDER BY t.slope_t_per_ha_per_year DESC NULLS LAST;


-- 2. Annual aggregate productivity from the existing view.
-- The view defines aggregate productivity as total production / total harvested area.
SELECT year,
       ROUND(aggregate_productivity_t_per_ha::numeric, 4) AS aggregate_productivity_t_per_ha
FROM agriculture.v_climate_productivity_annual
WHERE year BETWEEN 1991 AND 2020
ORDER BY year;


-- 3. Linear trend in aggregate productivity across the analysis period.
WITH annual_productivity AS (
    SELECT year, aggregate_productivity_t_per_ha
    FROM agriculture.v_climate_productivity_annual
    WHERE year BETWEEN 1991 AND 2020
      AND aggregate_productivity_t_per_ha IS NOT NULL
)
SELECT COUNT(*) AS years_observed,
       MIN(year) AS first_year,
       MAX(year) AS last_year,
       ROUND(AVG(aggregate_productivity_t_per_ha)::numeric, 4) AS mean_productivity_t_per_ha,
       ROUND(REGR_SLOPE(aggregate_productivity_t_per_ha, year)::numeric, 6)
           AS trend_slope_t_per_ha_per_year,
       ROUND(REGR_R2(aggregate_productivity_t_per_ha, year)::numeric, 4) AS r_squared
FROM annual_productivity;


-- 4. Pairwise correlations between annual aggregate productivity and climate variables.
-- Correlation is calculated only for years with all three values available.
WITH paired AS (
    SELECT p.year,
           p.aggregate_productivity_t_per_ha,
           r.rainfall_mm,
           t.avg_temperature_c
    FROM agriculture.v_climate_productivity_annual AS p
    JOIN climate.rainfall AS r USING (year)
    JOIN climate.temperature AS t USING (year)
    WHERE p.year BETWEEN 1991 AND 2020
      AND p.aggregate_productivity_t_per_ha IS NOT NULL
      AND r.rainfall_mm IS NOT NULL
      AND t.avg_temperature_c IS NOT NULL
)
SELECT COUNT(*) AS paired_years,
       ROUND(CORR(aggregate_productivity_t_per_ha, rainfall_mm)::numeric, 4)
           AS productivity_rainfall_correlation,
       ROUND(CORR(aggregate_productivity_t_per_ha, avg_temperature_c)::numeric, 4)
           AS productivity_temperature_correlation,
       ROUND(CORR(aggregate_productivity_t_per_ha, year)::numeric, 4)
           AS productivity_year_correlation
FROM paired;


-- 5. Production and harvested area totals by year.
-- This output helps interpret the aggregate productivity ratio and its components.
WITH annual AS (
    SELECT year,
           SUM(value) AS total_production_t
    FROM agriculture.production
    WHERE year BETWEEN 1991 AND 2020
    GROUP BY year
), area AS (
    SELECT year,
           SUM(value) AS total_harvested_area_ha
    FROM agriculture.land_use
    WHERE year BETWEEN 1991 AND 2020
    GROUP BY year
)
SELECT a.year,
       ROUND(a.total_production_t::numeric, 2) AS total_production_t,
       ROUND(ar.total_harvested_area_ha::numeric, 2) AS total_harvested_area_ha,
       ROUND((a.total_production_t / NULLIF(ar.total_harvested_area_ha, 0))::numeric, 4)
           AS aggregate_productivity_t_per_ha
FROM annual AS a
JOIN area AS ar USING (year)
ORDER BY a.year;
