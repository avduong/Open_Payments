# Open Payments dbt Project

A data engineering and analytics project built around the CMS Open Payments 2025 General Payments Dataset.

The project takes the publicly available Open Payments CSV data, loads it into PostgreSQL, and uses dbt to transform the raw data into clean, tested analytical models.

## Development Principles
The project will follow these principles:

- Keep raw source data unchanged.
- Use dbt sources to reference externally loaded data.
- Keep staging models close to the source structure.
- Perform cleaning and type standardization in staging.
- Use tests to validate important assumptions.
- Separate reusable transformations from final analytical models.
- Prefer clear, descriptive model and column names.
- Document important business logic.
- Avoid duplicating raw data unnecessarily.
- Use appropriate materializations based on model purpose and scale.
- Current Data Flow

## Project Status: In progress
Current stage: Design analytical fact and dimension models

Completed:
- Downloaded the 2025 Open Payments General Payments dataset
- Stored the original CSV locally
- Partitioned the CSV for ingestion
- Loaded the data into PostgreSQL
- Created a dbt project
- Connected dbt to PostgreSQL
- Configured a dedicated dbt development schema
- Registered the raw PostgreSQL table as a dbt source
- Created the first staging model
- Successfully built the staging model as a PostgreSQL view
- Standardized initial staging data types
- Added initial dbt data tests

## Next steps:
- Build analytical queries and metrics
- Evaluate performance and model materializations
- Architecture

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
- `payment_date` range check: Passed - no records outside of 2025.
- Payment records by month
    - January: 1177779
    - February: 1294752
    - March: 1402344
    - April: 1488614 
    - May: 1440029
    - June: 1322084
    - July: 1327688
    - August: 1346794
    - September: 1437050
    - October: 1604988
    - November: 1244090
    - December: 1045644
- Publication/payment date consistency check: Passed - no records with publication date prior to payment date.
- Distinct recipient state codes: 60 values (including AS, MP, GU, PR, VI, AA, AE, AP, DC, and null).
- Distinct manufacturer state codes: 49 values (including DC and null).
- Top 2 Payment Nature: Food and Beverage (91.52%), Travel and Lodging (3.86%).
- Change Type: New (99.97%), Add (0.03%)
- Indicator value distributions
  - Physician ownership: No (83.94%), NULL (16.02%), Yes (0.04%)
  - Third-party payment recipient: No Third Party Payment (98.97%), Entity (0.77%), Individual (0.26%)
  - Charity: NULL (73.73%), No (26.27%), Yes(<0.01%)
  - Third-party equals recipient: NULL (98.97%), No (0.81%), Yes (0.22%)
  - Delay in publication: No (100%)
  - Related product: Yes (93.61%), No (6.39%)
  - Product 1 coverage: Covered (91.04%), NULL (6.39%), Non-Covered (2.57%)
  - Product 2 Coverage: NULL (85.08%), Covered (14.45%), Non-Covered (0.47%)
  - Product 3 Coverage: NULL (96.62%), Covered (3.26%), Non-Covered (0.12%)
  - Product 4 Coverage: NULL (98.18%), Covered (1.76%), Non-Covered (0.06%)
  - Product 5 Coverage: NULL (98.83%), Covered (1.15%), Non-Covered (0.03%)
- Recipient type and specialty do not exhibit a strict one-to-one relationship in the observed data.
- Some records contain recipient specialties whose taxonomy category differs from the recipient's primary type.
- Records may have more than one specialty listed, and the same recipient can appear multiple times.

## Observations
- A $400,000,000 payment was identified as the maximum payment amount.
  - 114 payments of >= $1,000,000
  - 15 payments of >= $10,000,000
  - 1 payment of >= $100,000,000
  - The record is associated with a covered recipient teaching hospital, BioNTech SE, and has a payment nature of "Royalty or License."
  - The record was investigated as an outlier but was not identified as an obvious data-quality error.
  - No payment amount cap or outlier-removal rule will be applied based on this observation.
- Recipient type and specialty do not exhibit a strict one-to-one relationship in the observed data.
  - Records with recipient type `Doctor of Dentistry` were used as an initial case study to determine whether associated specialty values aligned with the recipient type.
  - Numerous records contained specialty values whose taxonomy category appeared inconsistent with the recipient type.
  - The source documentation does not establish a strict mapping between recipient type and specialty.
  - No recipient type–specialty combinations were classified as invalid based solely on this analysis but do prompt further investigation during analysis.
- Median and third quartile of payment amounts were $21.16 and $30.12, indicating that 75% payments were $30.12 or less.
- Monthly payment records were most numerous in October and least numerous in December, with noticeable variation.
- Recipient state codes included location beyond the 50 states.
- Manufacturer state codes included 49 distinct values, including DC and NULL.
- No payment records had a delay in publication.

