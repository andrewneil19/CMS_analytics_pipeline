with drugs as (
    select distinct
        drug_brand_name,
        drug_generic_name
    from {{ ref('stg_provider_drug') }}
),

final as (
    select 
        {{ dbt_utils.generate_surrogate_key(['drug_brand_name', 'drug_generic_name']) }} as drug_id,
        drug_brand_name,
        drug_generic_name
    from drugs
)

select * from final