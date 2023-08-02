-- models/stg_other_stats.sql

-- Define the staging model named "stg_other_stats"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_other_stats') }}
),
renamed as (
    select
        game_id,
        league_id,
        team_id_home,
        team_abbreviation_home,
        team_city_home,
        pts_paint_home,
        pts_2nd_chance_home,
        pts_fb_home,
        largest_lead_home,
        lead_changes,
        times_tied,
        team_turnovers_home,
        total_turnovers_home,
        team_rebounds_home,
        pts_off_to_home,
        team_id_away,
        team_abbreviation_away,
        team_city_away,
        pts_paint_away,
        pts_2nd_chance_away,
        pts_fb_away,
        largest_lead_away,
        team_turnovers_away,
        total_turnovers_away,
        team_rebounds_away,
        pts_off_to_away
    from source
)

select * from renamed