 select distinct
    recipient_profile_id,
    recipient_first_name,
    recipient_middle_name,
    recipient_last_name,
    recipient_name_suffix

from {{ ref('stg_open_payments') }}

where recipient_profile_id is not null