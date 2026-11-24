






















An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
Project status: Work in progress
Study period: 1991–2020 for the current national statistical database
Geographical focus: Zambia
Implemented technologies: PostgreSQL and SQL
Potential supporting tools for planned extensions: Python, R, QGIS and Earth-observation data

1. Project overview
Agricultural production in Zambia is closely connected to climatic conditions, land resources and the management of agricultural inputs. Changes in rainfall and temperature can influence crop productivity, while agricultural production systems are also associated with greenhouse-gas emissions arising from activities such as synthetic fertiliser use, rice cultivation and the management or burning of crop residues. Understanding these relationships requires the integration of information that is frequently distributed across different datasets, statistical systems and analytical environments.

This project develops an integrated data framework for examining agricultural productivity, climatic conditions and selected agricultural greenhouse-gas emissions in Zambia. Its current implementation centres on a relational PostgreSQL database containing national agricultural, climatic, emissions and geographical reference data for the period 1991–2020. SQL-based validation and analytical procedures are used to assess data consistency, examine temporal patterns and investigate descriptive relationships between selected agricultural and climatic indicators.

The broader research direction is to extend this national statistical foundation through geospatial analysis and Earth observation. A subsequent phase is intended to investigate spatial and temporal variation in vegetation conditions, drought-related indicators and land-surface temperature, and to explore how these environmental indicators may complement conventional agricultural statistics. This spatial and satellite-based phase has not yet been completed and is not represented as an existing analytical output.

The project therefore has two connected dimensions: an implemented national-level agricultural and environmental database, and a planned geospatial and Earth-observation extension. Together, these are intended to provide a more integrated basis for investigating agricultural productivity, climate-related vulnerability and selected emissions patterns in Zambia.

2. Research aim and objectives
2.1 Overall aim
To develop an integrated geospatial database and Earth-observation framework for assessing agricultural productivity, climate vulnerability and selected agricultural greenhouse-gas emissions in Zambia, using national statistical analysis as the foundation for a subsequent spatial and satellite-based assessment.

2.2 Specific objectives
Integrate and organise relevant agricultural, climatic, emissions and geographical reference data within a relational PostgreSQL database.
Assess and document data quality, completeness, consistency and referential integrity across the integrated datasets.
Examine national trends in crop production, harvested area, crop yields, fertiliser nutrient use, rainfall and temperature between 1991 and 2020.
Investigate descriptive associations between selected climatic indicators and aggregate agricultural productivity, while distinguishing statistical association from causal inference.
Examine temporal changes in selected agricultural greenhouse-gas emissions categories between 1991 and 2020, preserving the source-reported CO2-equivalent values and documenting their estimation status and methodological limitations.
Design a future geospatial and Earth-observation extension for analysing vegetation conditions, drought-related patterns and land-surface temperature.
Develop an analytical framework for evaluating how national statistical indicators and future spatial indicators may be compared, subject to appropriate spatial and temporal compatibility.
3. Research questions
The current database and national-level analyses address the first group of questions. The remaining questions define the planned spatial research phase.

3.1 Questions addressed by the current database
How did crop production, harvested area and crop yields change in Zambia between 1991 and 2020?
How did national rainfall, temperature and fertiliser nutrient use vary over the same period?
What descriptive relationships are observable between selected climatic indicators and aggregate agricultural productivity?
How did the selected agricultural greenhouse-gas emissions categories change between 1991 and 2020?
3.2 Questions for the planned spatial phase
How do satellite-derived vegetation conditions, drought-related indicators and land-surface temperature vary across geographical areas and seasons in Zambia?
To what extent can these environmental indicators complement national agricultural statistics in identifying areas and periods potentially exposed to climate-related agricultural stress?
What are the principal uncertainties and limitations associated with integrating satellite-derived indicators, gridded climate information and agricultural statistics collected at different spatial and temporal resolutions?
4. Database architecture and technologies
The current database is implemented in PostgreSQL and organised into four schemas:

Schema	Main purpose
agriculture	Crop reference data, production, yields, harvested area and fertiliser nutrient use
climate	National rainfall and temperature records and related analytical outputs
emissions	Selected agricultural greenhouse-gas emissions expressed as carbon dioxide equivalents
geography	Provincial reference information
The database currently contains 10 physical tables and 8 analytical views. Its design separates subject areas while providing a structured basis for cross-domain queries. The current implementation includes agricultural records for 11 crops and annual observations spanning 1991–2020.

