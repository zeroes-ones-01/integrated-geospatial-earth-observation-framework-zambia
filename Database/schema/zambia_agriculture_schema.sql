-- ============================================================
-- PROJECT: An Integrated Geospatial Database and Earth Observation Framework for Assessing Agricultural Productivity, Climate Vulnerability and Agricultural Greenhouse-Gas Emissions in Zambia
--          and Agricultural Emissions in Zambia
-- CREATOR AND MAINTAINER: Morgan Phiri
-- DATABASE: zambia_agriculture_db
-- DBMS: PostgreSQL 18
-- LICENSE: MIT
-- ============================================================
--
-- PostgreSQL database dump
--

\restrict XiP2VergJw1LAIutc9OEQLt1Qnv01Y4oru3Xlz5M3oZRrkvSwweUMgBBnIKtPzR

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: agriculture; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA agriculture;


ALTER SCHEMA agriculture OWNER TO postgres;

--
-- Name: climate; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA climate;


ALTER SCHEMA climate OWNER TO postgres;

--
-- Name: emissions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA emissions;


ALTER SCHEMA emissions OWNER TO postgres;

--
-- Name: geography; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA geography;


ALTER SCHEMA geography OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: fertilizer_nutrients; Type: TABLE; Schema: agriculture; Owner: postgres
--

