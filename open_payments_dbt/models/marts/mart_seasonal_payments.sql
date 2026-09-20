{{ config(
    materialized='table',
    indexes=[
        {'columns': ['payment_year', 'payment_month']}
    ]
) }}

with base_metrics as (
    select
        program_year as payment_year,
        payment_month,
        is_dental_sector,
        recipient_type,
        payment_nature,
        payment_form,
        (payment_amount_usd >= 1000000) as is_million_plus_payment,
        payment_amount_usd
        
    from {{ ref('open_payments_analytical_mart') }}
)

select
    payment_year,
    payment_month,
    is_dental_sector,
    recipient_type,
    payment_nature,
    payment_form,
    is_million_plus_payment,

    count(*) as total_payment_volume,
    sum(payment_amount_usd) as total_payment_amount_usd,
    avg(payment_amount_usd) as average_payment_amount_usd

from base_metrics
group by 1, 2, 3, 4, 5, 6, 7
