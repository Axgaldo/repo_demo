-- models/staging/stg_release_dates.sql
{{ config(
    database='MARVEL_BRONZE_DB',
    schema='STAGING'
) }}

with source as (
    select * 
    from {{ source('marvel_raw', 'raw_release_dates') }}
    -- Filtramos porque los tests demostraron que había 90 registros con errores
    where json_data:comic_id::int is not null 
      and json_data:release_date_raw::string is not null
)

select
    json_data:comic_id::int as issue_id,
    json_data:release_date_raw::string as release_date_raw,
    json_data:series_id::int as series_id
from source