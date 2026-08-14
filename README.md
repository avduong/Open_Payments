# Open Payments dbt Project

A data engineering and analytics project built around the CMS Open Payments 2025 General Payments Dataset.

The project takes the publicly available Open Payments CSV data, loads it into PostgreSQL, and uses dbt to transform the raw data into clean, tested analytical models.

## Development Principles

The project will follow these principles:

Keep raw source data unchanged.
Use dbt sources to reference externally loaded data.
Keep staging models close to the source structure.
Perform cleaning and type standardization in staging.
Use tests to validate important assumptions.
Separate reusable transformations from final analytical models.
Prefer clear, descriptive model and column names.
Document important business logic.
Avoid duplicating raw data unnecessarily.
Use appropriate materializations based on model purpose and scale.
Current Data Flow

## Project Status: In progress

Current stage: Profile staging data

Completed:
Downloaded the 2025 Open Payments General Payments dataset
Stored the original CSV locally
Partitioned the CSV for ingestion
Loaded the data into PostgreSQL
Created a dbt project
Connected dbt to PostgreSQL
Configured a dedicated dbt development schema
Registered the raw PostgreSQL table as a dbt source
Created the first staging model
Successfully built the staging model as a PostgreSQL view
Standardized initial staging data types
Added initial dbt data tests

## Next steps:
Add additional staging transformations
Design analytical fact and dimension models
Add documentation
Build analytical queries and metrics
Evaluate performance and model materializations
Architecture

The current data flow is:

 CMS Open Payments
                    2025 CSV Dataset
                           |
                           v
                     Local CSV Data
                           |
                           v
                  Python Ingestion Scripts
                           |
                           v
                    +-------------+
                    | PostgreSQL  |
                    |  payment_db |
                    +-------------+
                           |
                           v
                    public schema
                           |
                           v
              general_payment_2025
                           |
                           |  dbt source()
                           v
                 +-------------------+
                 |  Staging Model    |
                 | stg_open_payments  |
                 +-------------------+
                           |
                           v
                 dbt_dev schema
                           |
                           v
                 Analytical Marts

The raw source data remains in the PostgreSQL public schema.
dbt creates transformed models in the dbt_dev schema.
This separation keeps the original data independent from transformations managed by dbt.

## Data Profiling

- Total row count: 16,131,856
- Unique row count: 16,131,856
- `record_id`: 16,131,856 unique, 16,131,856 non-null
- Average payment amount: $243.22
- Payment amount range: $0.01–$400,000,000
- First quartile (Q1): $15.79
- Median (Q2): $21.16
- Third quartile (Q3): $30.12
- Payment forms:
  - In-kind items and services: 13,911,080
  - Cash or cash equivalent: 2,220,038
  - Stock, stock option, or any other ownership interest: 287
  - Dividend, profit or other return on investment: 262
  - Stock option: 159
  - Stock: 30
- Recipient types:
  - Covered Recipient Physician: 10,129,623
  - Covered Recipient Non-Physician Practitioner: 5,966,664
  - Covered Recipient Teaching Hospital: 35,569
- Null patterns: [summary file](/open_payments/analyses/profiling/null_counts.csv)
  - Fields with no null values:
    - `record_id`
    - `change_type`
    - `recipient_type`
    - `recipient_country`
    - `submitting_manufacturer_gpo_name`
    - `manufacturer_gpo_id`
    - `manufacturer_gpo_name`
    - `manufacturer_gpo_country`
    - `payment_amount_usd`
    - `payment_date`
    - `payment_count`
    - `payment_form`
    - `payment_nature`
    - `third_party_payment_recipient_indicator`
    - `delay_in_publication_indicator`
    - `dispute_status`
    - `related_product_indicator`
    - `program_year`
    - `payment_publication_date`
- `payment_amount_usd` null check: Passed — no records have a null payment amount.
- `payment_amount_usd` positivity check: Passed — no records have a payment amount less than or equal to $0.00.
- Payment date range: 2025-01-01 to 2025-12-31
- 

## Observations
- Median and third quartile of payment amounts were $21.16 and $30.12, indicating that 75% payments were $30.12 or smaller.
- A $400,000,000 payment was identified as the maximum payment amount.
- The record is associated with a covered recipient teaching hospital, BioNTech SE, and has a payment nature of "Royalty or License."
- The record was investigated as an outlier but was not identified as an obvious data-quality error.
- No payment amount cap or outlier-removal rule will be applied based on this observation.
- 114 payments of >= $1,000,000
- 15 payments of >= $10,000,000
- 1 payment of >= $100,000,000

## Profiling Decisions

- `record_id` is unique and non-null and will be treated as the primary business identifier.
- `payment_amount_usd` is non-null and positive across all records.
- Payment amounts will be retained without an upper-bound filter.
- Raw source data will remain unchanged in the `public` schema.
- Data type standardization and field-level cleaning will occur in dbt staging models.
- Business-oriented transformations will be deferred to downstream analytical models.

Remaining checklist
Publication/payment date consistency	
Program year distribution	
Categorical distributions	
Geographic distributions		
Indicator value distributions	
Product-field consistency	
Recipient type/specialty consistency
Whitespace checks


Directory responsibilities
data/

Local copies of the source dataset.

