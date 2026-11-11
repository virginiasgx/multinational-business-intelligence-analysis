/* DDL */
/* DATABASE AND STAGING TABLE */
CREATE DATABASE mreid_db;

USE mreid_db;

CREATE TABLE mreid_db.stg_mreid (
    id INT AUTO_INCREMENT PRIMARY KEY,
    iso3_o VARCHAR(3),
    country_o VARCHAR(100),
    iso3_d VARCHAR(3),
    country_d VARCHAR(100),
    year INT,
    naics2 INT,
    naics2description VARCHAR(255),
    extensive INT,
    greenfield INT,
    mergers INT,
    OperatingrevenueTurnover DECIMAL(18,4),
    OperatingrevenueTurnover_green DECIMAL(18,4),
    OperatingrevenueTurnover_mergers DECIMAL(18,4),
    TotalassetsthUSD DECIMAL(18,4),
    TotalassetsthUSD_green DECIMAL(18,4),
    TotalassetsthUSD_mergers DECIMAL(18,4),
    Numberofemployees DECIMAL(18,4),
    Numberofemployees_green INT,
    Numberofemployees_mergers INT,
    FixedassetsthUSD DECIMAL(18,4),
    FixedassetsthUSD_green DECIMAL(18,4),
    FixedassetsthUSD_mergers DECIMAL(18,4)
);

/* Check there are no NULL keys */
SELECT COUNT(*)
FROM stg_mreid
WHERE year IS NULL
   OR iso3_o IS NULL
   OR iso3_d IS NULL
   OR naics2 IS NULL;

/* Set record key - check duplicates */
ALTER TABLE mreid_db.stg_mreid
ADD COLUMN record_key VARCHAR(100);

UPDATE mreid_db.stg_mreid
SET record_key = CONCAT(
    iso3_o, '_',
    iso3_d, '_',
    year, '_',
    naics2
);

SELECT record_key, COUNT(*)
FROM mreid_db.stg_mreid
GROUP BY record_key
HAVING COUNT(*) > 1;

/* Add columns for exchange rate and conversion to EUR */
ALTER TABLE mreid_db.stg_mreid
ADD COLUMN exchange_rate DECIMAL(18,10),
ADD COLUMN OperatingrevenueTurnover_eur DECIMAL(20,4),
ADD COLUMN OperatingrevenueTurnover_green_eur DECIMAL(20,4),
ADD COLUMN OperatingrevenueTurnover_mergers_eur DECIMAL(20,4),
ADD COLUMN TotalassetsthUSD_eur DECIMAL(20,4),
ADD COLUMN TotalassetsthUSD_green_eur DECIMAL(20,4),
ADD COLUMN TotalassetsthUSD_mergers_eur DECIMAL(20,4),
ADD COLUMN FixedassetsthUSD_eur DECIMAL(20,4),
ADD COLUMN FixedassetsthUSD_green_eur DECIMAL(20,4),
ADD COLUMN FixedassetsthUSD_mergers_eur DECIMAL(20,4);

/* Check number of rows (329543 on csv) */
SELECT COUNT(*) FROM stg_mreid;

/* DIMENSION TABLES */
CREATE TABLE IF NOT EXISTS dim_countries (
  iso3 CHAR(3) NOT NULL,
  country VARCHAR(100) NOT NULL,
  PRIMARY KEY (iso3)
);
 
CREATE TABLE IF NOT EXISTS dim_sectors (
  naics2 TINYINT UNSIGNED NOT NULL,
  naics2description VARCHAR(200) NOT NULL,   -- trimmed (the CSV has trailing spaces)
  PRIMARY KEY (naics2)
);

CREATE TABLE IF NOT EXISTS dim_exchange_rates (
  `year`        SMALLINT      NOT NULL,
  exchange_rate DECIMAL(10,6) NOT NULL,
  PRIMARY KEY (`year`),
  CONSTRAINT chk_fx_positive CHECK (exchange_rate > 0)
);

