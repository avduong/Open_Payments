select
    -- Record metadata
    "Record_ID" as record_id,
    "Change_Type" as change_type,

    -- Recipient
    "Covered_Recipient_Type" as recipient_type,

    "Teaching_Hospital_CCN"::bigint::text
        as teaching_hospital_ccn,

    "Teaching_Hospital_ID"::bigint::text
        as teaching_hospital_id,

    "Teaching_Hospital_Name" as teaching_hospital_name,

    "Covered_Recipient_Profile_ID"::bigint::text
        as recipient_profile_id,

    "Covered_Recipient_NPI"::bigint::text
        as recipient_npi,

    "Covered_Recipient_First_Name" as recipient_first_name,
    "Covered_Recipient_Middle_Name" as recipient_middle_name,
    "Covered_Recipient_Last_Name" as recipient_last_name,
    "Covered_Recipient_Name_Suffix" as recipient_name_suffix,

    -- Recipient address
    "Recipient_Primary_Business_Street_Address_Line1"
        as recipient_address_line_1,

    "Recipient_Primary_Business_Street_Address_Line2"
        as recipient_address_line_2,

    "Recipient_City" as recipient_city,
    "Recipient_State" as recipient_state,
    "Recipient_Zip_Code" as recipient_zip_code,
    "Recipient_Country" as recipient_country,
    "Recipient_Province" as recipient_province,
    "Recipient_Postal_Code" as recipient_postal_code,

    -- Recipient classifications
    "Covered_Recipient_Primary_Type_1" as recipient_type_1,
    "Covered_Recipient_Primary_Type_2" as recipient_type_2,
    "Covered_Recipient_Primary_Type_3" as recipient_type_3,
    "Covered_Recipient_Primary_Type_4" as recipient_type_4,
    "Covered_Recipient_Primary_Type_5" as recipient_type_5,
    "Covered_Recipient_Primary_Type_6" as recipient_type_6,

    "Covered_Recipient_Specialty_1" as recipient_specialty_1,
    "Covered_Recipient_Specialty_2" as recipient_specialty_2,
    "Covered_Recipient_Specialty_3"::text as recipient_specialty_3,
    "Covered_Recipient_Specialty_4"::text as recipient_specialty_4,
    "Covered_Recipient_Specialty_5"::text as recipient_specialty_5,
    "Covered_Recipient_Specialty_6"::text as recipient_specialty_6,

    -- License states
    "Covered_Recipient_License_State_code1" as license_state_1,
    "Covered_Recipient_License_State_code2" as license_state_2,
    "Covered_Recipient_License_State_code3" as license_state_3,
    "Covered_Recipient_License_State_code4" as license_state_4,
    "Covered_Recipient_License_State_code5" as license_state_5,

    -- Manufacturer / GPO
    "Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name"
        as submitting_manufacturer_gpo_name,

    "Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID"
        as manufacturer_gpo_id,

    "Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name"
        as manufacturer_gpo_name,

    "Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State"
        as manufacturer_gpo_state,

    "Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Countr"
        as manufacturer_gpo_country,

    -- Payment
    "Total_Amount_of_Payment_USDollars"::numeric(14, 2)
        as payment_amount_usd,

    to_date("Date_of_Payment", 'MM/DD/YYYY')
        as payment_date,

    "Number_of_Payments_Included_in_Total_Amount"
        as payment_count,

    "Form_of_Payment_or_Transfer_of_Value"
        as payment_form,

    "Nature_of_Payment_or_Transfer_of_Value"
        as payment_nature,

    -- Travel
    "City_of_Travel" as travel_city,
    "State_of_Travel" as travel_state,
    "Country_of_Travel" as travel_country,

    -- Payment indicators
    "Physician_Ownership_Indicator"
        as physician_ownership_indicator,

    "Third_Party_Payment_Recipient_Indicator"
        as third_party_payment_recipient_indicator,

    "Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Val"
        as third_party_entity_name,

    "Charity_Indicator" as charity_indicator,

    "Third_Party_Equals_Covered_Recipient_Indicator"
        as third_party_equals_recipient_indicator,

    "Contextual_Information" as contextual_information,

    "Delay_in_Publication_Indicator"
        as delay_in_publication_indicator,

    -- Publication / dispute
    "Dispute_Status_for_Publication" as dispute_status,

    "Related_Product_Indicator" as related_product_indicator,

    -- Product 1
    "Covered_or_Noncovered_Indicator_1"
        as product_1_coverage_indicator,

    "Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_1"
        as product_1_type,

    "Product_Category_or_Therapeutic_Area_1"
        as product_1_category,

    "Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_1"
        as product_1_name,

    "Associated_Drug_or_Biological_NDC_1"
        as product_1_ndc,

    "Associated_Device_or_Medical_Supply_PDI_1"
        as product_1_pdi,

    -- Product 2
    "Covered_or_Noncovered_Indicator_2"
        as product_2_coverage_indicator,

    "Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_2"
        as product_2_type,

    "Product_Category_or_Therapeutic_Area_2"
        as product_2_category,

    "Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_2"
        as product_2_name,

    "Associated_Drug_or_Biological_NDC_2"
        as product_2_ndc,

    "Associated_Device_or_Medical_Supply_PDI_2"
        as product_2_pdi,

    -- Product 3
    "Covered_or_Noncovered_Indicator_3"
        as product_3_coverage_indicator,

    "Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_3"
        as product_3_type,

    "Product_Category_or_Therapeutic_Area_3"
        as product_3_category,

    "Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_3"
        as product_3_name,

    "Associated_Drug_or_Biological_NDC_3"
        as product_3_ndc,

    "Associated_Device_or_Medical_Supply_PDI_3"
        as product_3_pdi,

    -- Product 4
    "Covered_or_Noncovered_Indicator_4"
        as product_4_coverage_indicator,

    "Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_4"
        as product_4_type,

    "Product_Category_or_Therapeutic_Area_4"
        as product_4_category,

    "Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_4"
        as product_4_name,

    "Associated_Drug_or_Biological_NDC_4"
        as product_4_ndc,

    "Associated_Device_or_Medical_Supply_PDI_4"
        as product_4_pdi,

    -- Product 5
    "Covered_or_Noncovered_Indicator_5"
        as product_5_coverage_indicator,

    "Indicate_Drug_or_Biological_or_Device_or_Medical_Supply_5"
        as product_5_type,

    "Product_Category_or_Therapeutic_Area_5"
        as product_5_category,

    "Name_of_Drug_or_Biological_or_Device_or_Medical_Supply_5"
        as product_5_name,

    "Associated_Drug_or_Biological_NDC_5"
        as product_5_ndc,

    "Associated_Device_or_Medical_Supply_PDI_5"
        as product_5_pdi,

    -- Dataset metadata
    "Program_Year"::integer as program_year,

    to_date("Payment_Publication_Date", 'MM/DD/YYYY')
        as payment_publication_date

from {{ source('open_payments', 'general_payment_2025') }}

