-- models/stg_line_score.sql

-- Define the staging model named "stg_line_score"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_line_score') }}
),
renamed as (
    select
        game_date_est,
        game_sequence,
        game_id,
        team_id_home,
        team_abbreviation_home,
        team_city_name_home,
        team_nickname_home,
        team_wins_losses_home,
        pts_qtr1_home,
        pts_qtr2_home,
        pts_qtr3_home,
        pts_qtr4_home,
        pts_ot1_home,
        pts_ot2_home,
        pts_ot3_home,
        pts_ot4_home,
        pts_ot5_home,
        pts_ot6_home,
        pts_ot7_home,
        pts_ot8_home,
        pts_ot9_home,
        pts_ot10_home,
        pts_home,
        team_id_away,
        team_abbreviation_away,
        team_city_name_away,
        team_nickname_away,
        team_wins_losses_away,
        pts_qtr1_away,
        pts_qtr2_away,
        pts_qtr3_away,
        pts_qtr4_away,
        pts_ot1_away,
        pts_ot2_away,
        pts_ot3_away,
        pts_ot4_away,
        pts_ot5_away,
        pts_ot6_away,
        pts_ot7_away,
        pts_ot8_away,
        pts_ot9_away,
        pts_ot10_away,
        pts_away
    from source
)

select * from renamed