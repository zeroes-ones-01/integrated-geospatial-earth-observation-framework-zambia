/*
Project: An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
Script: 01_data_validation.sql
Purpose: Read-only checks to support transparent analysis and publication.
Scope: Main analytical period 1991–2020. Review flagged rows; do not assume every flag is an error.
*/

-- 1. Row counts for core tables (crop_statistics is known to be empty).
SELECT 'agriculture.crops' AS table_name, COUNT(*) AS row_count FROM agriculture.crops
UNION ALL SELECT 'agriculture.production', COUNT(*) FROM agriculture.production
UNION ALL SELECT 'agriculture.yields', COUNT(*) FROM agriculture.yields
UNION ALL SELECT 'agriculture.land_use', COUNT(*) FROM agriculture.land_use
UNION ALL SELECT 'agriculture.crop_statistics', COUNT(*) FROM agriculture.crop_statistics
UNION ALL SELECT 'agriculture.fertilizer_nutrients', COUNT(*) FROM agriculture.fertilizer_nutrients
UNION ALL SELECT 'climate.rainfall', COUNT(*) FROM climate.rainfall
UNION ALL SELECT 'climate.temperature', COUNT(*) FROM climate.temperature
UNION ALL SELECT 'emissions.co2_equivalent', COUNT(*) FROM emissions.co2_equivalent
UNION ALL SELECT 'geography.provinces', COUNT(*) FROM geography.provinces
ORDER BY table_name;

-- 2. Coverage by year for each main analytical table.
SELECT 'production' AS dataset, MIN(year) AS first_year, MAX(year) AS last_year,
       COUNT(DISTINCT year) AS distinct_years FROM agriculture.production
UNION ALL SELECT 'yields', MIN(year), MAX(year), COUNT(DISTINCT year) FROM agriculture.yields
UNION ALL SELECT 'land_use', MIN(year), MAX(year), COUNT(DISTINCT year) FROM agriculture.land_use
UNION ALL SELECT 'fertilizer_nutrients', MIN(year), MAX(year), COUNT(DISTINCT year) FROM agriculture.fertilizer_nutrients
UNION ALL SELECT 'rainfall', MIN(year), MAX(year), COUNT(DISTINCT year) FROM climate.rainfall
UNION ALL SELECT 'temperature', MIN(year), MAX(year), COUNT(DISTINCT year) FROM climate.temperature
UNION ALL SELECT 'co2_equivalent', MIN(year), MAX(year), COUNT(DISTINCT year) FROM emissions.co2_equivalent
ORDER BY dataset;

-- 3. Nulls in fields required for analysis.
SELECT 'production' AS dataset, COUNT(*) FILTER (WHERE crop_id IS NULL OR year IS NULL OR value IS NULL OR unit IS NULL) AS rows_with_nulls FROM agriculture.production
UNION ALL SELECT 'yields', COUNT(*) FILTER (WHERE crop_id IS NULL OR year IS NULL OR value IS NULL OR unit IS NULL) FROM agriculture.yields
UNION ALL SELECT 'land_use', COUNT(*) FILTER (WHERE crop_id IS NULL OR year IS NULL OR value IS NULL OR unit IS NULL) FROM agriculture.land_use
UNION ALL SELECT 'rainfall', COUNT(*) FILTER (WHERE year IS NULL OR rainfall_mm IS NULL) FROM climate.rainfall
UNION ALL SELECT 'temperature', COUNT(*) FILTER (WHERE year IS NULL OR avg_temperature_c IS NULL) FROM climate.temperature
UNION ALL SELECT 'co2_equivalent', COUNT(*) FILTER (WHERE item IS NULL OR year IS NULL OR unit IS NULL OR value IS NULL) FROM emissions.co2_equivalent
UNION ALL SELECT 'fertilizer_nutrients', COUNT(*) FILTER (WHERE nutrient IS NULL OR year IS NULL OR unit IS NULL OR value IS NULL) FROM agriculture.fertilizer_nutrients
ORDER BY dataset;

