select distinct
    recipient_profile_id

from {{ ref('stg_open_payments') }}

where recipient_profile_id is not null