PostgreSQL provides the relational data-management environment, while SQL is used for validation, aggregation and statistical analysis. Python and R are available as supporting analytical environments, and QGIS is intended to support the future spatial component. The use of these tools does not imply that every planned analytical workflow has already been implemented.

5. Data sources and provenance
The current database draws on FAOSTAT for agricultural statistics and selected agricultural greenhouse-gas emissions indicators. Its national annual climate series are supplied in a workbook identified in its metadata as CRU TS v4.10, obtained through the World Bank Climate Change Knowledge Portal (CCKP). The Climatic Research Unit (CRU), University of East Anglia, is the underlying climate data provider, while the World Bank CCKP is the distribution platform. The CCKP identifies its historical climate observations as CRU data, while the CRU documentation provides the dataset's version information and recommended attribution. The identification of the particular workbook as v4.10 is based on the workbook metadata. No separate World Bank indicator series has yet been established as a source of records in the current database.

The available provenance documentation identifies the source datasets and providers, their established geographical and temporal coverage, measurement units where confirmed, and transformations applied to the observations. Some source-level metadata remains subject to verification, including confirmation of the climate workbook units against version-specific documentation. If additional World Bank indicator series or other datasets are incorporated in a future phase, their identifiers, metadata and intended use must be established before integration.

The selected emissions observations are obtained from FAOSTAT's Emissions Totals domain under the element "Emissions (CO2eq) (AR5)", element code 723113. FAOSTAT's methodological documentation states that its CO2-equivalent aggregates use the global-warming potentials from the IPCC Fifth Assessment Report and that the domain includes estimates calculated using IPCC Tier 1 methods. The source values are therefore preserved without an additional global-warming-potential conversion. The observations used in this project are identified as FAO Tier 1 estimates. The categories currently represented are rice cultivation, synthetic fertilisers, crop residues and the burning of crop residues. They constitute selected indicators rather than a complete inventory of Zambia's agricultural greenhouse-gas emissions.

6. Database validation and restoration
Data integrity is a central component of the project. Validation has included comparisons between selected source CSV records and their corresponding PostgreSQL tables, checks for missing and duplicate records, verification of business keys, examination of referential integrity and independent checks of analytical views.

For production, yields and land use, 990 of 990 records across the three datasets matched between the CSV sources and PostgreSQL. Each of these datasets contains 330 records, representing 11 crops over 30 years. Additional checks covered the environmental and emissions tables, reference records, database constraints and analytical views.

A custom-format PostgreSQL backup was restored into an isolated test database on 23 November 2026. The restoration verification reported matching row counts across 10 physical tables and 8 views, together with matching table fingerprints and sequence configurations and values. This demonstrates that the tested backup could be restored consistently in the tested environment. The test predates the structural corrections completed on 24 November 2026; it therefore verifies the database state restored on 23 November, not the subsequently corrected state. It does not, by itself, establish a complete disaster-recovery capability or cross-platform recovery.

The detailed validation and restoration records are retained in Documentation/validation_records/. The database backup is stored separately in Backups/database/. Each verification record should be interpreted according to its stated scope, date and limitations, rather than as a claim that every aspect of the wider research framework has been validated.

7. Preliminary national-level findings
The current analytical work provides an initial description of agricultural and climatic patterns over the 1991–2020 period. The findings below are descriptive and should be interpreted in light of the temporal coverage, crop coverage, aggregation and limitations of the underlying data.

7.1 Aggregate agricultural productivity
The aggregate productivity indicator is calculated as the combined production of the 11 crops represented in the database divided by their combined harvested area for each year:

Aggregate productivity (t/ha) = Total recorded production (t) ÷ Total recorded harvested area (ha)

This is an area-weighted aggregate indicator derived from the crop-level records; it is not the unweighted arithmetic mean of the 11 crop yields. The harvested-area denominator is the sum of the crop-specific harvested areas and should not be interpreted as a measure of unique physical cropland, since the same land may be harvested for more than one crop during a year.

The calculated indicator increased from approximately 1.98 tonnes per hectare in 1991 to 3.60 tonnes per hectare in 2020. Its mean over the study period was approximately 2.51 tonnes per hectare. A linear time-trend model produced an estimated slope of approximately 0.067 tonnes per hectare per year, with an R² of 0.783.

This result indicates a strong upward temporal pattern in the constructed aggregate indicator. It does not establish that the increase was caused by any single factor. Changes in crop composition, harvested area, production measurement and other unobserved influences may also affect the aggregate series.

7.2 Climate indicators and productivity
The correlation between the aggregate productivity indicator and annual rainfall was approximately 0.411, indicating a moderate positive association in the observed national series. The corresponding correlation with annual temperature was approximately −0.161, indicating a weak negative association.

