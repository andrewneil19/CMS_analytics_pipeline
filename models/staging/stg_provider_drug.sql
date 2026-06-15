with

source as (

    select * from {{ source('cms_raw', 'provider_drug') }}

),

renamed as (

    select
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_city,
        provider_state,
        provider_state_fips_code,
        provider_specialty_code,
        provider_specialty_src as provider_specialty_code_source,
        drug_brand_name,
        drug_generic_name,
        total_claims,
        total_30d_fills as total_30_day_fills,
        total_day_supply,
        total_drug_cost,
        total_bene as total_beneficiaries,
        ge65_suppression_flag as age_65_plus_suppression_flag,
        total_ge65_claims as total_age_65_plus_claims,
        total_ge65_30d_fills as total_age_65_plus_30_day_fills,
        total_ge65_drug_cost as total_age_65_plus_drug_cost,
        total_ge65_day_supply as total_age_65_plus_day_supply,
        total_ge65_bene_suppression_flag as age_65_plus_beneficiary_suppression_flag,
        total_ge65_bene as total_age_65_plus_beneficiaries

    from source

)

select * from renamed