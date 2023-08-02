-- models/stg_inactive_players.sql

-- Define the staging model named "stg_inactive_players"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_inactive_players') }}
),
renamed as (
    select
        game_id,
        player_id,
        first_name,
        last_name,
        jersey_num,
        team_id,
        team_city,
        team_name,
        team_abbreviation
    from source
)

select * from renamed