-- Check record_id completeness and uniqueness
SELECT
    COUNT(*) AS total_rows,
    COUNT(record_id) AS non_null_record_ids,
    COUNT(DISTINCT record_id) AS distinct_record_ids
FROM dbt_dev.stg_open_payments;

-- Payment amount distribution
SELECT
    min(payment_amount_usd),
    max(payment_amount_usd),
    avg(payment_amount_usd)
FROM dbt_dev.stg_open_payments;

-- Identify max payment
SELECT
    record_id,
    recipient_type,
    recipient_first_name,
    recipient_last_name,
    manufacturer_gpo_name,
    payment_amount_usd,
    payment_date,
    payment_nature
FROM dbt_dev.stg_open_payments
WHERE payment_amount_usd = 400000000;

-- Recipient types
SELECT
    recipient_type,
    COUNT(*) AS row_count
FROM dbt_dev.stg_open_payments
GROUP BY recipient_type;

-- Payment forms
SELECT
    payment_form,
    count(*) AS row_count
FROM dbt_dev.stg_open_payments
GROUP BY payment_form
ORDER BY row_count DESC;

-- Output of this query is the actual query for finding null counts of each column
SELECT
    'SELECT ' ||
    string_agg(
        format(
            'COUNT(*) FILTER (WHERE %I IS NULL) AS %I_null_count',
            column_name,
            column_name
        ),
        ', ' ORDER BY ordinal_position
    ) ||
    ' FROM dbt_dev.stg_open_payments;'
FROM information_schema.columns
WHERE table_schema = 'dbt_dev'
  AND table_name = 'stg_open_payments';

-- Zero or negative payments
SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(payment_amount_usd IS NULL) AS null_amounts,
    COUNT_IF(payment_amount_usd <= 0) AS non_positive_amounts
FROM dbt_dev.stg_open_payments;

-- Q1, Q2, Q3 of payment amount
SELECT 
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY payment_amount_usd) AS first_quartile,
	PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY payment_amount_usd) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY payment_amount_usd) AS third_quartile
FROM dbt_dev.stg_open_payments;

-- Payment date range
SELECT MIN(payment_date), MAX(payment_date)
FROM dbt_dev.stg_open_payments;

-- Payment date distribution
SELECT EXTRACT(MONTH FROM payment_date) AS payment_month, COUNT(*)
FROM dbt_dev.stg_open_payments
GROUP BY payment_month;

-- Publication/payment date consistency
SELECT *
FROM dbt_dev.stg_open_payments
WHERE payment_date > payment_publication_date;

-- Distribution by state for recipient
SELECT
    payment_state,
    COUNT(*) AS record_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dbt_dev.stg_open_payments
GROUP BY payment_state
ORDER BY record_count DESC;

-- Distribution of payment nature. Used the same query template for all indicator categories
SELECT
    payment_nature,
    COUNT(*) AS record_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dbt_dev.stg_open_payments
GROUP BY payment_nature
ORDER BY record_count DESC;