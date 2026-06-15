with states as (
    select * from {{ ref('stg_provider_service') }}
),

final as (
    select DISTINCT
        provider_state,
        provider_state_fips_code,
        provider_country 
    from states
)

select * from final