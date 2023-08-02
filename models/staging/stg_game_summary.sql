-- models/stg_game_summary.sql

-- Define the staging model named "stg_game_summary"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_game_summary') }}
),
renamed as (
    select
        game_date_est,
        game_sequence,
        game_id,
        game_status_id,
        game_status_text,
        gamecode,
        home_team_id,
        visitor_team_id,
        season,
        live_period,
        live_pc_time,
        natl_tv_broadcaster_abbreviation,
        live_period_time_bcast,
        wh_status
    from source
)

select * from renamed