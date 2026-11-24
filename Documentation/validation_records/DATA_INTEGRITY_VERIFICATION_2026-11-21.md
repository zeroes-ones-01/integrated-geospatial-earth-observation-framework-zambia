# Data Integrity Verification Record

**Project:** An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia

**Verification date:** 21 November 2026

**Status:** PASSED

## 1. Purpose

To verify the consistency of the cleaned agricultural CSV source files against their corresponding records in the PostgreSQL database.

## 2. Datasets examined

Three datasets were examined:

- Production (`production.csv`)
- Yields (`yields.csv`)
- Harvested area (`area_harvested.csv`)

The verification covered all 11 crop identifiers.

## 3. Verification results

| Dataset | Compared | Matching | Discrepancies |
|---|---:|---:|---:|
| Production | 330 | 330 | 0 |
| Yields | 330 | 330 | 0 |
| Land use | 330 | 330 | 0 |
| **Total** | **990** | **990** | **0** |

**Overall matching rate: 100%**

## 4. Verification criteria

The comparison examined:

1. Crop identifiers.
2. Observation years.
3. Numerical values, using a tolerance of 0.000001.
4. Measurement units.
5. Missing database records.

## 5. Findings

All 990 observations matched their corresponding PostgreSQL records.

- No missing database records were detected among the compared observations.
- No numerical discrepancies were detected.
- No measurement-unit discrepancies were detected.

The three datasets achieved a 100% matching rate.

## 6. Technical note

A minor PowerShell interactive execution error occurred when the `else` statement was entered separately from its corresponding `if` block.

This did not affect the comparison results. The discrepancy count was independently confirmed to be zero.

## 7. Limitations

This verification establishes consistency between the selected cleaned CSV files and their corresponding PostgreSQL records.

It does not independently establish the accuracy, completeness or reliability of the original FAOSTAT source data.

## 8. Conclusion

The CSV-to-PostgreSQL data integrity comparison passed successfully.

All 990 observations across production, yields and harvested area matched their corresponding database records.

**Final status: PASSED**

## 9. Initial recommendation: crop coverage and temporal completeness

Conduct a crop coverage and temporal completeness audit for 1991–2020.

The next audit should examine:

- Expected annual observations per crop.
- Missing years.
- Duplicate crop-year combinations.
- Coverage across all 11 crops.
- Completeness across all three datasets.

This will provide additional evidence of database completeness before final database validation and portfolio documentation.

---

**Project:** An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
**Record type:** Data quality and integrity verification
**Verification date:** 2026-11-21

## 10. Crop Coverage and Temporal Completeness Audit

A subsequent read-only audit was conducted directly against the PostgreSQL database to assess crop coverage and temporal completeness.

The audit examined the following tables:

- `agriculture.production`
- `agriculture.yields`
- `agriculture.land_use`

The expected coverage was 11 crop identifiers (1–11) over 30 years (1991–2020), giving 330 expected crop-year observations per dataset.

### 10.1 Results

| Dataset    | Total records | Valid records | Crops | Years | Unique crop-year combinations | Missing | Duplicate groups | Out of scope |
| ---------- | ------------- | ------------- | ----- | ----- | ----------------------------- | ------- | ---------------- | ------------ |
| Production | 330           | 330           | 11    | 30    | 330                           | 0       | 0                | 0            |
| Yields     | 330           | 330           | 11    | 30    | 330                           | 0       | 0                | 0            |
| Land use   | 330           | 330           | 11    | 30    | 330                           | 0       | 0                | 0            |
| **Total**  | **990**       | **990**       | —     | —     | **990**                       | **0**   | **0**            | **0**        |

### 10.2 Findings

- All three tables contain the expected 330 records.
- All 11 crop identifiers are represented in each dataset.
- All 30 years, from 1991 to 2020, are represented.
- No missing expected crop-year combinations were detected.
- No duplicate crop-year groups were detected.
- No records outside the specified crop identifier and year ranges were detected.

### 10.3 Conclusion

The PostgreSQL crop coverage and temporal completeness audit passed successfully. All three datasets satisfy the expected structural coverage requirements.

**Audit status: PASSED**

## 11. Overall Conclusion

The selected agricultural datasets passed both the CSV-to-PostgreSQL data integrity comparison and the PostgreSQL crop coverage and temporal completeness audit.

Across the three datasets, all 990 observations matched their corresponding database records, with no detected value or unit discrepancies, missing crop-year combinations, duplicate groups or out-of-scope records.

These results provide evidence of consistency and temporal completeness for the selected agricultural datasets. They do not independently establish the accuracy or reliability of the original source data.

**Overall verification status: PASSED**

## 12. Subsequent validation status

Following the initial agricultural data-integrity verification, additional read-only validation was undertaken across the database. Subsequent checks covered climate, fertiliser nutrients, selected greenhouse-gas emissions, derived analytical views, climate-productivity indicators, crop-yield trends and structural integrity.

The subsequent results extend the original agricultural CSV-to-database comparison. They should not be interpreted as having formed part of the verification conducted on 21 November 2026.

Confirmed subsequent checks include:

- Agricultural production, yields and land-use records: 990 of 990 records matched the corresponding source records, comprising 330 records for each dataset.
- Climate and selected emissions: annual emissions comparisons passed for all 30 years.
- Fertiliser nutrients: annual nitrogen, phosphorus and potassium values matched the source data across the 30-year study period.
- Integrated annual indicators: all seven indicators in the annual climate, fertiliser and emissions view passed the reported 30-year validation.
- Annual emissions intensity: all 30 years passed independent recomputation using the production data and the selected emissions categories.
- Climate-productivity indicators: all 30 years passed numerical validation, accounting for the reported four-decimal rounding.
- Crop-yield trends: numerical results were reproduced for all 11 crops.
- Climate trends: both rainfall and temperature trend calculations passed numerical reproduction.
- Structural integrity: the corrective verification confirmed the revised study-period constraint and the applicable foreign-key indexes, while preserving the 990 agricultural records.

These results relate to the database's defined datasets and analytical indicators. The selected emissions categories do not constitute a complete national agricultural greenhouse-gas inventory. The national annual climate series and derived indicators do not establish provincial or district-level spatial patterns, and the database should not be described as having implemented PostGIS or Earth observation integration.
