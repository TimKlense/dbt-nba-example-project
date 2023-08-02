-- models/stg_team.sql

-- Define the staging model named "stg_team"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_team') }}
),
renamed as (
    select
        id,
        full_name,
        abbreviation,
        nickname,
        city,
        state,
        year_founded
    from source
)

select * from renamed