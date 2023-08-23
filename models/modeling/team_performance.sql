-- models/team_performance.sql

-- Referring to the stage models
WITH
  team AS (
    SELECT
      id,
      full_name
    FROM {{ ref('stg_team') }}
  ),
  team_history AS (
    SELECT
      team_id,
      city,
      nickname,
      year_founded,
      year_active_till
    FROM {{ ref('stg_team_history') }}
  ),
  team_details AS (
    SELECT
      team_id,
      city,
      yearfounded
    FROM {{ ref('stg_team_details') }}
  )

-- Joining the data
SELECT
  t.id,
  t.full_name,
  th.city,
  th.nickname,
  th.year_founded,
  th.year_active_till
FROM team t
LEFT JOIN team_history th ON t.id = th.team_id
LEFT JOIN team_details td ON t.id = td.team_id
