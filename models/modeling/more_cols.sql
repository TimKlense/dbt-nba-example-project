{% set chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" %}
{% for j in range(200) %}
  select
  {% for i in range(210) %}
    '{{ chars[((i + j) % 52):((i + j) % 52) + 5 + ((i + j) % 28)] }}' as col_{{ i + (j*2) }}
    {%- if not loop.last %}, {% endif -%}
  {% endfor %}
  {%- if not loop.last %} UNION ALL {% endif %}
{% endfor %}
LIMIT 1000