-- 4. Duplicate natural-key checks. Any returned count above zero merits review.
SELECT 'production crop-year' AS check_name, COUNT(*) AS duplicate_groups FROM (SELECT crop_id, year FROM agriculture.production GROUP BY crop_id, year HAVING COUNT(*) > 1) d
UNION ALL SELECT 'yields crop-year', COUNT(*) FROM (SELECT crop_id, year FROM agriculture.yields GROUP BY crop_id, year HAVING COUNT(*) > 1) d
UNION ALL SELECT 'land_use crop-year', COUNT(*) FROM (SELECT crop_id, year FROM agriculture.land_use GROUP BY crop_id, year HAVING COUNT(*) > 1) d
UNION ALL SELECT 'rainfall year', COUNT(*) FROM (SELECT year FROM climate.rainfall GROUP BY year HAVING COUNT(*) > 1) d
UNION ALL SELECT 'temperature year', COUNT(*) FROM (SELECT year FROM climate.temperature GROUP BY year HAVING COUNT(*) > 1) d
UNION ALL SELECT 'emissions item-year', COUNT(*) FROM (SELECT item, year FROM emissions.co2_equivalent GROUP BY item, year HAVING COUNT(*) > 1) d
UNION ALL SELECT 'fertilizer nutrient-year', COUNT(*) FROM (SELECT nutrient, year FROM agriculture.fertilizer_nutrients GROUP BY nutrient, year HAVING COUNT(*) > 1) d
ORDER BY check_name;

-- 5. Unit labels. Check consistency before comparing or combining values.
SELECT 'production' AS dataset, COALESCE(unit, '[NULL]') AS unit, COUNT(*) AS rows FROM agriculture.production GROUP BY unit
UNION ALL SELECT 'yields', COALESCE(unit, '[NULL]'), COUNT(*) FROM agriculture.yields GROUP BY unit
UNION ALL SELECT 'land_use', COALESCE(unit, '[NULL]'), COUNT(*) FROM agriculture.land_use GROUP BY unit
UNION ALL SELECT 'co2_equivalent', COALESCE(unit, '[NULL]'), COUNT(*) FROM emissions.co2_equivalent GROUP BY unit
UNION ALL SELECT 'fertilizer_nutrients', COALESCE(unit, '[NULL]'), COUNT(*) FROM agriculture.fertilizer_nutrients GROUP BY unit
ORDER BY dataset, unit;

-- 6. Category labels, with quotes making accidental whitespace easier to spot.
SELECT 'fertilizer_nutrients' AS dataset, quote_literal(nutrient) AS category_label, COUNT(*) AS rows
FROM agriculture.fertilizer_nutrients GROUP BY nutrient
UNION ALL
SELECT 'co2_equivalent', quote_literal(item), COUNT(*)
FROM emissions.co2_equivalent GROUP BY item
ORDER BY dataset, category_label;

-- 7. Zero or negative values for review. Zero may be valid; this query does not change data.
SELECT 'production' AS dataset, COUNT(*) AS zero_or_negative_values FROM agriculture.production WHERE value <= 0
UNION ALL SELECT 'yields', COUNT(*) FROM agriculture.yields WHERE value <= 0
UNION ALL SELECT 'land_use', COUNT(*) FROM agriculture.land_use WHERE value <= 0
UNION ALL SELECT 'rainfall', COUNT(*) FROM climate.rainfall WHERE rainfall_mm <= 0
UNION ALL SELECT 'co2_equivalent', COUNT(*) FROM emissions.co2_equivalent WHERE value <= 0
UNION ALL SELECT 'fertilizer_nutrients', COUNT(*) FROM agriculture.fertilizer_nutrients WHERE value <= 0
ORDER BY dataset;

-- 8. Crop lookup integrity checks.
SELECT 'production crop IDs without crop lookup' AS check_name, COUNT(*) AS unmatched_rows
FROM agriculture.production p LEFT JOIN agriculture.crops c USING (crop_id) WHERE c.crop_id IS NULL
UNION ALL
SELECT 'yields crop IDs without crop lookup', COUNT(*)
FROM agriculture.yields y LEFT JOIN agriculture.crops c USING (crop_id) WHERE c.crop_id IS NULL
UNION ALL
SELECT 'land_use crop IDs without crop lookup', COUNT(*)
FROM agriculture.land_use l LEFT JOIN agriculture.crops c USING (crop_id) WHERE c.crop_id IS NULL
ORDER BY check_name;

-- 9. Missing climate years within the intended 1991–2020 period.
WITH expected_years AS (SELECT generate_series(1991, 2020) AS year)
SELECT 'rainfall' AS dataset, e.year AS missing_year
FROM expected_years e LEFT JOIN climate.rainfall r USING (year) WHERE r.year IS NULL
UNION ALL
SELECT 'temperature', e.year
FROM expected_years e LEFT JOIN climate.temperature t USING (year) WHERE t.year IS NULL
ORDER BY dataset, missing_year;

-- 10. Explicitly report the optional crop_statistics table's status.
SELECT COUNT(*) AS crop_statistics_rows FROM agriculture.crop_statistics;
