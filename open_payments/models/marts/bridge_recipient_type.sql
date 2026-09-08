select
    recipient_profile_id,
    recipient_type,
    recipient_type_order
from {{ ref('stg_open_payments') }}