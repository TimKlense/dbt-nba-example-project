-- models/stg_game_info.sql

-- Define the staging model named "stg_game_info"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_game_info') }}
),
renamed as (
    select
        game_id,
        game_date,
        attendance,
        game_time
    from source
)

select * from renamed