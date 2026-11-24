# System Design Notes

## 1. Purpose

The system is designed to provide an integrated and reproducible framework for managing and analysing agricultural productivity, climate and selected agricultural greenhouse-gas emissions data for Zambia.

The current implementation is a PostgreSQL relational database containing national statistical records and geographical reference information. The approved project title describes the intended wider framework; it should not be taken to mean that a fully operational spatial database or Earth observation workflow has already been implemented. Spatial data management, spatial analysis and Earth observation integration constitute planned extensions to the existing statistical foundation.

The approved project title is:

**An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia**

## 2. Design Principles

The system is guided by the following principles:

1. **Data provenance:** source institutions, dataset identities, extraction procedures, units and transformations should be documented.
2. **Data integrity:** primary keys, foreign keys, uniqueness rules, appropriate data types and check constraints should be used to protect the consistency of stored records.
3. **Harmonisation:** datasets should use consistent identifiers, temporal references, geographical references and measurement conventions wherever possible.
4. **Reproducibility:** data preparation and analytical procedures should be documented and implemented through traceable scripts and queries.
5. **Modularity:** source data, database structures, analytical outputs and spatial extensions should remain logically distinguishable.
6. **Scientific restraint:** analytical conclusions should reflect the limitations of the underlying data and methods.
7. **Extensibility:** the architecture should accommodate additional spatial datasets and Earth observation products without compromising the existing statistical database.

## 3. Conceptual Architecture

The system is organised into five conceptual layers.

### 3.1 Source Data Layer

This layer contains the original datasets and their source documentation.

The current statistical implementation draws on:

- FAOSTAT agricultural production, harvested-area, yield, fertiliser nutrient and emissions data.
- National annual precipitation and temperature series supplied in a workbook identified as CRU TS v4.10 and obtained through the World Bank Climate Change Knowledge Portal. The distribution platform and underlying dataset version are identified; however, the precise version-specific procedure used to derive the workbook's national annual values has not been independently established.
- Provincial geographical reference information.

The source files are retained separately from the cleaned datasets. The repository's `data/raw/` directory should not be represented as containing the original source files while those files remain maintained externally.

### 3.2 Data Harmonisation Layer

This layer prepares source records for consistent database integration.

Relevant operations include:

- selecting the geographical area and study period;
- identifying the appropriate indicators and observations;
- standardising variable names and units;
- harmonising crop and geographical identifiers;
- checking missing values and duplicate records;
- validating temporal coverage;
- comparing cleaned records against their source observations; and
- documenting transformations and unresolved uncertainties.

The cleaning process should preserve the distinction between source values and derived indicators. Transformations must be explicit and reproducible.

### 3.3 Relational Database Layer

The database is implemented in PostgreSQL and organised into four principal schemas:

| Schema | Main responsibility |
|---|---|
| `agriculture` | Crop reference information, production, yields, harvested area and related agricultural indicators |
| `climate` | National annual precipitation and temperature information and associated analytical outputs |
| `emissions` | Selected agricultural greenhouse-gas emissions observations |
| `geography` | Provincial geographical reference information |

The implemented database contains ten physical tables and eight analytical views.

The principal agricultural datasets include crop reference information, production, yields and harvested area. Climate and emissions records are stored in their respective subject areas, while geographical reference information supports the organisation of spatially relevant entities.

The `agriculture.crop_statistics` table is currently empty. Its existence should not be interpreted as evidence that a populated crop-statistics dataset has been integrated.

The relational structure uses keys and constraints to support referential integrity and consistent storage. Analytical views provide reusable representations of selected indicators and relationships without requiring the underlying observations to be duplicated.

### 3.4 Analytical Layer

This layer contains SQL-based validation and exploratory analysis.

Current analytical areas include:

- crop production and harvested-area patterns;
- crop-specific and aggregate yield trends;
- annual precipitation and temperature patterns;
- descriptive relationships between climate variables and agricultural productivity;
- selected agricultural greenhouse-gas emissions trends; and
- derived agricultural productivity and emissions indicators.

Aggregate productivity should be calculated using total production divided by total harvested area for the corresponding period and geographical unit. Crop-specific yields should retain their source measurement conventions, with any conversion from kilograms per hectare to tonnes per hectare explicitly documented. Aggregate productivity must also be interpreted in light of changes in crop composition: shifts in the relative contribution of crops with different typical yields can influence the aggregate indicator even when individual crop yields follow different trajectories. Crop-specific results should therefore be considered alongside the aggregate series.

The emissions analysis should preserve the source's reported CO2-equivalent values and units. Where the source already reports emissions in CO2-equivalent terms, an additional global-warming-potential conversion must not be applied. Emissions totals and emissions intensity must be treated as distinct indicators. Any intensity measure should state its emissions numerator, production denominator, units, geographical and temporal coverage, and the categories included. Comparisons should not imply that selected emissions categories constitute a complete agricultural greenhouse-gas inventory.

