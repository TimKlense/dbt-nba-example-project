WITH stg_game AS (
  SELECT
    GAME_ID,
    GAME_DATE,
    TEAM_ID_HOME,
    TEAM_NAME_HOME,
    TEAM_ID_AWAY,
    TEAM_NAME_AWAY
  FROM {{ ref('stg_game') }}
), stg_game_summary AS (
  SELECT
    GAME_ID,
    GAME_DATE_EST,
    LIVE_PERIOD,
    LIVE_PC_TIME,
    GAME_STATUS_TEXT
  FROM {{ ref('stg_game_summary') }}
), stg_line_score AS (
  SELECT
    GAME_ID,
    PTS_QTR1_HOME,
    PTS_QTR2_HOME,
    PTS_QTR3_HOME,
    PTS_QTR4_HOME,
    PTS_OT1_HOME,
    PTS_OT2_HOME,
    PTS_OT3_HOME,
    PTS_OT4_HOME,
    PTS_OT5_HOME,
    PTS_OT6_HOME,
    PTS_OT7_HOME,
    PTS_OT8_HOME,
    PTS_OT9_HOME,
    PTS_OT10_HOME,
    PTS_HOME,
    PTS_QTR1_AWAY,
    PTS_QTR2_AWAY,
    PTS_QTR3_AWAY,
    PTS_QTR4_AWAY,
    PTS_OT1_AWAY,
    PTS_OT2_AWAY,
    PTS_OT3_AWAY,
    PTS_OT4_AWAY,
    PTS_OT5_AWAY,
    PTS_OT6_AWAY,
    PTS_OT7_AWAY,
    PTS_OT8_AWAY,
    PTS_OT9_AWAY,
    PTS_OT10_AWAY,
    PTS_AWAY
  FROM {{ ref('stg_line_score') }}
), stg_other_stats AS (
  SELECT
    GAME_ID,
    LEAGUE_ID,
    TEAM_ID_HOME,
    TEAM_ID_AWAY,
    PTS_PAINT_HOME,
    PTS_PAINT_AWAY,
    PTS_2ND_CHANCE_HOME,
    PTS_2ND_CHANCE_AWAY,
    PTS_FB_HOME,
    PTS_FB_AWAY,
    LARGEST_LEAD_HOME,
    LARGEST_LEAD_AWAY,
    LEAD_CHANGES,
    TIMES_TIED,
    TEAM_TURNOVERS_HOME,
    TOTAL_TURNOVERS_HOME,
    TEAM_REBOUNDS_HOME,
    PTS_OFF_TO_HOME,
    TEAM_TURNOVERS_AWAY,
    TOTAL_TURNOVERS_AWAY,
    TEAM_REBOUNDS_AWAY,
    PTS_OFF_TO_AWAY
  FROM {{ ref('stg_other_stats') }}
), join_2958 AS (
  SELECT
    stg_game.GAME_ID,
    stg_game.GAME_DATE,
    stg_game.TEAM_ID_HOME,
    stg_game.TEAM_NAME_HOME,
    stg_game.TEAM_ID_AWAY,
    stg_game.TEAM_NAME_AWAY,
    stg_game_summary.GAME_DATE_EST,
    stg_game_summary.LIVE_PERIOD,
    stg_game_summary.LIVE_PC_TIME,
    stg_game_summary.GAME_STATUS_TEXT
  FROM stg_game
  JOIN stg_game_summary
    ON stg_game.GAME_ID = stg_game_summary.GAME_ID
), join_197f AS (
  SELECT
    join_2958.GAME_ID,
    join_2958.GAME_DATE,
    join_2958.TEAM_ID_HOME,
    join_2958.TEAM_NAME_HOME,
    join_2958.TEAM_ID_AWAY,
    join_2958.TEAM_NAME_AWAY,
    join_2958.GAME_DATE_EST,
    join_2958.LIVE_PERIOD,
    join_2958.LIVE_PC_TIME,
    join_2958.GAME_STATUS_TEXT,
    stg_line_score.PTS_QTR1_HOME,
    stg_line_score.PTS_QTR2_HOME,
    stg_line_score.PTS_QTR3_HOME,
    stg_line_score.PTS_QTR4_HOME,
    stg_line_score.PTS_OT1_HOME,
    stg_line_score.PTS_OT2_HOME,
    stg_line_score.PTS_OT3_HOME,
    stg_line_score.PTS_OT4_HOME,
    stg_line_score.PTS_OT5_HOME,
    stg_line_score.PTS_OT6_HOME,
    stg_line_score.PTS_OT7_HOME,
    stg_line_score.PTS_OT8_HOME,
    stg_line_score.PTS_OT9_HOME,
    stg_line_score.PTS_OT10_HOME,
    stg_line_score.PTS_HOME,
    stg_line_score.PTS_QTR1_AWAY,
    stg_line_score.PTS_QTR2_AWAY,
    stg_line_score.PTS_QTR3_AWAY,
    stg_line_score.PTS_QTR4_AWAY,
    stg_line_score.PTS_OT1_AWAY,
    stg_line_score.PTS_OT2_AWAY,
    stg_line_score.PTS_OT3_AWAY,
    stg_line_score.PTS_OT4_AWAY,
    stg_line_score.PTS_OT5_AWAY,
    stg_line_score.PTS_OT6_AWAY,
    stg_line_score.PTS_OT7_AWAY,
    stg_line_score.PTS_OT8_AWAY,
    stg_line_score.PTS_OT9_AWAY,
    stg_line_score.PTS_OT10_AWAY,
    stg_line_score.PTS_AWAY
  FROM join_2958
  JOIN stg_line_score
    ON join_2958.GAME_ID = stg_line_score.GAME_ID
), join_1c35 AS (
  SELECT
    join_197f.GAME_ID,
    join_197f.GAME_DATE,
    join_197f.TEAM_ID_HOME,
    join_197f.TEAM_NAME_HOME,
    join_197f.TEAM_ID_AWAY,
    join_197f.TEAM_NAME_AWAY,
    join_197f.GAME_DATE_EST,
    join_197f.LIVE_PERIOD,
    join_197f.LIVE_PC_TIME,
    join_197f.GAME_STATUS_TEXT,
    join_197f.PTS_QTR1_HOME,
    join_197f.PTS_QTR2_HOME,
    join_197f.PTS_QTR3_HOME,
    join_197f.PTS_QTR4_HOME,
    join_197f.PTS_OT1_HOME,
    join_197f.PTS_OT2_HOME,
    join_197f.PTS_OT3_HOME,
    join_197f.PTS_OT4_HOME,
    join_197f.PTS_OT5_HOME,
    join_197f.PTS_OT6_HOME,
    join_197f.PTS_OT7_HOME,
    join_197f.PTS_OT8_HOME,
    join_197f.PTS_OT9_HOME,
    join_197f.PTS_OT10_HOME,
    join_197f.PTS_HOME,
    join_197f.PTS_QTR1_AWAY,
    join_197f.PTS_QTR2_AWAY,
    join_197f.PTS_QTR3_AWAY,
    join_197f.PTS_QTR4_AWAY,
    join_197f.PTS_OT1_AWAY,
    join_197f.PTS_OT2_AWAY,
    join_197f.PTS_OT3_AWAY,
    join_197f.PTS_OT4_AWAY,
    join_197f.PTS_OT5_AWAY,
    join_197f.PTS_OT6_AWAY,
    join_197f.PTS_OT7_AWAY,
    join_197f.PTS_OT8_AWAY,
    join_197f.PTS_OT9_AWAY,
    join_197f.PTS_OT10_AWAY,
    join_197f.PTS_AWAY,
    stg_other_stats.LEAGUE_ID,
    stg_other_stats.PTS_PAINT_HOME,
    stg_other_stats.PTS_PAINT_AWAY,
    stg_other_stats.PTS_2ND_CHANCE_HOME,
    stg_other_stats.PTS_2ND_CHANCE_AWAY,
    stg_other_stats.PTS_FB_HOME,
    stg_other_stats.PTS_FB_AWAY,
    stg_other_stats.LARGEST_LEAD_HOME,
    stg_other_stats.LARGEST_LEAD_AWAY,
    stg_other_stats.LEAD_CHANGES,
    stg_other_stats.TIMES_TIED,
    stg_other_stats.TEAM_TURNOVERS_HOME,
    stg_other_stats.TOTAL_TURNOVERS_HOME,
    stg_other_stats.TEAM_REBOUNDS_HOME,
    stg_other_stats.PTS_OFF_TO_HOME,
    stg_other_stats.TEAM_TURNOVERS_AWAY,
    stg_other_stats.TOTAL_TURNOVERS_AWAY,
    stg_other_stats.TEAM_REBOUNDS_AWAY,
    stg_other_stats.PTS_OFF_TO_AWAY
  FROM join_197f
  LEFT JOIN stg_other_stats
    ON join_197f.GAME_ID = stg_other_stats.GAME_ID
), game_analysis_sql AS (
  SELECT
    *
  FROM join_1c35
)
SELECT
  *
FROM game_analysis_sql