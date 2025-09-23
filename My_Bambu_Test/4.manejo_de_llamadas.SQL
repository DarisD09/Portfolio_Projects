WITH parsed AS (
  SELECT
    split_part(users, ';', 1) AS agente_principal,
    duration_ms,
    lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) AS estado
  FROM llamadas
),
flagged AS (
  SELECT
    agente_principal,
    duration_ms,
    CASE 
      WHEN estado NOT LIKE '%voicemail%'
       AND estado NOT LIKE '%no answer%'
       AND estado NOT LIKE '%timeout%'
       AND estado NOT LIKE '%system error%'
       AND estado NOT LIKE '%out of service%'
      THEN 1 ELSE 0 
    END AS answered_flag
  FROM parsed
)
SELECT 
    agente_principal,
    COUNT(*) FILTER (WHERE answered_flag = 1) AS answered_calls,
    ROUND(SUM(duration_ms) FILTER (WHERE answered_flag = 1) / 60000.0, 2) AS total_tiempo_min,
    ROUND(
        (SUM(duration_ms) FILTER (WHERE answered_flag = 1) / 60000.0)
        / NULLIF(COUNT(*) FILTER (WHERE answered_flag = 1), 0), 
        2
    ) AS aht_minutos
FROM flagged
GROUP BY agente_principal;

ROUND(SUM(duration_ms) FILTER (WHERE answered_flag=1)/60000.0, 2) AS total_tiempo_min,
ROUND(
  (SUM(duration_ms) FILTER (WHERE answered_flag=1)/60000.0)
  / NULLIF(COUNT(*) FILTER (WHERE answered_flag=1),0)
, 2) AS aht_minutos

SELECT 
    agente_principal,
    COUNT(*) FILTER (WHERE answered_flag = 1) AS answered_calls,
    ROUND(SUM(duration_ms) FILTER (WHERE answered_flag = 1) / 60000.0, 2) AS total_tiempo_min,
    ROUND(
        (SUM(duration_ms) FILTER (WHERE answered_flag = 1) / 60000.0)
        / NULLIF(COUNT(*) FILTER (WHERE answered_flag = 1), 0), 
        2
    ) AS aht_minutos
FROM calls
GROUP BY agente_principal;

WITH parsed AS (
  SELECT
    split_part(users, ';', 1) AS agente_principal,
    duration_ms,
    lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) AS estado
  FROM llamadas
),
flagged AS (
  SELECT
    agente_principal,
    duration_ms,
    CASE 
      WHEN estado NOT LIKE '%voicemail%'
       AND estado NOT LIKE '%no answer%'
       AND estado NOT LIKE '%timeout%'
       AND estado NOT LIKE '%system error%'
       AND estado NOT LIKE '%out of service%'
      THEN 1 ELSE 0 
    END AS answered_flag
  FROM parsed
)
SELECT 
    agente_principal,
    COUNT(*) FILTER (WHERE answered_flag = 1) AS answered_calls,
    ROUND(SUM(duration_ms) FILTER (WHERE answered_flag = 1) / 60.0, 2) AS total_tiempo_min, -- divide by 60, not 60000
    ROUND(
        (SUM(duration_ms) FILTER (WHERE answered_flag = 1) / 60.0)
        / NULLIF(COUNT(*) FILTER (WHERE answered_flag = 1), 0), 
        2
    ) AS aht_minutos
FROM flagged
GROUP BY agente_principal


y
