-- models/stg_draft_combine_stats.sql

-- Define the staging model named "stg_draft_combine_stats"

with source as (
    
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_draft_combine_stats') }}

),
renamed as (

SELECT
  season,
        player_id,
        first_name,
        last_name,
        player_name,
        position,
        height_wo_shoes,
        height_wo_shoes_ft_in,
        height_w_shoes,
        height_w_shoes_ft_in,
        weight,
        wingspan,
        wingspan_ft_in,
        standing_reach,
        standing_reach_ft_in,
        body_fat_pct,
        hand_length,
        hand_width,
        standing_vertical_leap,
        max_vertical_leap,
        lane_agility_time,
        modified_lane_agility_time,
        three_quarter_sprint,
        bench_press,
        spot_fifteen_corner_left,
        spot_fifteen_break_left,
        spot_fifteen_top_key,
        spot_fifteen_break_right,
        spot_fifteen_corner_right,
        spot_college_corner_left,
        spot_college_break_left,
        spot_college_top_key,
        spot_college_break_right,
        spot_college_corner_right,
        spot_nba_corner_left,
        spot_nba_break_left,
        spot_nba_top_key,
        spot_nba_break_right,
        spot_nba_corner_right,
        off_drib_fifteen_break_left,
        off_drib_fifteen_top_key,
        off_drib_fifteen_break_right,
        off_drib_college_break_left,
        off_drib_college_top_key,
        off_drib_college_break_right,
        on_move_fifteen,
        on_move_college
FROM
  source

)

select * from renamed