These correlations are exploratory rather than causal estimates. National annual observations cannot, on their own, identify crop-specific responses, seasonal exposure, local drought conditions or the effects of other determinants such as management practices, input availability and technological change.

The estimated rainfall trend was approximately 5.24 mm per year, although the linear model explained a relatively modest proportion of the observed variation (R² approximately 0.212). The estimated temperature slope was approximately −0.0035 °C per year, with a very low R² of approximately 0.011. The latter result should not be interpreted as compelling evidence of a meaningful long-term cooling trend. The precipitation and temperature series are interpreted using the expected units of millimetres and degrees Celsius, respectively; these unit assignments remain subject to confirmation against version-specific metadata for the downloaded workbook.

Zambia-focused research has examined relationships between rainfall shocks and crop productivity, including implications for agricultural water-risk management (Matchaya et al., 2022). Other research has modelled climate-change impacts on rainfed maize yields under conventional and optimised crop-management conditions (Siatwiinda et al., 2021). These studies provide relevant research context, but they do not independently validate the correlations or trend estimates calculated in this project.

7.3 Agricultural production and harvested area
For the 11 crops represented in the database, total recorded production increased from approximately 2.04 million tonnes in 1991 to 8.06 million tonnes in 2020. Their combined recorded harvested area increased from approximately 1.03 million hectares to 2.24 million hectares over the same period.

These changes provide important context for interpreting the aggregate productivity indicator. Increases in total production should not be attributed exclusively to improved yields, because changes in harvested area and the composition of the crops represented in the database also contribute to aggregate production. These totals should not be interpreted as comprehensive national totals for every crop produced in Zambia.

7.4 Selected agricultural greenhouse-gas emissions
The four selected emissions categories increased in aggregate from approximately 379.80 kt CO2-equivalent in 1991 to 1,447.51 kt CO2-equivalent in 2020. Synthetic fertiliser emissions increased from approximately 221.22 kt to 1,057.93 kt CO2-equivalent over the same period.

These figures represent the source-reported CO2-equivalent values for the selected categories in the database. They should not be interpreted as Zambia's total agricultural emissions, nor should changes in emissions be attributed to changes in fertiliser application alone without further analysis of activity data, emission factors and other relevant drivers.

8. Planned geospatial and Earth-observation extension
The next substantive research phase will extend the current national statistical framework through spatially explicit environmental analysis. Its purpose is to investigate geographical and temporal variation that cannot be resolved using national annual aggregates alone.

The proposed work will consider:

Vegetation condition: satellite-derived vegetation indices, including the Normalised Difference Vegetation Index (NDVI) and Enhanced Vegetation Index (EVI), to investigate changes in vegetation greenness and condition. The MODIS/Terra MOD13Q1 product provides 16-day vegetation-index composites at 250 m spatial resolution.
Drought-related conditions: rainfall anomalies and vegetation-condition indicators to examine the spatial and temporal characteristics of agricultural and meteorological stress. CHIRPS combines satellite observations with station data to provide a precipitation record for monitoring rainfall patterns and extremes.
Land-surface temperature: satellite-derived surface-temperature products to investigate spatial patterns of surface heating, subject to product quality, retrieval limitations and the appropriate conversion of recorded digital numbers into physical temperature values. Landsat Collection 2 surface-temperature products require the application of their specified scaling factors.
Spatial integration: the use of appropriate administrative boundaries and other geographical reference data to summarise and compare environmental indicators across locations.
Statistical integration: carefully designed comparisons between spatial indicators and agricultural statistics, accounting for differences in geographical coverage, temporal frequency, spatial resolution and measurement definitions.
Candidate datasets may include CHIRPS precipitation estimates, MODIS vegetation-index products and Landsat Collection 2 surface-temperature products. Their suitability for Zambia, the selected study period and the intended spatial scale must be assessed before adoption. Their temporal coverage is not identical: MODIS MOD13Q1 observations begin in 2000 and therefore cannot provide a continuous record for the full 1991–2020 statistical period. CHIRPS and Landsat products have different temporal characteristics and must also be assessed for coverage, consistency and suitability across the intended study period.

Product-specific quality flags, missing observations, cloud contamination, sensor differences and known retrieval limitations must be considered. CHIRPS should be treated as a satellite-and-station precipitation product rather than as a purely satellite-derived measurement. Landsat surface-temperature observations require attention to sensor-specific coverage, retrieval conditions and scaling procedures.

