{% set chars = "abcdefghijklmnopqrstuv" %}
{% for j in range(80) %}
  select
  {% for i in range(180) %}
    '{{ chars[((i + j) % 22):((i + j) % 22) + 5 + ((i + j) % 21)] }}' as column_name_is_really_long_bcuz_some_people_have_long_col_names_so_we_might_want_to_test_that_too_{{ i + (j*2) }}
    {%- if not loop.last %}, {% endif -%}
  {% endfor %}
  {%- if not loop.last %} UNION ALL {% endif %}
{% endfor %}
LIMIT 1000