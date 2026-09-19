{{ config(
    indexes=[
      {'columns': ['record_id'], 'unique': true},
      {'columns': ['recipient_npi']},
      {'columns': ['payment_date', 'payment_nature']}
    ]
) }}

select
    record_id,
    change_type,
    recipient_type,
    teaching_hospital_ccn,
    teaching_hospital_id,
    teaching_hospital_name,
    recipient_profile_id,
    recipient_npi,
    recipient_first_name,
    recipient_middle_name,
    recipient_last_name,
    recipient_name_suffix,
    
    -- Address
    recipient_address_line_1,
    recipient_address_line_2,
    recipient_city,
    recipient_state,
    recipient_zip_code,
    recipient_country,
    recipient_province,
    recipient_postal_code,
    
    -- Recipient types & specialties
    recipient_type_1,
    recipient_type_2,
    recipient_type_3,
    recipient_type_4,
    recipient_type_5,
    recipient_type_6,

    case 
        when recipient_type_1 = 'Doctor of Dentistry'
          or recipient_type_2 = 'Doctor of Dentistry'
          or recipient_type_3 = 'Doctor of Dentistry'
          or recipient_type_4 = 'Doctor of Dentistry'
          or recipient_type_5 = 'Doctor of Dentistry'
          or recipient_type_6 = 'Doctor of Dentistry'
          then true 
        else false 
    end as is_dental_sector,

    recipient_specialty_1,
    recipient_specialty_2,
    recipient_specialty_3,
    recipient_specialty_4,
    recipient_specialty_5,
    recipient_specialty_6,
    
    -- Licenses
    license_state_1,
    license_state_2,
    license_state_3,
    license_state_4,
    license_state_5,
    
    -- Manufacturer / GPO
    submitting_manufacturer_gpo_name,
    manufacturer_gpo_id,
    manufacturer_gpo_name,
    manufacturer_gpo_state,
    manufacturer_gpo_country,
    
    -- Payment metrics
    payment_amount_usd,
    payment_date,
    date_part('month', payment_date)::integer as payment_month,
    payment_count,
    payment_form,
    payment_nature,
    
    -- Travel
    travel_city,
    travel_state,
    travel_country,
    
    -- Indicators
    physician_ownership_indicator,
    third_party_payment_recipient_indicator,
    third_party_entity_name,
    charity_indicator,
    third_party_equals_recipient_indicator,
    contextual_information,
    delay_in_publication_indicator,
    dispute_status,
    related_product_indicator,
    
    -- Product 1
    product_1_coverage_indicator,
    product_1_type,
    product_1_category,
    product_1_name,
    product_1_ndc,
    product_1_pdi,
    
    -- Product 2
    product_2_coverage_indicator,
    product_2_type,
    product_2_category,
    product_2_name,
    product_2_ndc,
    product_2_pdi,
    
    -- Product 3
    product_3_coverage_indicator,
    product_3_type,
    product_3_category,
    product_3_name,
    product_3_ndc,
    product_3_pdi,
    
    -- Product 4
    product_4_coverage_indicator,
    product_4_type,
    product_4_category,
    product_4_name,
    product_4_ndc,
    product_4_pdi,
    
    -- Product 5
    product_5_coverage_indicator,
    product_5_type,
    product_5_category,
    product_5_name,
    product_5_ndc,
    product_5_pdi,
    
    -- Metadata
    program_year,
    payment_publication_date

from {{ ref('stg_open_payments') }}