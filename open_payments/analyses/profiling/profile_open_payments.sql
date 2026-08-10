-- Row count
select count(*)
from dbt_dev.stg_open_payments;

-- Check for non-null or duplicate repeat record_id's
select
    count(*) as total_rows,
    count(record_id) as non_null_record_ids,
    count(distinct record_id) as distinct_record_ids
from dbt_dev.stg_open_payments;

-- Payment amount distribution
select
    min(payment_amount_usd),
    max(payment_amount_usd),
    avg(payment_amount_usd)
from dbt_dev.stg_open_payments;

-- Identify max payment
select
    record_id,
    recipient_type,
    recipient_first_name,
    recipient_last_name,
    manufacturer_gpo_name,
    payment_amount_usd,
    payment_date,
    payment_nature
from dbt_dev.stg_open_payments
where payment_amount_usd = 400000000;

-- Payment forms
select
    payment_form,
    count(*) as row_count
from dbt_dev.stg_open_payments
group by payment_form
order by row_count desc;