/* FACT TABLE */
CREATE TABLE IF NOT EXISTS mreid_facts (

  -- DIMENSION KEYS
  `year` SMALLINT NOT NULL,
  iso3_o CHAR(3) NOT NULL,
  iso3_d CHAR(3) NOT NULL,
  naics2 TINYINT UNSIGNED NOT NULL,

  -- INVESTMENT
  extensive INT NULL,
  greenfield INT NULL,
  mergers INT NULL,

  -- OPERATING REVENUE (USD)
  OperatingrevenueTurnover DECIMAL(22,6) NULL,
  OperatingrevenueTurnover_green DECIMAL(22,6) NULL,
  OperatingrevenueTurnover_mergers DECIMAL(22,6) NULL,

  -- OPERATING REVENUE (EUR)
  OperatingrevenueTurnover_eur DECIMAL(22,6) NULL,
  OperatingrevenueTurnover_green_eur DECIMAL(22,6) NULL,
  OperatingrevenueTurnover_mergers_eur DECIMAL(22,6) NULL,

  -- TOTAL ASSETS (USD)
  TotalassetsthUSD DECIMAL(22,6) NULL,
  TotalassetsthUSD_green DECIMAL(22,6) NULL,
  TotalassetsthUSD_mergers DECIMAL(22,6) NULL,

  -- TOTAL ASSETS (EUR)
  TotalassetsthUSD_eur DECIMAL(22,6) NULL,
  TotalassetsthUSD_green_eur DECIMAL(22,6) NULL,
  TotalassetsthUSD_mergers_eur DECIMAL(22,6) NULL,

  -- EMPLOYEES
  Numberofemployees DECIMAL(22,6) NULL,
  Numberofemployees_green DECIMAL(22,6) NULL,
  Numberofemployees_mergers DECIMAL(22,6) NULL,

  -- FIXED ASSETS (USD)
  FixedassetsthUSD DECIMAL(22,6) NULL,
  FixedassetsthUSD_green DECIMAL(22,6) NULL,
  FixedassetsthUSD_mergers DECIMAL(22,6) NULL,

  -- FIXED ASSETS (EUR)
  FixedassetsthUSD_eur DECIMAL(22,6) NULL,
  FixedassetsthUSD_green_eur DECIMAL(22,6) NULL,
  FixedassetsthUSD_mergers_eur DECIMAL(22,6) NULL,

  -- PRIMARY KEY
  PRIMARY KEY (`year`, iso3_o, iso3_d, naics2),

  -- INDEXES
  KEY ix_destination_year_sector (iso3_d, `year`, naics2),
  KEY ix_origin_year (iso3_o, `year`),
  KEY ix_sector (naics2),

  -- FOREIGN KEYS
  CONSTRAINT fk_facts_origin
    FOREIGN KEY (iso3_o)
    REFERENCES dim_countries(iso3),

  CONSTRAINT fk_facts_destination
    FOREIGN KEY (iso3_d)
    REFERENCES dim_countries(iso3),

  CONSTRAINT fk_facts_sector
    FOREIGN KEY (naics2)
    REFERENCES dim_sectors(naics2),

  CONSTRAINT fk_facts_exchange_rate
    FOREIGN KEY (`year`)
    REFERENCES dim_exchange_rates(`year`)

);

/* LOAD STAGING TO FINAL TABLES */

/* COUNTRIES */
INSERT IGNORE INTO dim_countries (iso3, country)
SELECT iso3_o, TRIM(country_o)
FROM stg_mreid
UNION
SELECT iso3_d, TRIM(country_d)
FROM stg_mreid;

  /* Check number of countries */
    SELECT COUNT(DISTINCT iso3) AS total_unique_countries
  FROM (
      SELECT iso3_o AS iso3 FROM stg_mreid
      UNION
      SELECT iso3_d AS iso3 FROM stg_mreid
  ) combined_countries
  WHERE iso3 IS NOT NULL;

