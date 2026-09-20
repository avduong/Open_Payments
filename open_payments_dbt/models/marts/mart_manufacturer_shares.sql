{{ config(
    materialized='table',
    indexes=[
        {'columns': ['manufacturer_gpo_name']}
    ]
) }}

with base_metrics as (
    select
        manufacturer_gpo_name,
        is_dental_sector,
        recipient_specialty_1 as primary_specialty,
        recipient_state,
        payment_amount_usd,
        (payment_amount_usd >= 1000000) as is_million_plus_payment
        
    from {{ ref('open_payments_analytical_mart') }}
)

select
    manufacturer_gpo_name,
    is_dental_sector,
    primary_specialty,
    recipient_state,
    is_million_plus_payment,

    sum(payment_amount_usd) as total_payment_amount_usd,
    count(*) as total_volume

from base_metrics
group by 1, 2, 3, 4, 5