The spatial phase will require a clearly defined study design, appropriate temporal compositing, spatial aggregation rules, validation procedures and an explicit treatment of uncertainty. Satellite-derived indicators will be treated as environmental proxies, not direct measurements of crop yield or agricultural vulnerability.

9. Methodological limitations
Several limitations constrain the interpretation of the current results.

National aggregation: national annual data conceal subnational differences, seasonal variation and localised climatic extremes.
Observational design: correlations and linear trends do not establish causal relationships.
Temporal coverage: the present statistical database covers 1991–2020; it does not automatically provide evidence about conditions after 2020.
Data provenance: no separate World Bank indicator series has yet been established in the current database; any such series incorporated in a future phase will require documented identifiers and metadata.
Emissions coverage: the four emissions categories represented are not a complete agricultural greenhouse-gas inventory.
Indicator construction: aggregate productivity is calculated as combined production divided by combined crop-specific harvested area for the 11 crops represented in the database. It is therefore an area-weighted aggregate indicator, not the arithmetic mean of crop-level yields. Its interpretation depends on the definitions, coverage and aggregation of the underlying production and harvested-area records.
Spatial analysis: the database's provincial reference records do not constitute a completed spatial analysis. Spatially explicit results require appropriate geographical datasets and methods.
Earth-observation uncertainty: satellite-derived indicators are subject to sensor, atmospheric, retrieval, resolution and temporal-compositing limitations. Their temporal coverage may also differ from that of the current national statistical database.
Comparability: agricultural statistics, climate grids and satellite products may differ in spatial support, temporal frequency and measurement concepts. Their integration requires explicit harmonisation rather than direct comparison of incompatible values.
10. Research Integrity and Reporting Principles
The project will be guided by internationally recognised principles of research integrity, including honesty, accountability, fairness, transparency and responsible research practice, as reflected in the Singapore Statement on Research Integrity (World Conferences on Research Integrity, 2010).

These principles require accurate attribution of data sources, transparent documentation of analytical methods, responsible interpretation of findings, appropriate acknowledgement of uncertainty and a clear distinction between completed work and proposed extensions. They also require research decisions and conclusions to be supported by the available evidence.

10.1 Data-source integrity
The current statistical database uses the following established sources:

FAOSTAT: agricultural statistics and selected agricultural greenhouse-gas emissions indicators.
CRU TS v4.10: the underlying climate dataset identified in the downloaded climate workbook, obtained through the World Bank Climate Change Knowledge Portal (CCKP). The Climatic Research Unit is the underlying data provider, while the CCKP is the confirmed distribution platform.
These sources must be attributed according to their actual roles. The CCKP must not be described as the original producer of the CRU observations.

Additional datasets must not be presented as integrated project sources until their identities, provenance and relevance have been established. Proposed Earth-observation and spatial datasets must remain clearly distinguished from data already incorporated into the database.

10.2 Accuracy and transparency in reporting
The project will distinguish between source observations, cleaned records, derived indicators and statistical estimates. Data transformations, measurement units and aggregation assumptions must be represented accurately in the research documentation.

The selected FAOSTAT emissions observations are already expressed in carbon-dioxide equivalents. No additional global-warming-potential conversion is applied. Their FAO Tier 1 estimation status must remain explicit, and the four selected emissions categories must not be represented as a complete agricultural greenhouse-gas inventory.

The climate observations currently analysed are national annual values for 1991–2020. They must not be presented as provincial, district-level or seasonal measurements.

10.3 Scientific interpretation
The interpretation of findings must remain proportionate to the evidence and methods available.

Descriptive trends and correlations do not, on their own, establish causal relationships. National annual observations cannot independently identify local climate exposure, crop-specific responses or seasonal agricultural vulnerability.

The construction of aggregate productivity and emissions-intensity indicators must be explained in terms of their component variables, units, geographical coverage and temporal scope. Selected-category emissions intensity must not be interpreted as a complete measure of agricultural carbon footprint.

10.4 Validation and research limitations
Technical validation and scientific validity are distinct. Successful database integrity checks, analytical-view comparisons and backup-restoration tests provide evidence about the specific properties examined. They do not establish that every source dataset is complete, that every measurement is free from uncertainty or that the wider research framework has been fully validated.

Validation claims must therefore be limited to the checks actually performed and documented. Unresolved source metadata, processing details and methodological uncertainties must be identified rather than inferred or presented as established facts.

10.5 Distinction between implemented and planned work
The current implementation comprises a national statistical PostgreSQL database and associated SQL-based validation and analysis. Geospatial analysis, spatially explicit climate-vulnerability assessment and Earth-observation integration remain planned extensions.

