with recipient_name_counts as (

    select
        recipient_profile_id,
        lower(trim(recipient_first_name)) as recipient_first_name,
        lower(trim(recipient_middle_name)) as recipient_middle_name,
        lower(trim(recipient_last_name)) as recipient_last_name,
        lower(trim(recipient_name_suffix)) as recipient_name_suffix,
        count(*) as occurrence_count,
        max(payment_date) as last_seen_date

    from {{ ref('stg_open_payments') }}

    group by
        recipient_profile_id,
        lower(trim(recipient_first_name)),
        lower(trim(recipient_middle_name)),
        lower(trim(recipient_last_name)),
        lower(trim(recipient_name_suffix))

),

ranked_names as (

    select
        *,
        row_number() over (
            partition by recipient_profile_id
            order by
                occurrence_count desc,
                last_seen_date desc
        ) as name_rn

    from recipient_name_counts

),

recipient_profiles as (

    select
        s.*,
        row_number() over (
            partition by s.recipient_profile_id
            order by
                s.payment_date desc,
                s.record_id
        ) as profile_rn

    from {{ ref('stg_open_payments') }} s

    inner join ranked_names r
        on s.recipient_profile_id = r.recipient_profile_id
        and lower(trim(s.recipient_first_name)) = r.recipient_first_name
        and lower(trim(s.recipient_middle_name)) = r.recipient_middle_name
        and lower(trim(s.recipient_last_name)) = r.recipient_last_name
        and lower(trim(s.recipient_name_suffix)) = r.recipient_name_suffix
        and r.name_rn = 1

)

select
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
    recipient_address_line_1,
    recipient_address_line_2,
    recipient_city,
    recipient_state,
    recipient_zip_code,
    recipient_country,
    recipient_province,
    recipient_postal_code

from recipient_profiles
where profile_rn = 1