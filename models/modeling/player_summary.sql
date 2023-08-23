-- models/player_summary.sql

-- Referring to the stage models
WITH
  player_info AS (
    SELECT
      person_id,
      first_name,
      last_name,
      birthdate,
      position,
      height,
      weight,
      season_exp,
      jersey,
      team_id,
      team_name,
      team_abbreviation,
      team_city
    FROM {{ ref('stg_common_player_info') }}
  ),
  draft_history AS (
    SELECT
      person_id,
      season,
      round_number,
      round_pick,
      overall_pick,
      draft_type,
      team_id,
      team_city,
      team_name,
      team_abbreviation,
      organization,
      organization_type
    FROM {{ ref('stg_draft_history') }}
  ),
  draft_combine AS (
    SELECT
      season,
      player_id,
      position,
      height_wo_shoes,
      height_w_shoes,
      weight,
      wingspan,
      standing_reach,
      body_fat_pct,
      hand_length,
      hand_width,
      standing_vertical_leap,
      max_vertical_leap,
      lane_agility_time,
      modified_lane_agility_time,
      three_quarter_sprint,
      bench_press
    FROM {{ ref('stg_draft_combine_stats') }}
  )

-- Joining the data
SELECT
  pi.person_id,
  pi.first_name,
  pi.last_name,
  pi.birthdate,
  pi.position,
  pi.height,
  pi.season_exp,
  pi.jersey,
  pi.team_id,
  pi.team_name,
  pi.team_abbreviation,
  pi.team_city,
  dh.season,
  dh.round_number,
  dh.round_pick,
  dh.overall_pick,
  dh.draft_type,
  dh.organization,
  dh.organization_type,
  dc.height_wo_shoes,
  dc.height_w_shoes,
  dc.weight,
  dc.wingspan,
  dc.standing_reach,
  dc.body_fat_pct,
  dc.hand_length,
  dc.hand_width,
  dc.standing_vertical_leap,
  dc.max_vertical_leap,
  dc.lane_agility_time,
  dc.modified_lane_agility_time,
  dc.three_quarter_sprint,
  dc.bench_press
FROM player_info pi
LEFT JOIN draft_history dh ON pi.person_id = dh.person_id
LEFT JOIN draft_combine dc ON pi.person_id = dc.player_id