The project will not report spatial results, satellite-derived indicators or environmental-model outputs as completed findings until the relevant data have been integrated, the analytical methods implemented and the results evaluated.

11. Current status and next steps
The project remains in progress. The current implementation has established a relational database, completed a range of data-integrity checks, reproduced selected analytical outputs and tested a database backup-restoration procedure.

The next priorities are to:

maintain a complete source-level provenance record and document any additional World Bank indicator series before integrating them;
complete and critically review the research problem, conceptual framework and research questions;
document the existing analytical methods and the construction of the aggregate productivity indicator;
consolidate the academic literature underpinning the climate, agricultural productivity, emissions and Earth-observation components;
design the spatial study, including study-area selection, data-product suitability, temporal coverage, spatial resolution and validation;
implement and evaluate the planned vegetation, drought and land-surface temperature analyses; and
assess how the resulting spatial indicators can be integrated with the existing agricultural database without overstating their explanatory power.
The project will progress from a validated national statistical foundation towards a more spatially explicit assessment of agricultural and environmental conditions in Zambia. Its conclusions will remain bounded by the evidence, methods and data available at each stage of development.

References
Climatic Research Unit (n.d.). CRU TS Version 4.10. University of East Anglia. Available at: https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.10/ (Accessed: 24 November 2026).

Food and Agriculture Organization of the United Nations (FAO) (n.d.). FAOSTAT Statistical Database. Available at: https://www.fao.org/faostat/en/#data (Accessed: 24 November 2026).

Food and Agriculture Organization of the United Nations (FAO) (2023). FAOSTAT Domain Emissions Totals: Methodological Note. Release October 2023. Available at: https://files-faostat.fao.org/production/GT/GT_en.pdf.

Funk, C., Peterson, P., Landsfeld, M., Pedreros, D., Verdin, J., Shukla, S., Husak, G., Rowland, J., Harrison, L., Hoell, A. and Michaelsen, J. (2015). The climate hazards infrared precipitation with stations—a new environmental record for monitoring extremes. Scientific Data, 2, 150066. https://doi.org/10.1038/sdata.2015.66

Harris, I., Osborn, T.J., Jones, P. and Lister, D. (2020). Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. Scientific Data, 7, 109. https://doi.org/10.1038/s41597-020-0453-3

Intergovernmental Panel on Climate Change (IPCC) (2013). Climate Change 2013: The Physical Science Basis. Contribution of Working Group I to the Fifth Assessment Report of the Intergovernmental Panel on Climate Change. Cambridge University Press. https://doi.org/10.1017/CBO9781107415324

Matchaya, G.C., Tadesse, G. and Kuteya, A.N. (2022). Rainfall shocks and crop productivity in Zambia: Implication for agricultural water risk management. Agricultural Water Management, 269, 107648. https://doi.org/10.1016/j.agwat.2022.107648

National Aeronautics and Space Administration (NASA) Land Processes Distributed Active Archive Center (LP DAAC) (n.d.). MODIS/Terra Vegetation Indices 16-Day L3 Global 250 m SIN Grid (MOD13Q1), Collection 6.1. Available at: https://ladsweb.modaps.eosdis.nasa.gov/missions-and-measurements/products/MOD13Q1/ (Accessed: 24 November 2026).

Siatwiinda, S.M., Supit, I., van Hove, B., Yerokun, O., Ros, G.H. and de Vries, W. (2021). Climate change impacts on rainfed maize yields in Zambia under conventional and optimized crop management. Climatic Change, 167, 39. https://doi.org/10.1007/s10584-021-03191-0

United States Geological Survey (USGS) (n.d.-a). Landsat Collection 2 Surface Temperature. Available at: https://www.usgs.gov/landsat-missions/landsat-collection-2-surface-temperature (Accessed: 24 November 2026).

United States Geological Survey (USGS) (n.d.-b). How do I use a scale factor with Landsat Level-2 science products? Available at: https://www.usgs.gov/faqs/how-do-i-use-a-scale-factor-landsat-level-2-science-products (Accessed: 24 November 2026).

World Bank Group (n.d.). Climate Change Knowledge Portal: Climatology (CRU), Zambia. Available at: https://climateknowledgeportal.worldbank.org/node/5735 (Accessed: 24 November 2026).

World Conferences on Research Integrity (2010). Singapore Statement on Research Integrity. Second World Conference on Research Integrity, Singapore. Available at: https://www.wcrif.org/guidance/singapore-statement.