CREATE TABLE agriculture.fertilizer_nutrients (
    fertilizer_emission_id integer CONSTRAINT fertilizer_by_nutrient_fertilizer_emission_id_not_null NOT NULL,
    nutrient text CONSTRAINT fertilizer_by_nutrient_nutrient_not_null NOT NULL,
    year integer CONSTRAINT fertilizer_by_nutrient_year_not_null NOT NULL,
    unit text CONSTRAINT fertilizer_by_nutrient_unit_not_null NOT NULL,
    value numeric(12,2) CONSTRAINT fertilizer_by_nutrient_value_not_null NOT NULL,
    CONSTRAINT chk_fertilizer_emission_value CHECK ((value >= (0)::numeric)),
    CONSTRAINT chk_fertilizer_emission_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE agriculture.fertilizer_nutrients OWNER TO postgres;

--
-- Name: annual_fertilizer_nutrients; Type: VIEW; Schema: agriculture; Owner: postgres
--

CREATE VIEW agriculture.annual_fertilizer_nutrients AS
 SELECT year,
    max(
        CASE
            WHEN (nutrient = 'Nitrogen'::text) THEN value
            ELSE NULL::numeric
        END) AS nitrogen_t,
    max(
        CASE
            WHEN (nutrient = 'Phosphate'::text) THEN value
            ELSE NULL::numeric
        END) AS phosphate_t,
    max(
        CASE
            WHEN (nutrient = 'Potash'::text) THEN value
            ELSE NULL::numeric
        END) AS potash_t
   FROM agriculture.fertilizer_nutrients
  GROUP BY year;


ALTER VIEW agriculture.annual_fertilizer_nutrients OWNER TO postgres;

--
-- Name: rainfall; Type: TABLE; Schema: climate; Owner: postgres
--

CREATE TABLE climate.rainfall (
    rainfall_id integer NOT NULL,
    year integer NOT NULL,
    rainfall_mm numeric(8,2) NOT NULL,
    CONSTRAINT chk_rainfall_value CHECK ((rainfall_mm >= (0)::numeric)),
    CONSTRAINT chk_rainfall_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE climate.rainfall OWNER TO postgres;

--
-- Name: temperature; Type: TABLE; Schema: climate; Owner: postgres
--

CREATE TABLE climate.temperature (
    temperature_id integer NOT NULL,
    year integer NOT NULL,
    avg_temperature_c numeric(5,2) NOT NULL,
    CONSTRAINT chk_temperature_range CHECK (((avg_temperature_c >= ('-20'::integer)::numeric) AND (avg_temperature_c <= (60)::numeric))),
    CONSTRAINT chk_temperature_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE climate.temperature OWNER TO postgres;

--
-- Name: co2_equivalent; Type: TABLE; Schema: emissions; Owner: postgres
--

CREATE TABLE emissions.co2_equivalent (
    emission_id integer NOT NULL,
    item text NOT NULL,
    year integer NOT NULL,
    unit text NOT NULL,
    value numeric(12,2) NOT NULL,
    CONSTRAINT chk_emission_value CHECK ((value >= (0)::numeric)),
    CONSTRAINT chk_emission_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE emissions.co2_equivalent OWNER TO postgres;

--
-- Name: annual_climate_emissions; Type: VIEW; Schema: climate; Owner: postgres
--

CREATE VIEW climate.annual_climate_emissions AS
 SELECT r.year,
    r.rainfall_mm,
    t.avg_temperature_c,
    max(
        CASE
            WHEN (e.item = 'Burning - Crop residues'::text) THEN e.value
            ELSE NULL::numeric
        END) AS burning_crop_residues_kt,
    max(
        CASE
            WHEN (e.item = 'Crop Residues'::text) THEN e.value
            ELSE NULL::numeric
        END) AS crop_residues_kt,
    max(
        CASE
            WHEN (e.item = 'Rice Cultivation'::text) THEN e.value
            ELSE NULL::numeric
        END) AS rice_cultivation_kt,
    max(
        CASE
            WHEN (e.item = 'Synthetic Fertilizers'::text) THEN e.value
            ELSE NULL::numeric
        END) AS synthetic_fertilizers_kt,
    sum(e.value) AS total_crop_emissions_kt
   FROM ((climate.rainfall r
     JOIN climate.temperature t ON ((r.year = t.year)))
     JOIN emissions.co2_equivalent e ON ((r.year = e.year)))
  GROUP BY r.year, r.rainfall_mm, t.avg_temperature_c;


ALTER VIEW climate.annual_climate_emissions OWNER TO postgres;

--
-- Name: annual_climate_fertilizer_emissions; Type: VIEW; Schema: agriculture; Owner: postgres
--

CREATE VIEW agriculture.annual_climate_fertilizer_emissions AS
 SELECT c.year,
    c.rainfall_mm,
    c.avg_temperature_c,
    f.nitrogen_t,
    f.phosphate_t,
    f.potash_t,
    c.synthetic_fertilizers_kt,
    c.total_crop_emissions_kt
   FROM (climate.annual_climate_emissions c
     JOIN agriculture.annual_fertilizer_nutrients f ON ((c.year = f.year)));


ALTER VIEW agriculture.annual_climate_fertilizer_emissions OWNER TO postgres;

--
-- Name: production; Type: TABLE; Schema: agriculture; Owner: postgres
--

CREATE TABLE agriculture.production (
    production_id integer NOT NULL,
    crop_id integer NOT NULL,
    year integer NOT NULL,
    value numeric(12,2) CONSTRAINT production_production_tonnes_not_null NOT NULL,
    unit character varying(50),
    CONSTRAINT chk_production_value CHECK ((value >= (0)::numeric)),
    CONSTRAINT chk_production_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE agriculture.production OWNER TO postgres;

--
-- Name: annual_emissions_intensity; Type: VIEW; Schema: agriculture; Owner: postgres
--

CREATE VIEW agriculture.annual_emissions_intensity AS
 SELECT p.year,
    sum(p.value) AS total_crop_production_tonnes,
    c.total_crop_emissions_kt,
    ((c.total_crop_emissions_kt * 1000000.0) / NULLIF(sum(p.value), (0)::numeric)) AS emissions_intensity_kg_co2e_per_tonne
   FROM (agriculture.production p
     JOIN climate.annual_climate_emissions c ON ((p.year = c.year)))
  GROUP BY p.year, c.total_crop_emissions_kt;


ALTER VIEW agriculture.annual_emissions_intensity OWNER TO postgres;

--
-- Name: crops; Type: TABLE; Schema: agriculture; Owner: postgres
--

CREATE TABLE agriculture.crops (
    crop_id integer NOT NULL,
    crop_name character varying(100) NOT NULL
);


ALTER TABLE agriculture.crops OWNER TO postgres;

--
-- Name: land_use; Type: TABLE; Schema: agriculture; Owner: postgres
--

CREATE TABLE agriculture.land_use (
    land_use_id integer NOT NULL,
    crop_id integer NOT NULL,
    year integer NOT NULL,
    value numeric(12,2) CONSTRAINT land_use_area_hectares_not_null NOT NULL,
    unit text,
    CONSTRAINT chk_landuse_area CHECK ((value >= (0)::numeric)),
    CONSTRAINT chk_landuse_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE agriculture.land_use OWNER TO postgres;

--
-- Name: yields; Type: TABLE; Schema: agriculture; Owner: postgres
--

CREATE TABLE agriculture.yields (
    yield_id integer NOT NULL,
    crop_id integer NOT NULL,
    year integer NOT NULL,
    value numeric(10,3) CONSTRAINT yields_yield_tonnes_per_hectare_not_null NOT NULL,
    unit text,
    CONSTRAINT chk_yield_value CHECK ((value >= (0)::numeric)),
    CONSTRAINT chk_yield_year CHECK (((year >= 1991) AND (year <= 2020)))
);


ALTER TABLE agriculture.yields OWNER TO postgres;

--
-- Name: crop_agriculture_climate; Type: VIEW; Schema: agriculture; Owner: postgres
--

CREATE VIEW agriculture.crop_agriculture_climate AS
 SELECT c.crop_id,
    c.crop_name,
    p.year,
    p.value AS production_value,
    p.unit AS production_unit,
    y.value AS yield_value,
    y.unit AS yield_unit,
    l.value AS land_use_value,
    l.unit AS land_use_unit,
    r.rainfall_mm,
    t.avg_temperature_c
   FROM (((((agriculture.crops c
     JOIN agriculture.production p ON ((c.crop_id = p.crop_id)))
     JOIN agriculture.yields y ON (((p.crop_id = y.crop_id) AND (p.year = y.year))))
     JOIN agriculture.land_use l ON (((p.crop_id = l.crop_id) AND (p.year = l.year))))
     JOIN climate.rainfall r ON ((p.year = r.year)))
     JOIN climate.temperature t ON ((p.year = t.year)))
  WHERE ((p.year >= 1991) AND (p.year <= 2020));


ALTER VIEW agriculture.crop_agriculture_climate OWNER TO postgres;

--
-- Name: crop_statistics; Type: TABLE; Schema: agriculture; Owner: postgres
--

CREATE TABLE agriculture.crop_statistics (
    stat_id integer NOT NULL,
    crop_id integer NOT NULL,
    year integer NOT NULL,
    indicator character varying(50) NOT NULL,
    value numeric(14,2) NOT NULL,
    unit character varying(50),
    CONSTRAINT chk_value CHECK ((value >= (0)::numeric)),
    CONSTRAINT chk_year CHECK (((year >= 1991) AND (year <= 2024)))
);


ALTER TABLE agriculture.crop_statistics OWNER TO postgres;

--
-- Name: crop_statistics_stat_id_seq; Type: SEQUENCE; Schema: agriculture; Owner: postgres
--

CREATE SEQUENCE agriculture.crop_statistics_stat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agriculture.crop_statistics_stat_id_seq OWNER TO postgres;

--
-- Name: crop_statistics_stat_id_seq; Type: SEQUENCE OWNED BY; Schema: agriculture; Owner: postgres
--

ALTER SEQUENCE agriculture.crop_statistics_stat_id_seq OWNED BY agriculture.crop_statistics.stat_id;


--
-- Name: crops_crop_id_seq; Type: SEQUENCE; Schema: agriculture; Owner: postgres
--

CREATE SEQUENCE agriculture.crops_crop_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agriculture.crops_crop_id_seq OWNER TO postgres;

--
-- Name: crops_crop_id_seq; Type: SEQUENCE OWNED BY; Schema: agriculture; Owner: postgres
--

ALTER SEQUENCE agriculture.crops_crop_id_seq OWNED BY agriculture.crops.crop_id;


--
-- Name: fertilizer_by_nutrient_fertilizer_emission_id_seq; Type: SEQUENCE; Schema: agriculture; Owner: postgres
--

CREATE SEQUENCE agriculture.fertilizer_by_nutrient_fertilizer_emission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agriculture.fertilizer_by_nutrient_fertilizer_emission_id_seq OWNER TO postgres;

--
-- Name: fertilizer_by_nutrient_fertilizer_emission_id_seq; Type: SEQUENCE OWNED BY; Schema: agriculture; Owner: postgres
--

ALTER SEQUENCE agriculture.fertilizer_by_nutrient_fertilizer_emission_id_seq OWNED BY agriculture.fertilizer_nutrients.fertilizer_emission_id;


--
-- Name: land_use_land_use_id_seq; Type: SEQUENCE; Schema: agriculture; Owner: postgres
--

CREATE SEQUENCE agriculture.land_use_land_use_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agriculture.land_use_land_use_id_seq OWNER TO postgres;

--
-- Name: land_use_land_use_id_seq; Type: SEQUENCE OWNED BY; Schema: agriculture; Owner: postgres
--

ALTER SEQUENCE agriculture.land_use_land_use_id_seq OWNED BY agriculture.land_use.land_use_id;


--
-- Name: production_production_id_seq; Type: SEQUENCE; Schema: agriculture; Owner: postgres
--

CREATE SEQUENCE agriculture.production_production_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agriculture.production_production_id_seq OWNER TO postgres;

--
-- Name: production_production_id_seq; Type: SEQUENCE OWNED BY; Schema: agriculture; Owner: postgres
--

ALTER SEQUENCE agriculture.production_production_id_seq OWNED BY agriculture.production.production_id;


--
-- Name: v_climate_productivity_annual; Type: VIEW; Schema: agriculture; Owner: postgres
--

CREATE VIEW agriculture.v_climate_productivity_annual AS
 SELECT p.year,
    round((sum(p.value) / NULLIF(sum(l.value), (0)::numeric)), 4) AS aggregate_productivity_t_per_ha,
    r.rainfall_mm,
    t.avg_temperature_c
   FROM (((agriculture.production p
     JOIN agriculture.land_use l ON (((p.crop_id = l.crop_id) AND (p.year = l.year))))
     JOIN climate.rainfall r ON ((p.year = r.year)))
     JOIN climate.temperature t ON ((p.year = t.year)))
  GROUP BY p.year, r.rainfall_mm, t.avg_temperature_c;


ALTER VIEW agriculture.v_climate_productivity_annual OWNER TO postgres;

--
-- Name: v_crop_yield_trends; Type: VIEW; Schema: agriculture; Owner: postgres
--

CREATE VIEW agriculture.v_crop_yield_trends AS
 SELECT c.crop_name,
    max(
        CASE
            WHEN (y.year = 1991) THEN (y.value / 1000.0)
            ELSE NULL::numeric
        END) AS yield_1991_t_per_ha,
    max(
        CASE
            WHEN (y.year = 2020) THEN (y.value / 1000.0)
            ELSE NULL::numeric
        END) AS yield_2020_t_per_ha,
    (max(
        CASE
            WHEN (y.year = 2020) THEN (y.value / 1000.0)
            ELSE NULL::numeric
        END) - max(
        CASE
            WHEN (y.year = 1991) THEN (y.value / 1000.0)
            ELSE NULL::numeric
        END)) AS absolute_change_t_per_ha,
    regr_slope(((y.value / 1000.0))::double precision, (y.year)::double precision) AS annual_change_t_per_ha_per_year,
    (regr_slope(((y.value / 1000.0))::double precision, (y.year)::double precision) * (10)::double precision) AS change_t_per_ha_per_decade,
    regr_r2((y.value)::double precision, (y.year)::double precision) AS r_squared
   FROM (agriculture.yields y
     JOIN agriculture.crops c ON ((y.crop_id = c.crop_id)))
  GROUP BY c.crop_name;


ALTER VIEW agriculture.v_crop_yield_trends OWNER TO postgres;

--
-- Name: yields_yield_id_seq; Type: SEQUENCE; Schema: agriculture; Owner: postgres
--

CREATE SEQUENCE agriculture.yields_yield_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE agriculture.yields_yield_id_seq OWNER TO postgres;

--
-- Name: yields_yield_id_seq; Type: SEQUENCE OWNED BY; Schema: agriculture; Owner: postgres
--

ALTER SEQUENCE agriculture.yields_yield_id_seq OWNED BY agriculture.yields.yield_id;


--
-- Name: rainfall_rainfall_id_seq; Type: SEQUENCE; Schema: climate; Owner: postgres
--

CREATE SEQUENCE climate.rainfall_rainfall_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE climate.rainfall_rainfall_id_seq OWNER TO postgres;

--
-- Name: rainfall_rainfall_id_seq; Type: SEQUENCE OWNED BY; Schema: climate; Owner: postgres
--

ALTER SEQUENCE climate.rainfall_rainfall_id_seq OWNED BY climate.rainfall.rainfall_id;


--
-- Name: temperature_temperature_id_seq; Type: SEQUENCE; Schema: climate; Owner: postgres
--

CREATE SEQUENCE climate.temperature_temperature_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE climate.temperature_temperature_id_seq OWNER TO postgres;

--
-- Name: temperature_temperature_id_seq; Type: SEQUENCE OWNED BY; Schema: climate; Owner: postgres
--

ALTER SEQUENCE climate.temperature_temperature_id_seq OWNED BY climate.temperature.temperature_id;


--
-- Name: v_climate_trends; Type: VIEW; Schema: climate; Owner: postgres
--

CREATE VIEW climate.v_climate_trends AS
 SELECT 'Rainfall'::text AS climate_variable,
    regr_slope((rainfall.rainfall_mm)::double precision, (rainfall.year)::double precision) AS annual_change,
    (regr_slope((rainfall.rainfall_mm)::double precision, (rainfall.year)::double precision) * (10)::double precision) AS change_per_decade,
    regr_r2((rainfall.rainfall_mm)::double precision, (rainfall.year)::double precision) AS r_squared,
    min(rainfall.rainfall_mm) AS minimum_value,
    max(rainfall.rainfall_mm) AS maximum_value,
    avg(rainfall.rainfall_mm) AS average_value
   FROM climate.rainfall
UNION ALL
 SELECT 'Temperature'::text AS climate_variable,
    regr_slope((temperature.avg_temperature_c)::double precision, (temperature.year)::double precision) AS annual_change,
    (regr_slope((temperature.avg_temperature_c)::double precision, (temperature.year)::double precision) * (10)::double precision) AS change_per_decade,
    regr_r2((temperature.avg_temperature_c)::double precision, (temperature.year)::double precision) AS r_squared,
    min(temperature.avg_temperature_c) AS minimum_value,
    max(temperature.avg_temperature_c) AS maximum_value,
    avg(temperature.avg_temperature_c) AS average_value
   FROM climate.temperature;


ALTER VIEW climate.v_climate_trends OWNER TO postgres;

--
-- Name: co2_equivalent_emission_id_seq; Type: SEQUENCE; Schema: emissions; Owner: postgres
--

CREATE SEQUENCE emissions.co2_equivalent_emission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE emissions.co2_equivalent_emission_id_seq OWNER TO postgres;

--
-- Name: co2_equivalent_emission_id_seq; Type: SEQUENCE OWNED BY; Schema: emissions; Owner: postgres
--

ALTER SEQUENCE emissions.co2_equivalent_emission_id_seq OWNED BY emissions.co2_equivalent.emission_id;


--
-- Name: provinces; Type: TABLE; Schema: geography; Owner: postgres
--

CREATE TABLE geography.provinces (
    province_id integer NOT NULL,
    province_name character varying(50) NOT NULL
);


ALTER TABLE geography.provinces OWNER TO postgres;

--
-- Name: provinces_province_id_seq; Type: SEQUENCE; Schema: geography; Owner: postgres
--

CREATE SEQUENCE geography.provinces_province_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geography.provinces_province_id_seq OWNER TO postgres;

--
-- Name: provinces_province_id_seq; Type: SEQUENCE OWNED BY; Schema: geography; Owner: postgres
--

ALTER SEQUENCE geography.provinces_province_id_seq OWNED BY geography.provinces.province_id;


--
-- Name: crop_statistics stat_id; Type: DEFAULT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.crop_statistics ALTER COLUMN stat_id SET DEFAULT nextval('agriculture.crop_statistics_stat_id_seq'::regclass);


--
-- Name: crops crop_id; Type: DEFAULT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.crops ALTER COLUMN crop_id SET DEFAULT nextval('agriculture.crops_crop_id_seq'::regclass);


--
-- Name: fertilizer_nutrients fertilizer_emission_id; Type: DEFAULT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.fertilizer_nutrients ALTER COLUMN fertilizer_emission_id SET DEFAULT nextval('agriculture.fertilizer_by_nutrient_fertilizer_emission_id_seq'::regclass);


--
-- Name: land_use land_use_id; Type: DEFAULT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.land_use ALTER COLUMN land_use_id SET DEFAULT nextval('agriculture.land_use_land_use_id_seq'::regclass);


--
-- Name: production production_id; Type: DEFAULT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.production ALTER COLUMN production_id SET DEFAULT nextval('agriculture.production_production_id_seq'::regclass);


--
-- Name: yields yield_id; Type: DEFAULT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.yields ALTER COLUMN yield_id SET DEFAULT nextval('agriculture.yields_yield_id_seq'::regclass);


--
-- Name: rainfall rainfall_id; Type: DEFAULT; Schema: climate; Owner: postgres
--

ALTER TABLE ONLY climate.rainfall ALTER COLUMN rainfall_id SET DEFAULT nextval('climate.rainfall_rainfall_id_seq'::regclass);


--
-- Name: temperature temperature_id; Type: DEFAULT; Schema: climate; Owner: postgres
--

ALTER TABLE ONLY climate.temperature ALTER COLUMN temperature_id SET DEFAULT nextval('climate.temperature_temperature_id_seq'::regclass);


--
-- Name: co2_equivalent emission_id; Type: DEFAULT; Schema: emissions; Owner: postgres
--

ALTER TABLE ONLY emissions.co2_equivalent ALTER COLUMN emission_id SET DEFAULT nextval('emissions.co2_equivalent_emission_id_seq'::regclass);


--
-- Name: provinces province_id; Type: DEFAULT; Schema: geography; Owner: postgres
--

ALTER TABLE ONLY geography.provinces ALTER COLUMN province_id SET DEFAULT nextval('geography.provinces_province_id_seq'::regclass);


--
-- Name: crop_statistics crop_statistics_pkey; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.crop_statistics
    ADD CONSTRAINT crop_statistics_pkey PRIMARY KEY (stat_id);


--
-- Name: crops crops_crop_name_key; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.crops
    ADD CONSTRAINT crops_crop_name_key UNIQUE (crop_name);


--
-- Name: crops crops_pkey; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.crops
    ADD CONSTRAINT crops_pkey PRIMARY KEY (crop_id);


--
-- Name: fertilizer_nutrients fertilizer_by_nutrient_pkey; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.fertilizer_nutrients
    ADD CONSTRAINT fertilizer_by_nutrient_pkey PRIMARY KEY (fertilizer_emission_id);


--
-- Name: land_use land_use_pkey; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.land_use
    ADD CONSTRAINT land_use_pkey PRIMARY KEY (land_use_id);


--
-- Name: production production_pkey; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.production
    ADD CONSTRAINT production_pkey PRIMARY KEY (production_id);


--
-- Name: yields yields_pkey; Type: CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.yields
    ADD CONSTRAINT yields_pkey PRIMARY KEY (yield_id);


--
-- Name: rainfall rainfall_pkey; Type: CONSTRAINT; Schema: climate; Owner: postgres
--

ALTER TABLE ONLY climate.rainfall
    ADD CONSTRAINT rainfall_pkey PRIMARY KEY (rainfall_id);


--
-- Name: temperature temperature_pkey; Type: CONSTRAINT; Schema: climate; Owner: postgres
--

ALTER TABLE ONLY climate.temperature
    ADD CONSTRAINT temperature_pkey PRIMARY KEY (temperature_id);


--
-- Name: co2_equivalent co2_equivalent_pkey; Type: CONSTRAINT; Schema: emissions; Owner: postgres
--

ALTER TABLE ONLY emissions.co2_equivalent
    ADD CONSTRAINT co2_equivalent_pkey PRIMARY KEY (emission_id);


--
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: geography; Owner: postgres
--

ALTER TABLE ONLY geography.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (province_id);


--
-- Name: provinces provinces_province_name_key; Type: CONSTRAINT; Schema: geography; Owner: postgres
--

ALTER TABLE ONLY geography.provinces
    ADD CONSTRAINT provinces_province_name_key UNIQUE (province_name);


--
-- Name: crop_statistics fk_crop; Type: FK CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.crop_statistics
    ADD CONSTRAINT fk_crop FOREIGN KEY (crop_id) REFERENCES agriculture.crops(crop_id);


--
-- Name: production fk_crop; Type: FK CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.production
    ADD CONSTRAINT fk_crop FOREIGN KEY (crop_id) REFERENCES agriculture.crops(crop_id);


--
-- Name: land_use fk_land_use_crop; Type: FK CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.land_use
    ADD CONSTRAINT fk_land_use_crop FOREIGN KEY (crop_id) REFERENCES agriculture.crops(crop_id);


--
-- Name: yields fk_yield_crop; Type: FK CONSTRAINT; Schema: agriculture; Owner: postgres
--

ALTER TABLE ONLY agriculture.yields
    ADD CONSTRAINT fk_yield_crop FOREIGN KEY (crop_id) REFERENCES agriculture.crops(crop_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict XiP2VergJw1LAIutc9OEQLt1Qnv01Y4oru3Xlz5M3oZRrkvSwweUMgBBnIKtPzR
