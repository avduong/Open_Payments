{{ config(
    indexes=[
        {'columns': ['payment_year', 'payment_month']},
        {'columns': ['recipient_type']},
        {'columns': ['is_dental_sector']}
    ]
) }}

with base_metrics as (
    select
        -- Time Dimensions (Seasonality / Cycles)
        program_year as payment_year,
        payment_month,
        
        -- Recipient Dimensions (Volume & Amount Differences)
        recipient_type,
        is_dental_sector,
        recipient_specialty_1 as primary_specialty,
        recipient_state as geographic_location,
        
        -- Manufacturer Dimensions (Largest GPOs / Concentration)
        submitting_manufacturer_gpo_name as manufacturer_name,
        
        -- Payment Attributes (Nature / Form Differences)
        payment_nature,
        payment_form,

        -- High-Value Concentration Flags
        case when payment_amount_usd >= 1000000 then true else false end as is_million_plus_payment,

        -- Raw Metrics
        payment_amount_usd

    from {{ ref('open_payments_analytical_mart') }}
)

select
    payment_year,
    payment_month,
    recipient_type,
    is_dental_sector,
    primary_specialty,
    geographic_location,
    manufacturer_name,
    payment_nature,
    payment_form,
    is_million_plus_payment,

    -- Aggregated Business Metrics
    count(*) as total_payment_volume,
    sum(payment_amount_usd) as total_payment_amount_usd,
    avg(payment_amount_usd) as average_payment_amount_usd,
    
    -- Median calculation for skewed distributions (like that $400M outlier!)
    percentile_cont(0.5) within group (order by payment_amount_usd) as median_payment_amount_usd

from base_metrics
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10