raw/ contains the original downloaded CSV.
raw_partitioned/ contains smaller CSV partitions used during ingestion.

The raw data is not transformed by dbt.

scripts/

Python utilities used during ingestion and preparation of the source data.

partition.py partitions the original CSV.
load.py loads the data into PostgreSQL.
open_payments/

The actual dbt project.

This directory contains dbt_project.yml and all dbt models, tests, macros, seeds, snapshots, and related project files.

open_payments/models/staging/

Staging models provide the first transformation layer over the raw source data.

Current model:

stg_open_payments__general_payment
logs/

Runtime logs from the project.

Generated files should generally not be committed to version control.

PostgreSQL Setup

The data is currently stored in:

Database: payment_db
Raw schema: public
dbt development schema: dbt_dev

The raw table is:

public.general_payment_2025

The dbt staging model is:

dbt_dev.stg_open_payments__general_payment

The intended structure is:

payment_db
├── public
│   └── general_payment_2025
│
└── dbt_dev
    └── stg_open_payments

The raw table is not managed by dbt.

The staging model is managed by dbt.

dbt Configuration

The project uses:

dbt Core 1.12.0
PostgreSQL adapter 1.11.0
PostgreSQL
Python 3.14.3

The dbt development target uses:

database: payment_db
schema: dbt_dev
threads: 4

Database credentials are stored outside the repository in the local dbt profile.

dbt Source

The raw PostgreSQL table is registered as a dbt source:

sources:
  - name: open_payments
    schema: public
    tables:
      - name: general_payment_2025

Models reference the source using:

{{ source('open_payments', 'general_payment_2025') }}

This keeps database and schema details out of individual SQL models and allows dbt to understand the dependency between the raw source and downstream models.

Current Staging Model

The first staging model is:

stg_open_payments__general_payment

Its initial purpose is to create a cleaner interface over the raw Open Payments table.

For example:

Raw column	Staging column
Record_ID	record_id
Covered_Recipient_Profile_ID	recipient_profile_id
Covered_Recipient_NPI	recipient_npi
Covered_Recipient_First_Name	recipient_first_name
Covered_Recipient_Last_Name	recipient_last_name
Total_Amount_of_Payment_USDollars	payment_amount_usd
Date_of_Payment	payment_date
Program_Year	program_year

The initial model focuses on naming and organization.

Further transformations will address:

Date casting
Identifier types
Monetary values
Null handling
Data quality
Standardization of categorical fields
Product-related fields
dbt Commands

Run commands from the dbt project directory:

cd open_payments
Verify the dbt installation
dbt --version
Verify the project and database connection
dbt debug
List project resources
dbt ls
List the Open Payments source
dbt ls --select source:open_payments
Build a specific model
dbt run --select stg_open_payments__general_payment
Run all models
dbt run
Run tests
dbt test
Data Modeling Strategy

The project will follow a layered dbt architecture.

Sources

Existing raw data loaded into PostgreSQL.

public.general_payment_2025
Staging

Clean and standardize the source data.

stg_open_payments__general_payment

Responsibilities include:

Renaming columns
Casting data types
Standardizing values
Handling obvious source-level inconsistencies
Creating a reliable interface for downstream models
Intermediate

Business-oriented transformations that may require joins, aggregations, or restructuring.

Marts

Final analytical models designed for querying and reporting.

Potential future models include:

fct_payments
dim_recipients
dim_manufacturers
dim_products

These names are provisional and will be determined based on the final analytical requirements and the structure of the source data.

Data Quality Considerations

The raw dataset contains several fields that require careful treatment.

Examples:

Identifiers

Fields such as:

Covered_Recipient_NPI
Covered_Recipient_Profile_ID
Record_ID

are identifiers rather than numerical measurements.

They should therefore be treated accordingly during staging.

Dates

The raw dataset stores fields such as:

Date_of_Payment
Payment_Publication_Date

as text.

These will be converted to proper date types during staging.

Monetary values
Total_Amount_of_Payment_USDollars

requires appropriate numeric handling rather than being treated as a generic floating-point value.

Repeated product fields

The source contains multiple sets of product-related columns:

..._1
..._2
..._3
..._4
..._5

These may eventually be normalized into a separate product/payment relationship rather than remaining as repeated columns.



At the current stage, the implemented pipeline is:

general_payment_data_2025.csv
            |
            v
       scripts/load.py
            |
            v
PostgreSQL: payment_db.public
            |
            v
general_payment_2025
            |
            v
dbt source
            |
            v
stg_open_payments__general_payment
            |
            v
PostgreSQL: payment_db.dbt_dev

The staging model currently materializes as a PostgreSQL view.

Future Work

Complete staging transformations

Standardize all source column names

Convert date fields to proper date types

Correct identifier data types

Standardize monetary fields

Investigate null patterns

Add primary-key/uniqueness tests where appropriate

Add not-null tests where appropriate

Add accepted-value tests for categorical fields

Investigate duplicate records

Normalize repeated product fields

Design fact and dimension models

Add analytical marts

Add model documentation

Add lineage documentation

Evaluate table vs. view materializations

Add analytical queries/use cases

Improve ingestion pipeline

Add reproducible setup instructions

Notes

The target/ and generated log directories are dbt runtime artifacts and do not represent source code.

The local .env file contains environment-specific configuration and should not be committed to version control.