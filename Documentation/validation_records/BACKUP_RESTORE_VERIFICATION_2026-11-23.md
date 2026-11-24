﻿# Database Backup and Restoration Verification

**Project:** An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
**Verification date:** 23 November 2026
**Database system:** PostgreSQL 18.3
**Database owner:** postgres

## 1. Purpose

This record documents the creation and restoration of a PostgreSQL database backup and the subsequent comparison of the restored database against the original.

The restoration was performed in a separate test database. The original production database was not modified.

## 2. Backup details

| Item | Details |
|---|---|
| Original database | `zambia_agriculture_db` |
| Backup format | PostgreSQL custom format |
| Backup filename | `zambia_agriculture_db_20261123_092427.backup` |
| Backup directory | `Backups/` |
| Creation date | 23 November 2026 |
| Approximate file size | 0.045 MB |
| Backup command result | Exit code 0 |
| Archive inspection | 91 recognised table-of-contents entries |

The archive was inspected using `pg_restore -l` before restoration.

## 3. Restoration details

| Item | Details |
|---|---|
| Source database | `zambia_agriculture_db` |
| Restoration database | `zambia_agriculture_restore_test_20261123` |
| Restoration utility | `pg_restore` |
| Restore result | Successful |
| Restore exit code | 0 |
| Reported restoration errors | None |

The restoration included the project schemas, tables, views, table data, sequences, sequence settings, constraints and indexes.

## 4. Verification results

### 4.1 Table and view row-count comparison

The original and restored databases were queried independently.

All 18 checked objects had identical row counts:

- 10 physical tables
- 8 analytical views

No differences were returned by PowerShell `Compare-Object`.

### 4.2 Structural inventory comparison

| Object type | Original | Restored | Result |
|---|---:|---:|---|
| Tables | 10 | 10 | PASS |
| Views | 8 | 8 | PASS |
| Constraints | 69 | 69 | PASS |
| Indexes | 12 | 12 | PASS |
| Sequences | 10 | 10 | PASS |

### 4.3 Physical table content comparison

Content fingerprints were calculated for all 10 physical tables using PostgreSQL row serialisation and MD5 hashing.

The original and restored databases produced identical fingerprints for every table.

No differences were returned by `Compare-Object`.

This comparison provides evidence of matching table contents, but MD5 fingerprints are not a cryptographic guarantee of backup authenticity.

### 4.4 Sequence comparison

All 10 sequences were compared using their configuration and recorded current values.

The following properties matched:

- Start value
- Minimum and maximum values
- Increment
- Cycle setting
- Cache size
- Recorded last value, where available

No differences were returned by `Compare-Object`.

The empty `agriculture.crop_statistics` table and its sequence's unavailable last value were preserved consistently.

## 5. Overall result

**BACKUP AND RESTORATION VERIFICATION: PASS**

The custom-format backup was successfully restored into an isolated test database. The restored database matched the original in all the row-count, structural, table-content fingerprint and sequence comparisons performed.

The original database remained untouched during the verification process.

## 6. Scope and limitations

The following were not established by this test:

- Recovery to a different physical server or operating system.
- Point-in-time recovery using archived WAL files.
- Recovery of PostgreSQL cluster-wide objects such as roles and tablespaces from a database-only backup.
- Application-level connectivity and operational testing after restoration.
- A cryptographic authenticity guarantee for the backup archive.

The successful test therefore demonstrates a successful database-level backup and restoration under the tested local PostgreSQL environment. It does not establish a complete disaster-recovery strategy.

## 7. Retention recommendation

Retain the following until a separate retention decision is made:

1. The original custom-format backup archive.
2. The restored test database.
3. This verification record.

The test database should only be removed after its evidence has been retained and cleanup has been explicitly approved.

---

**Verification status:** Complete
**Record filename:** `BACKUP_RESTORE_VERIFICATION_2026-11-23.md`
