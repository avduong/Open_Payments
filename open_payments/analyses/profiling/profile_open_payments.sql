-- Check record_id completeness and uniqueness
SELECT
    COUNT(*) AS total_rows,
    COUNT(record_id) AS non_null_record_ids,
    COUNT(DISTINCT record_id) AS distinct_record_ids
FROM dbt_dev.stg_open_payments;

-- Payment amount distribution
SELECT
    min(payment_amount_usd) AS min_payment_amount,
    max(payment_amount_usd) AS max_payment_amount,
    avg(payment_amount_usd) AS avg_payment_amount
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

-- What is the null count profile of each column? This query produces the actual query used to answer the question
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

-- Are there any payments of 0 or negative value?
SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(payment_amount_usd IS NULL) AS null_amounts,
    COUNT_IF(payment_amount_usd <= 0) AS non_positive_amounts
FROM dbt_dev.stg_open_payments;

-- What are the Q1, Q2, and Q3 values for payment amounts?
SELECT 
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY payment_amount_usd) AS first_quartile,
	PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY payment_amount_usd) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY payment_amount_usd) AS third_quartile
FROM dbt_dev.stg_open_payments;

-- What is the range of payment dates? Are they all in year 2025?
SELECT MIN(payment_date), MAX(payment_date)
FROM dbt_dev.stg_open_payments;

-- What is the distribution of records by month in 2025?
SELECT EXTRACT(MONTH FROM payment_date) AS payment_month, COUNT(*)
FROM dbt_dev.stg_open_payments
GROUP BY payment_month;

-- Do any records have payment publication dates before the actual payment date?
SELECT *
FROM dbt_dev.stg_open_payments
WHERE payment_date > payment_publication_date;

-- What is the distribution by state of payments?
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

-- What is the distribution of the payment nature column? (Used this template for all indicator categories)
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

-- Can record have more than one recipient type column populated?
SELECT
    CASE WHEN recipient_type_1 IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN recipient_type_2 IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN recipient_type_3 IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN recipient_type_4 IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN recipient_type_5 IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN recipient_type_6 IS NOT NULL THEN 1 ELSE 0 END AS type_count,
    COUNT(*) AS records
FROM dbt_dev.stg_open_payments
GROUP BY 1
ORDER BY 1;

-- Do records exist such that recipient_type_1 is null, while other recipient type columns are not?
SELECT *
FROM dbt_dev.stg_open_payments
WHERE recipient_type_1 is NULL 
	AND (recipient_type_2 is not null
		OR recipient_type_3 is not null
		OR recipient_type_4 is not null
		OR recipient_type_5 is not null
		OR recipient_type_6 is not null)
