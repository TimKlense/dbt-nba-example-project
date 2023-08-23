-- models/stg_player.sql

-- Define the staging model named "stg_player"

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_player') }}
),
renamed as (
    select
        id,
        full_name,
        first_name,
        last_name,
        is_active
    from source
)

select * from renamed