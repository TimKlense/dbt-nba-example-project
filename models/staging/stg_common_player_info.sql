-- models/stg_common_player_info.sql

-- Define the staging model named "stg_common_player_info"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_common_player_info') }}
),
renamed as (
    select
        person_id,
        first_name,
        last_name,
        display_first_last,
        display_last_comma_first,
        display_fi_last,
        player_slug,
        birthdate,
        school,
        country,
        last_affiliation,
        height,
        weight,
        season_exp,
        jersey,
        position,
        rosterstatus,
        games_played_current_season_flag,
        team_id,
        team_name,
        team_abbreviation,
        team_code,
        team_city,
        playercode,
        from_year,
        to_year,
        dleague_flag,
        nba_flag,
        games_played_flag,
        draft_year,
        draft_round,
        draft_number,
        greatest_75_flag
    from source
)

select * from renamed
