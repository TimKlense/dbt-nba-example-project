-- models/stg_team_info_common.sql

-- Define the staging model named "stg_team_info_common"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_team_info_common') }}
),
renamed as (
    select
        team_id,
        season_year,
        team_city,
        team_name,
        team_abbreviation,
        team_conference,
        team_division,
        team_code,
        team_slug,
        w,
        l,
        pct,
        conf_rank,
        div_rank,
        min_year,
        max_year,
        league_id,
        season_id,
        pts_rank,
        pts_pg,
        reb_rank,
        reb_pg,
        ast_rank,
        ast_pg,
        opp_pts_rank,
        opp_pts_pg
    from source
)

select * from renamed