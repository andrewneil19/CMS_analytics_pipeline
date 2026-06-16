select 
    provider_npi,
    hcpcs_code,
    place_of_service,
    total_beneficiaries,
    total_services,
    total_beneficiaries_per_day_services,
    avg_submitted_charge,
    avg_medicare_allowed_amount,
    avg_medicare_payment_amount,
    avg_medicare_standardized_amount
from {{ ref('stg_provider_service') }}
WHERE provider_npi IN (SELECT provider_npi FROM dim_provider)