/* SECTORS */

INSERT IGNORE INTO dim_sectors (
    naics2,
    naics2description
)
SELECT DISTINCT
    naics2,
    TRIM(naics2description)
FROM stg_mreid;

/* EXCHANGE RATES */
INSERT IGNORE INTO dim_exchange_rates (
    year,
    exchange_rate
)
SELECT DISTINCT
    year,
    exchange_rate
FROM stg_mreid
WHERE exchange_rate IS NOT NULL;

/* Check naics code with different descriptions */
SELECT
    naics2,
    COUNT(DISTINCT TRIM(naics2description)) AS different_descriptions
FROM stg_mreid
WHERE naics2description IS NOT NULL
  AND TRIM(naics2description) <> ''
GROUP BY naics2
HAVING COUNT(DISTINCT TRIM(naics2description)) > 1;

/* Check orphan records—rows */
SELECT COUNT(*)
FROM stg_mreid r
LEFT JOIN dim_countries co
    ON r.iso3_o = co.iso3
LEFT JOIN dim_countries cd
    ON r.iso3_d = cd.iso3
LEFT JOIN dim_sectors s
    ON r.naics2 = s.naics2
LEFT JOIN dim_exchange_rates er
    ON r.year = er.year
WHERE co.iso3 IS NULL
   OR cd.iso3 IS NULL
   OR s.naics2 IS NULL
   OR er.year IS NULL;

/* FACTS */
INSERT INTO mreid_facts (
    `year`,
    iso3_o,
    iso3_d,
    naics2,

    extensive,
    greenfield,
    mergers,

    OperatingrevenueTurnover,
    OperatingrevenueTurnover_green,
    OperatingrevenueTurnover_mergers,

    OperatingrevenueTurnover_eur,
    OperatingrevenueTurnover_green_eur,
    OperatingrevenueTurnover_mergers_eur,

    TotalassetsthUSD,
    TotalassetsthUSD_green,
    TotalassetsthUSD_mergers,

    TotalassetsthUSD_eur,
    TotalassetsthUSD_green_eur,
    TotalassetsthUSD_mergers_eur,

    Numberofemployees,
    Numberofemployees_green,
    Numberofemployees_mergers,

    FixedassetsthUSD,
    FixedassetsthUSD_green,
    FixedassetsthUSD_mergers,

    FixedassetsthUSD_eur,
    FixedassetsthUSD_green_eur,
    FixedassetsthUSD_mergers_eur
)

SELECT
    r.year,
    r.iso3_o,
    r.iso3_d,
    r.naics2,

    r.extensive,
    r.greenfield,
    r.mergers,

    r.OperatingrevenueTurnover,
    r.OperatingrevenueTurnover_green,
    r.OperatingrevenueTurnover_mergers,

    r.OperatingrevenueTurnover_eur,
    r.OperatingrevenueTurnover_green_eur,
    r.OperatingrevenueTurnover_mergers_eur,

    r.TotalassetsthUSD,
    r.TotalassetsthUSD_green,
    r.TotalassetsthUSD_mergers,

    r.TotalassetsthUSD_eur,
    r.TotalassetsthUSD_green_eur,
    r.TotalassetsthUSD_mergers_eur,

    r.Numberofemployees,
    r.Numberofemployees_green,
    r.Numberofemployees_mergers,

    r.FixedassetsthUSD,
    r.FixedassetsthUSD_green,
    r.FixedassetsthUSD_mergers,

    r.FixedassetsthUSD_eur,
    r.FixedassetsthUSD_green_eur,
    r.FixedassetsthUSD_mergers_eur

FROM stg_mreid r;

/* Check duplicates */
SELECT
    year,
    iso3_o,
    iso3_d,
    naics2,
    COUNT(*)
FROM mreid_facts
GROUP BY year, iso3_o, iso3_d, naics2
HAVING COUNT(*) > 1;