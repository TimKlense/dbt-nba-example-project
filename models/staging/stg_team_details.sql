-- models/stg_team_details.sql

-- Define the staging model named "stg_team_details"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_team_details') }}
),
renamed as (
    select
        team_id,
        abbreviation,
        nickname,
        yearfounded,
        city,
        arena,
        arenacapacity,
        owner,
        generalmanager,
        headcoach,
        dleagueaffiliation,
        facebook,
        instagram,
        twitter
    from source
)

select * from renamed
