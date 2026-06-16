-- ============================================================
-- Berka Banking Pipeline — Snowflake Setup
-- Creates the database, medallion schemas, and warehouse.
-- Run this once on a fresh Snowflake account.
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- Database that holds the whole project
CREATE DATABASE IF NOT EXISTS berka;
USE DATABASE berka;

-- Medallion layers:
--   bronze = raw data loaded as-is
--   silver = cleaned & typed
--   gold   = business-ready dimensional models
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Compute warehouse.
-- XSMALL is the cheapest size and plenty for this project.
-- AUTO_SUSPEND = 60 shuts it off after 60s idle to save credits.
CREATE WAREHOUSE IF NOT EXISTS berka_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Confirm everything got created
SHOW SCHEMAS IN DATABASE berka;
SHOW WAREHOUSES LIKE 'berka_wh';
