{% set chars = "abcdefghij" %}
{% for j in range(30) %}
  select
  {% for i in range(2) %}
    '{{ chars[((i + j) % 7):((i + j) % 722) + 5 + ((i + j) % 6)] }}' as column_name_long_to_show_that_it_goes_off_the_screen_for_vis_editor{{ i + (j*2) }}
    {%- if not loop.last %}, {% endif -%}
  {% endfor %}
  {%- if not loop.last %} UNION ALL {% endif %}
{% endfor %}
LIMIT 1000