Statistical associations should be interpreted descriptively. The available national annual time series do not, on their own, establish causal effects of climate conditions on agricultural production. Annual national climate summaries cannot resolve within-year rainfall distribution, growing-season dry spells or crop-specific heat exposure. Further seasonal or higher-frequency climate data, interpreted against relevant crop calendars, are required before such conditions can be assessed reliably.

### 3.5 Geospatial and Earth Observation Layer

This layer is the planned spatial extension of the current statistical system.

Its purpose is to incorporate spatially explicit information that can improve the geographical representation of agricultural and environmental conditions.

Potential components include:

- administrative boundaries and other appropriate geographical reference data;
- agricultural land and crop-related spatial information, where suitable data are available;
- satellite-derived vegetation indicators;
- land-cover information;
- spatially explicit precipitation and temperature products; and
- indicators relevant to drought and heat assessment.

Candidate Earth observation products and datasets must be assessed for temporal coverage, spatial resolution, geographical suitability, quality, licensing and methodological compatibility before adoption.

The spatial workflow should document data acquisition, coordinate reference systems, preprocessing, spatial aggregation, classification or index calculations, validation and uncertainty.

No provincial or local vulnerability result should be claimed until the relevant spatial analysis has been implemented and evaluated.

## 4. Data Integrity and Quality Assurance

Quality assurance is applied at source, harmonisation, database and analytical stages.

Key checks include:

- record counts and temporal completeness;
- uniqueness of business keys;
- validity of crop and geographical identifiers;
- permissible value ranges and measurement units;
- missing and duplicate observations;
- referential integrity;
- agreement between source and cleaned records; and
- consistency between stored observations and analytical outputs.

Validation results should be retained as evidence of the checks performed. A successful database restoration test demonstrates that the tested backup can be restored under the tested conditions; it does not, by itself, establish a complete disaster-recovery capability.

## 5. Data Provenance and Reproducibility

Each dataset should have sufficient documentation to identify its source, extraction date where known, temporal and geographical coverage, variables, units, processing history and limitations.

The FAOSTAT emissions records require particular care because the selected observations are reported as CO2-equivalent emissions and are identified by their source indicator and methodology. Their values should be preserved without an additional conversion.

The climate series should be identified as CRU TS v4.10 data obtained through the World Bank Climate Change Knowledge Portal. The underlying dataset provider and the distribution platform are distinct parts of the data provenance.

Where source metadata do not establish a particular processing detail, the documentation should identify it as unresolved rather than infer or invent a procedure.

SQL scripts, database schema definitions, source documentation and validation records should be maintained so that the analytical workflow can be inspected and reproduced.

## 6. Current Implementation

The current implementation establishes a PostgreSQL relational database for national statistical analysis over 1991–2020, with agricultural, climate, emissions and geographical reference components.

It supports structured storage, validation and exploratory analysis of selected indicators. Although geographical reference information is present, this does not establish that spatial geometries, spatial indexes, PostGIS operations or Earth observation processing have been implemented. These capabilities belong to the planned spatial extension and should be documented as implemented only after their development and validation.

The current national statistical analysis does not provide spatially explicit measurements of agricultural vulnerability. The presence of a geographical schema or provincial reference table should not be confused with the completion of spatial analysis.

## 7. Planned Development Workflow

The intended development sequence is:

1. Complete and review the current documentation and repository structure.
2. Complete the current Git review and commit workflow only after explicit approval.
3. Identify and validate suitable geographical and Earth observation datasets.
4. Establish the spatial data model and document its relationship to the existing relational database.
5. Acquire and preprocess the selected spatial datasets.
6. Develop and validate appropriate vegetation, land-cover, drought and heat indicators.
7. Integrate relevant spatial outputs with agricultural and environmental statistics.
8. Examine spatial patterns and assess the limitations and uncertainty of the resulting indicators.
9. Document the complete workflow, results and reproducibility requirements.

The sequence is intended to preserve a clear distinction between the implemented national statistical foundation and subsequent spatial analyses.

## 8. Limitations and Design Considerations

The current statistical database has national annual coverage for 1991–2020. This temporal and geographical structure limits the ability to investigate local exposure, seasonal processes and short-duration climate extremes.

The selected emissions categories are not a complete national greenhouse-gas inventory. The availability of provincial reference information does not imply that the agricultural, climate or emissions observations are spatially disaggregated to provincial level.

The planned Earth observation component will introduce additional considerations, including sensor differences, cloud contamination, temporal compositing, spatial resolution, classification uncertainty and the suitability of satellite-derived indicators for the Zambian agricultural context.

These limitations must be considered when selecting methods and interpreting results.

## 9. Expected Contribution

The intended contribution is an integrated and transparent analytical framework that connects agricultural productivity, climate information and selected agricultural emissions indicators with a pathway towards spatial and Earth observation analysis.

Its value lies not simply in storing datasets, but in establishing a documented and reproducible basis for examining agricultural and environmental patterns, identifying information gaps and supporting more geographically detailed investigations.
