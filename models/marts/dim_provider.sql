with providers as (
    select * from {{ ref('int_provider_union') }}
),

us_providers as (
    select
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_credentials,
        provider_entity_code,
        provider_city,
        provider_zip,
        provider_ruca_desc,
        provider_state,
        provider_state_fips_code,
        provider_country,
        provider_specialty_code,
        provider_medicare_indicator
    from providers
    where provider_country = 'US'
),

final as (
    select
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_credentials,
        provider_entity_code,
        provider_city,
        provider_zip,
        provider_ruca_desc,
        provider_state,
        provider_specialty_code,
        provider_medicare_indicator
    from us_providers
)

select * from final