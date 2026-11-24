# Structural Integrity Corrective Actions and Verification

**Project:** An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia

**Date:** 24 November 2026

**Database:** `zambia_agriculture_db`

**DBMS:** PostgreSQL 18.3

**Status:** PASSED — approved corrective actions completed and verified.

## 1. Purpose and scope

This record documents the approved structural integrity corrections undertaken following the database structural audit. The work addressed the year constraint on `agriculture.crop_statistics` and supporting indexes for foreign-key columns in populated agricultural tables.

All corrective operations were performed against the existing database. Subsequent verification checks confirmed that the changes did not alter the underlying agricultural observations.

## 2. Assessment of agriculture.crop_statistics

The structural assessment established that:

- `agriculture.crop_statistics` is a regular table containing the columns `stat_id`, `crop_id`, `year`, `indicator`, `value` and `unit`.
- The table contained zero records at the time of inspection.
- No views, routines, triggers or incoming foreign-key dependencies were identified.
- The table has an outgoing foreign key to `agriculture.crops`.
- Its generic indicator-value structure may support additional agricultural observations in future.

**Decision:** The table was retained. Its empty state does not constitute a database integrity failure, and deletion was not necessary to address the identified structural issues.

## 3. Correction of the year constraint

The original `chk_year` constraint permitted years from 1991 to 2024.

The approved correction aligned the constraint with the current database study period of 1991–2020.

The revised constraint is:

`CHECK (year >= 1991 AND year <= 2020)`

Verification confirmed:

| Check | Result |
|---|---|
| Constraint name | `chk_year` |
| Lower year boundary | 1991 |
| Upper year boundary | 2020 |
| Constraint validated | Yes |
| Records in table | 0 |
| Records outside study period | 0 |
| Outcome | PASS |

The constraint is validated by PostgreSQL.

## 4. Supporting indexes for foreign keys

The assessment identified three foreign-key columns in populated tables without supporting indexes. The following indexes were created:

| Table | Index | Indexed column |
|---|---|---|
| `agriculture.land_use` | `idx_land_use_crop_id` | `crop_id` |
| `agriculture.production` | `idx_production_crop_id` | `crop_id` |
| `agriculture.yields` | `idx_yields_crop_id` | `crop_id` |

Post-creation verification confirmed that all three indexes were valid and ready for use.

The index on `agriculture.crop_statistics.crop_id` was deliberately deferred because the table contains no records. Its foreign-key constraint remains validated.

## 5. Foreign-key verification

All four foreign-key relationships were inspected after the corrective actions.

| Table | Foreign key | Validation result | Index outcome |
|---|---|---|---|
| `agriculture.crop_statistics` | `fk_crop` | Validated | Deferred — empty table |
| `agriculture.land_use` | `fk_land_use_crop` | Validated | Supporting index valid and ready |
| `agriculture.production` | `fk_crop` | Validated | Supporting index valid and ready |
| `agriculture.yields` | `fk_yield_crop` | Validated | Supporting index valid and ready |

No corrective action was required for the foreign-key constraints themselves.

## 6. Data preservation verification

Record counts were checked after index creation to confirm that the three populated tables remained unchanged.

| Table | Verified records |
|---|---:|
| `agriculture.land_use` | 330 |
| `agriculture.production` | 330 |
| `agriculture.yields` | 330 |
| **Total** | **990** |

All 990 records were preserved. The combined record-count verification passed.

The `agriculture.crop_statistics` table also remained empty, with zero records.

## 7. Final assessment

The approved structural integrity corrective actions were completed and independently verified through subsequent read-only checks.

The final results establish that:

1. The `agriculture.crop_statistics` year constraint is validated and aligned with the 1991–2020 study period.
2. Three supporting indexes were successfully created on foreign-key columns in populated agricultural tables.
3. All four foreign-key constraints remain validated.
4. The supporting index for the empty `agriculture.crop_statistics` table was appropriately deferred.
5. All 990 records across the three indexed tables were preserved.
6. The empty `agriculture.crop_statistics` table was retained.

**Overall outcome: PASS.**

No further corrective action is outstanding for the issues addressed in this record.

---

*This record documents the specific corrective actions and verification results completed on 24 November 2026. It does not replace the broader database validation, data integrity or backup and restoration records.*
