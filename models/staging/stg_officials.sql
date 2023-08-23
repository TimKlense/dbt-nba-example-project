-- models/stg_officials.sql

-- Define the staging model named "stg_officials"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_officials') }}
),
renamed as (
    select
        game_id,
        official_id,
        first_name,
        last_name,
        jersey_num
    from source
)

select * from renamed