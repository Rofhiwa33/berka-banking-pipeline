# Berka Banking Data Pipeline

An end-to-end data engineering project that takes raw banking data and turns it
into clean, analysis-ready tables in a cloud data warehouse — using the same
tools and patterns used by professional data teams.

**Stack:** PySpark (Databricks) → Snowflake → dbt → GitHub

---

## 1. The Business Problem

A retail bank has years of operational data sitting in raw files: customer records,
accounts, transactions, loans, and credit cards. On its own, this raw data is hard
to use — it's messy, spread across eight separate tables, written partly in another
language, and not shaped for analysis.

**The business wants to answer questions like:**

- Which customers are most likely to default on a loan?
- How do account balances change over time?
- Which regions (districts) have the most active customers?
- What does a typical customer's transaction behaviour look like?

To answer these reliably, the raw data first needs to be **cleaned, organised, and
modelled** into trustworthy tables that analysts and dashboards can query. That
pipeline — from raw files to business-ready tables — is what this project builds.

---

## 2. The Dataset

This project uses the **Berka dataset**: real, anonymised data from a Czech bank,
released for a data mining challenge in 1999. It is one of the few public, realistic
banking datasets available.

- ~5,300 clients
- ~4,500 accounts
- Over 1,000,000 transactions
- ~700 loans and ~900 credit cards
- 8 related tables

> The raw data is **not** stored in this repo. Download it from Kaggle
> ([the-berka-dataset](https://www.kaggle.com/datasets/marceloventura/the-berka-dataset))
> and place the files in `data/raw/`.

**The 8 tables:**

| Table            | What it holds                                |
|------------------|----------------------------------------------|
| `account`        | Bank accounts                                |
| `client`         | The people who own accounts                  |
| `disposition`    | Links clients to accounts (who owns what)    |
| `transaction`    | Every transaction (~1M rows — the big one)   |
| `permanent_order`| Standing/recurring payments                  |
| `loan`           | Loans granted to accounts                    |
| `card`           | Credit cards issued                          |
| `district`       | Demographic info per region                  |

---

## 3. How It Works (The Architecture)

The project follows the **medallion architecture** — a standard way to organise a
data warehouse into three layers. Data flows left to right, getting cleaner and more
useful at each step.

```
Raw CSV files
     │
     ▼
[ PySpark on Databricks ]   ← read, clean, transform ~1M transactions
     │
     ▼
[ SNOWFLAKE WAREHOUSE ]
     │
     ├── BRONZE   raw data, loaded as-is
     │
     ├── SILVER   cleaned & typed (dbt)
     │            - fixed dates, removed duplicates, translated values
     │
     └── GOLD     business-ready models (dbt)
                  - dim_client, dim_account, dim_district
                  - fct_transactions, fct_loans
                  - aggregates for analysis
```

**Why three layers?**

- **Bronze** keeps an untouched copy of the raw data, so we can always trace back.
- **Silver** is where the cleaning happens — one reliable, tidy version of the data.
- **Gold** is shaped for business questions — fact and dimension tables that
  dashboards and analysts query directly.

---

## 4. What Each Tool Does

| Tool          | Role in this project                                            |
|---------------|-----------------------------------------------------------------|
| **PySpark**   | Heavy lifting: read raw files, clean & transform large data     |
| **Databricks**| Free cloud environment to run the PySpark notebooks             |
| **Snowflake** | The cloud data warehouse where all the tables live              |
| **dbt**       | Builds the silver & gold models, runs tests, writes docs        |
| **GitHub**    | Version control — tracks every change to the project            |

---

## 5. Project Structure

```
berka-banking-pipeline/
├── data/raw/        # raw CSVs (not committed to git)
├── notebooks/       # PySpark notebooks (ingestion & cleaning)
├── dbt/             # dbt project (silver & gold models, tests)
├── scripts/         # setup and helper scripts (e.g. Snowflake SQL)
├── docs/            # diagrams and extra documentation
└── README.md        # this file
```

---


---

## 7. Snowflake Setup (Already Done)

The warehouse and schemas were created with this script (kept in `scripts/`):

```sql
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS berka;
USE DATABASE berka;

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

CREATE WAREHOUSE IF NOT EXISTS berka_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;
```

- **bronze / silver / gold** are the three medallion layers.
- **AUTO_SUSPEND = 60** turns the warehouse off after 60 seconds idle, so it
  doesn't waste credits.

---

