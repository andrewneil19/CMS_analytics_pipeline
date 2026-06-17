# CMS Medicare Analytics Pipeline

A complete Snowflake → dbt → Power BI analytics pipeline built on real, publicly available CMS Medicare data — ~38 million rows across two datasets, modeled into a dimensional warehouse and surfaced through a Power BI semantic model.

**Stack:** Snowflake → dbt Cloud → Power BI

## Why this project

This is real, messy, public-sector data — not a synthetic or pre-cleaned dataset. The goal was to demonstrate the full analytics engineering lifecycle: hand-built Snowflake ingestion, a layered dbt project with tests and documentation, deliberate dimensional modeling decisions, and a BI semantic layer with consistent business definitions.

The CMS data itself is just the substrate. The same techniques here — grain verification, conformed dimensions, least-privilege roles, referential integrity testing — apply to any domain.

## Data

- **Medicare Physician & Other Practitioners by Provider and Service** (~9.8M rows) — provider-level medical claims summary
- **Medicare Part D Prescribers by Provider and Drug** (~28M rows) — provider-level prescription claims summary

Both are public, PHI-free files from [data.cms.gov](https://data.cms.gov).

## What this enables

The dimensional model supports questions an analyst could answer directly in Snowflake or by exploring the Power BI semantic model — without writing new SQL each time:

- Which states have the highest Medicare spend per service, or per beneficiary?
- Which provider specialties drive the most utilization, and how does that differ between facility and non-facility settings?
- Which drugs account for the largest share of total Part D cost, and how does that shift for beneficiaries 65+?
- Which providers prescribe at high volume relative to the services they render — and does that pattern cluster by specialty or geography?

None of these required custom SQL once the marts existed — that's the point of building a conformed dimensional model with consistent, documented measures: the hard modeling work happens once, and the questions on top of it become cheap to ask.

## Architecture

```
CMS flat files
   ↓ SnowSQL PUT + COPY INTO
Snowflake (raw)
   ↓ dbt staging (clean, rename, standardize)
   ↓ dbt intermediate (union + dedupe providers across sources)
   ↓ dbt marts (star schema: dimensions + facts)
Power BI (semantic model, Import mode)
```

![dbt lineage DAG](assets/dbt_lineage.png)

## Data model

**Dimensions**
- `dim_provider` — one row per provider NPI; conformed across both source datasets
- `dim_service` — one row per HCPCS code
- `dim_drug` — one row per drug brand/generic name combination, with a surrogate key (`drug_id`)

**Facts**
- `fct_services_rendered` — grain: provider × HCPCS code × place of service
- `fct_drugs_prescribed` — grain: provider × drug

`place_of_service` is treated as a degenerate dimension (only two values, no separate attributes worth normalizing).

![Power BI semantic model](assets/power_bi_semantic_model.png)

## Design decisions worth calling out

- **Grain verification, not assumption.** Table grain was identified from data dictionary clues ("for each X, Y, Z...") and then verified empirically with `GROUP BY` + `HAVING COUNT(*) > 1`. One initial grain assumption (provider × drug generic name) turned out to be wrong — verification caught it before it propagated downstream.
- **Conformed provider dimension.** Both source datasets describe providers using different/overlapping columns. An intermediate model unions and deduplicates them via `ROW_NUMBER()`, preferring the more complete source when a provider appears in both.
- **Surrogate vs. natural keys.** Dimension tables use surrogate keys (`dbt_utils.generate_surrogate_key`) where a composite natural key would be awkward to carry into fact tables (e.g. `dim_drug`). Fact tables themselves rely on natural composite keys — Kimball convention, since fact rows are queried by aggregation, not key lookup.
- **Degenerate dimension.** `place_of_service` has only two values and no other attributes, so it stays in the fact table rather than becoming its own dimension.
- **Least privilege.** dbt connects via a dedicated `transformer` role/`dbt_user`, scoped to `SELECT` on raw and full DML on dev/prod schemas — not the account admin role.
- **Import mode in Power BI.** The data is a static annual snapshot and the marts are already aggregated, so Import mode was chosen over DirectQuery for report performance and to avoid recurring Snowflake compute costs. In a production environment with regularly-refreshing source data, a single Import-mode model wouldn't be the right default — large fact tables would more typically use DirectQuery or a hybrid/dual storage model (dimensions on Import or dual mode, facts on DirectQuery or incremental refresh) to balance data freshness against query performance. Import made sense specifically because of the static, pre-aggregated nature of this dataset, not as a general recommendation.
- **Referential integrity caught a real issue.** When `dim_provider` was scoped to US-only providers, `relationships` tests on both fact tables failed — correctly flagging orphaned non-US records. Fact tables were filtered to match.

## dbt features demonstrated

- Layered architecture: staging → intermediate → marts
- Tests: `not_null`, `unique`, `accepted_values`, `unique_combination_of_columns`, `relationships` (47 tests passing across the project)
- Documentation: model and column descriptions powering a full lineage DAG
- An exposure representing the downstream Power BI semantic model
- Materializations: views for staging/intermediate, tables for marts
- Git branch/PR workflow for every layer of the build

## Scope and possible extensions

This project covers transformation and modeling end to end, but ingestion and orchestration were intentionally manual: raw files were loaded by hand via SnowSQL `PUT`/`COPY INTO`, and dbt runs were triggered manually rather than scheduled. That was a deliberate choice to keep the focus on dimensional modeling and dbt craft — but it's worth being upfront about, since it means this isn't a fully automated pipeline as built.

The same architecture generalizes well beyond CMS data:

- **Any regularly-updating insurance claims feed** (commercial, dental, workers' comp) could use this same staging → intermediate → marts structure and the same grain-verification approach. The main changes would be swapping the manual `COPY INTO` load for a scheduled ingestion tool (e.g. Airbyte or Fivetran) and adding an orchestrator (Airflow, dbt Cloud jobs) to trigger runs on each new batch — turning this into a genuinely automated, recurring pipeline rather than a one-time load.
- The dbt models themselves are written so that loading a new year's CMS data would flow through without modification, even without full automation.

## Repo structure

```
snowflake/      -- setup, raw table DDL, role/grant scripts (reference only)
models/
  staging/
  intermediate/
  marts/
  exposures/
assets/         -- screenshots referenced in this README
```
