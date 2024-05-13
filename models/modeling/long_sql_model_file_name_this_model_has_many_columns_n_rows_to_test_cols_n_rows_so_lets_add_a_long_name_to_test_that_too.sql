{% set chars = "abcdefghij" %}
{% for j in range(30) %}
  select
  {% for i in range(165) %}
    '{{ chars[((i + j) % 7):((i + j) % 722) + 5 + ((i + j) % 6)] }}' as column_name_is_really_long_bcuz_some_people_have_long_col_names_so_we_might_want_to_test_that_too_{{ i + (j*2) }}
    {%- if not loop.last %}, {% endif -%}
  {% endfor %}
  {%- if not loop.last %} UNION ALL {% endif %}
{% endfor %}
LIMIT 1000