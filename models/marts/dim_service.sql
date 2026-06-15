select distinct
    hcpcs_code,
    hcpcs_code_desc as hcpcs_code_description,
    hcpcs_drug_indicator
from {{ ref('stg_provider_service') }}