with 

source as (

    select * from {{ source('cms_raw', 'provider_service') }}

),

renamed as (

    select
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_middle_initial,
        provider_credentials,
        provider_entity_code,
        provider_street_add_1,
        provider_street_add_2,
        provider_city,
        provider_state,
        provider_state_fips_code,
        provider_zip,
        provider_ruca,
        provider_ruca_desc,
        provider_country,
        provider_specialty_code,
        provider_medicare_indicator,
        hcpcs_code,
        hcpcs_code_desc,
        hcpcs_drug_indicator,
        place_of_service,
        total_beneficiaries,
        total_services,
        total_benef_day_services as total_beneficiaries_per_day_services,
        avg_submitted_charge,
        avg_medicare_allowed_amt as avg_medicare_allowed_amount,
        avg_medicare_pymt_amt as avg_medicare_payment_amount,
        avg_medicare_stdzd_amt as avg_medicare_standardized_amount

    from source

)

select * from renamed