with recipient_tree as (

    select
        recipient_profile_id,
        recipient_type,
        recipient_npi,
        payment_date,
        record_id

    from {{ ref('stg_open_payments') }}

    where recipient_profile_id is not null

),

recipient_profiles as (

    select
        *,
        row_number() over (
            partition by recipient_profile_id
            order by
                payment_date desc,
                record_id desc
        ) as profile_rn

    from recipient_tree

)

select
    recipient_profile_id,
    recipient_type,
    recipient_npi

from recipient_profiles
where profile_rn = 1