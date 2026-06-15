with provider_with_service as (
    select
        'service' as source,
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_middle_initial,
        provider_credentials,
        provider_entity_code,
        provider_street_add_1,
        provider_street_add_2,
        provider_city,
        provider_zip,
        provider_ruca,
        provider_ruca_desc,
        provider_specialty_code,
        null as provider_specialty_code_source,
        provider_medicare_indicator
    from {{ ref('stg_provider_service') }}
),

provider_with_drug as (
    select
        'drug' as source,
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        null as provider_middle_initial,
        null as provider_credentials,
        null as provider_entity_code,
        null as provider_street_add_1,
        null as provider_street_add_2,
        provider_city,
        null as provider_zip,
        null as provider_ruca,
        null as provider_ruca_desc,
        provider_specialty_code,
        provider_specialty_code_source,
        null as provider_medicare_indicator --this is something to circle back to. there are indeed some providers with N for this column - why would they be in this dataset, and do i want to keep them?
    from {{ ref('stg_provider_drug') }}    
),

unioned as (
    select * from provider_with_service

    union all

    select * from provider_with_drug
),

ranked as (
    select *, 
        row_number() over (partition by provider_npi order by source desc) as rn
    from unioned
),

final as (
    select * from ranked
    where rn = 1
)

--Include all columns except source and rn
select * exclude (source, rn) from final

    