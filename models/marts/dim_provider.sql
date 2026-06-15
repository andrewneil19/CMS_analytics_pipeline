with providers as (
    select * from {{ ref('int_provider_union') }}
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
        provider_specialty_code,
        provider_medicare_indicator
    from providers
)

select * from final