## Profiling Decisions
- Indicator NULL values will be retained unless they represent an invalid or inconsistent value. 
- NULLs that represent non-applicability will not be converted to negative indicator values.
- `record_id` is unique and non-null and will be treated as the primary business identifier.
- `payment_amount_usd` is non-null and positive across all records.
  - dbt data test was added to ensure `payment_amount_usd` was positive.
- Payment amounts will be retained without an upper-bound filter.
- Raw source data will remain unchanged in the `public` schema.
- Data type standardization and field-level cleaning will occur in dbt staging models.
- Business-oriented transformations will be deferred to downstream analytical models.

## Fact and Dimension Models
Grain: One row represents one payment record from the 2025 Open Payments General Payments dataset, identified by record_id.

### Primary analytical questions

- How do payment volume and total payment amounts vary over time?
- How do payment volume and amounts differ across recipient types?
- Which manufacturers/GPOs account for the largest payment amounts and payment volumes?
- How do payment patterns differ by payment nature and payment form?
- How do payment patterns differ across recipient specialties and geographic locations?
- Are high-value payments concentrated among particular manufacturers, recipient types, payment natures, or time periods?

### Recipient identity and data-quality questions

- Can recipient_profile_id reliably identify a recipient across payment records?
- Can recipient_profile_id serve as the business identifier for recipients, and which recipient attributes can be treated as stable versus time-varying?
- Do recipient names, types, specialties, or locations vary within the same recipient profile?
- Do recipient identity inconsistencies differ by recipient type?

Tentative ERD:
                         dim_recipient
                              |
                       recipient_key
                              |
                              ↓
dim_manufacturer ---> fct_payments
       |                   |
       |                   | record_id
       |                   ↓
       |          bridge_payment_product
       |                   |
       |              product_key
       |                   |
       |                   ↓
       |              dim_product
       |
manufacturer_key

fct_payments
- record_id (PK)
- change_type
- payment_amount_usd
- payment_count
- payment_form
- payment_nature
- travel_city
- travel_country
- travel_state
- physician_ownership_indicator
- third_party_payment_recipient_indicator
- third_party_entity_name
- charity_indicator
- third_party_equals_recipient_indicator
- contextual_information
- delay_in_publication_indicator
- dispute_status
- related_product_indicator
- program_year
- payment_publication_date
- payment_date
- payment_month (new field)

- recipient_key (FK)
- manufacturer_key (FK)

dim_recipient
- recipient_key (PK)
- recipient_type 
- teaching_hospital_ccn
- teaching_hospital_id
- teaching_hospital_name
- recipient_profile_id
- recipient_npi
- recipient_first_name
- recipient_middle_name
- recipient_last_name
- recipient_name_suffix
- recipient_address_line_1
- recipient_address_line_2
- recipient_city
- recipient_state
- recipient_zip_code
- recipient_country
- recipient_province
- recipient_postal_code
- recipient_type_1
- recipient_type_2
- recipient_type_3
- recipient_type_4
- recipient_type_5
- recipient_type_6
- recipient_specialty_1
- recipient_specialty_2
- recipient_specialty_3
- recipient_specialty_4
- recipient_specialty_5
- recipient_specialty_6
- license_state_1
- license_state_2
- license_state_3
- license_state_4
- license_state_5
                       
dim_manufacturer
- manufacturer_key (PK)
- submitting_manufacturer_gpo_name
- manufacturer_gpo_id
- manufacturer_gpo_name
- manufacturer_gpo_state
- manufacturer_gpo_country                     
                       
dim_product
- product_key (PK)
- product_type
- product_category
- product_name
- product_ndc
- product_pdi

bridge_payment_product
- record_id (FK)
- product_key (FK)
- product_sequence
- coverage_indicator


- There are 1,022,575 distinct recipient profiles.
- Recipient attributes are not stable across payment records:
  - 97,368 profiles have multiple first names
  - 245,074 have multiple middle names
  - 106,147 have multiple last names
  - 505,158 have multiple addresses
5 recipient profiles have multiple NPIs.
  - 10561994 - Jodi Goldman was found to be listed with two different NPI's, one of which was the same as Angie Mikhail
  - 11335167 - Two providers found both of which only appeared once
  - 11951587 - 4 records with Nicole Dawn Mosley (NPI 1699663161) and 1 record with Kristen White (NPI 1194428490)
  - 4866542 - 13 records with Haley Ellis (NPI 1972098820) and 1 record with Alexandra Paz (NPI 1366058463)
  - 650359 - 3 records with Alexandra Newtson (NPI 1073925863) and 1 record with Rochelle Fayngor (NPI 1134879349)
- `recipient_profile_id` chosen as business identifier, since the conflicting NPIs were associated with different individuals (apparent source identity error) rather than legitimate one-to-many relationships between recipient profiles and NPIs