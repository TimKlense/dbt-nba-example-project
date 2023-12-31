-- models/stg_game.sql

-- Define the staging model named "stg_game"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_game') }}
),
renamed as (
    select
        season_id,
        team_id_home,
        team_abbreviation_home,
        team_name_home,
        game_id,
        game_date,
        matchup_home,
        wl_home,
        min as minutes,
        fgm_home,
        fga_home,
        fg_pct_home,
        fg3m_home,
        fg3a_home,
        fg3_pct_home,
        ftm_home,
        fta_home,
        ft_pct_home,
        oreb_home,
        dreb_home,
        reb_home,
        ast_home,
        stl_home,
        blk_home,
        tov_home,
        pf_home,
        pts_home,
        plus_minus_home,
        video_available_home,
        team_id_away,
        team_abbreviation_away,
        team_name_away,
        matchup_away,
        wl_away,
        fgm_away,
        fga_away,
        fg_pct_away,
        fg3m_away,
        fg3a_away,
        fg3_pct_away,
        ftm_away,
        fta_away,
        ft_pct_away,
        oreb_away,
        dreb_away,
        reb_away,
        ast_away,
        stl_away,
        blk_away,
        tov_away,
        pf_away,
        pts_away,
        plus_minus_away,
        video_available_away,
        season_type
    from source
)

select * from renamed