-- models/stg_draft_history.sql

-- Define the staging model named "stg_draft_history"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_draft_history') }}
),
renamed as (
    select
        person_id,
        player_name,
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
        organization_type,
        player_profile_flag
    from source
)

select * from renamed
