select
    {{ dbt_utils.generate_surrogate_key(['drug_brand_name', 'drug_generic_name']) }} as drug_id,
    provider_npi,
    total_claims,
    total_30_day_fills,
    total_day_supply,
    total_drug_cost,
    total_beneficiaries,
    age_65_plus_suppression_flag,
    total_age_65_plus_claims,
    total_age_65_plus_30_day_fills,
    total_age_65_plus_drug_cost,
    total_age_65_plus_day_supply,
    age_65_plus_beneficiary_suppression_flag,
    total_age_65_plus_beneficiaries
from {{ ref('stg_provider_drug') }}
WHERE provider_npi IN (SELECT provider_npi FROM dim_provider)