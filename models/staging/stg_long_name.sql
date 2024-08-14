-- models/stg_game_info.sql

-- Define the staging model named "stg_game_info"
-- COLUMN_NAME_LONG_TO_SHOW_THAT_IT_GOES_OFF_THE_SCREEN_FOR_VIS_EDITOR0
-- COLUMN_NAME_LONG_TO_SHOW_THAT_IT_GOES_OFF_THE_SCREEN_FOR_VIS_EDITOR1

with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('raw_long_name') }}
),
renamed as (
    select
        test1,
        test2
    from source
)

select * from renamed