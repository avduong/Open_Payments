with payments as (
    select * from {{ ref('stg_open_payments') }}
)

select
    record_id,
    change_type,
    payment_amount_usd,
    payment_count,
    payment_form,
    payment_nature,
    travel_city,
    travel_country,
    travel_state,
    physician_ownership_indicator,
    third_party_payment_recipient_indicator,
    third_party_entity_name,
    charity_indicator,
    third_party_equals_recipient_indicator,
    contextual_information,
    delay_in_publication_indicator,
    dispute_status,
    related_product_indicator,
    program_year,
    payment_publication_date,
    payment_date,
    date_trunc('month', payment_date)::date as payment_month,
    {{ dbt_utils.generate_surrogate_key(['manufacturer_gpo_id']) }}
    as manufacturer_key

- recipient_key (FK)
- manufacturer_key (FK)

from payments