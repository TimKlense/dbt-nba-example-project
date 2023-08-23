-- models/stg_team_history.sql

-- Define the staging model named "stg_team_history"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_team_history') }}
),
renamed as (
    select
        team_id,
        city,
        nickname,
        year_founded,
        year_active_till
    from source
)

select * from renamed
