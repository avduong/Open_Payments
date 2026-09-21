{{ config(
    materialized='table',
    indexes=[
        {'columns': ['recipient_profile_id']}
    ]
) }}

with profile_aggregation as (
    select
        recipient_profile_id,
        recipient_type,
        recipient_specialty_1 as primary_specialty,
        recipient_state,
        is_dental_sector,

        -- Aggregating financial totals
        sum(payment_amount_usd) as total_vendor_spend_usd,
        count(*) as total_payment_volume,
        count(distinct manufacturer_gpo_name) as unique_vendors_engaged,
        
        -- Segmenting values for Ultimate Question calculation
        sum(case 
            when payment_nature in ('Travel and Lodging', 'Food and Beverage', 'Gift', 'Entertainment') 
            then payment_amount_usd else 0 
        end) as benefits_in_kind_usd,
        
        sum(case 
            when payment_nature in ('Consulting Fee', 'Honoraria', 'Compensation for services other than consulting', 'Speaker Fee') 
            then payment_amount_usd else 0 
        end) as direct_cash_compensation_usd

    from {{ ref('open_payments_analytical_mart') }}
    group by 1, 2, 3, 4, 5
)

select 
    *,
    -- Value-Based Care Risk Math
    case 
        when unique_vendors_engaged = 0 then 0.0
        -- High dollar concentration inside very few vendors highlights clinical capture risk
        else round((total_vendor_spend_usd / unique_vendors_engaged)::numeric, 2)
    end as vendor_concentration_factor,

    case 
        when total_vendor_spend_usd = 0 then 0.0
        else round((benefits_in_kind_usd / total_vendor_spend_usd)::numeric, 4)
    end as in_kind_ratio

from profile_aggregation