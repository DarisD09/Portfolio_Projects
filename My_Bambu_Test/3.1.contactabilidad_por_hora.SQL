SELECT 
    EXTRACT(hour FROM date_ts) AS hora,
    COUNT(*) AS total_llamadas,
    SUM(CASE WHEN lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) NOT LIKE '%voicemail%'
          AND lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) NOT LIKE '%no answer%'
          AND lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) NOT LIKE '%timeout%'
          AND lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) NOT LIKE '%system error%'
          THEN 1 ELSE 0 END) AS llamadas_respondidas,
    SUM(CASE WHEN lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE '%customer contacted%'
          OR lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE '%resolved%'
          OR lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE '%transfer%'
          OR lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE '%answered%'
          THEN 1 ELSE 0 END) AS llamadas_contactadas
FROM llamadas
GROUP BY hora
ORDER BY hora;

SELECT 
    EXTRACT(hour FROM date_ts) AS hora,
    COUNT(*) AS total_llamadas,
    SUM(CASE WHEN estado IN ('answered','transfer','customer contacted','resolved') THEN 1 ELSE 0 END) AS llamadas_contactadas,
    ROUND(100.0 * SUM(CASE WHEN estado IN ('answered','transfer','customer contacted','resolved') THEN 1 ELSE 0 END) / COUNT(*), 2) AS tasa_contacto
FROM llamadas
GROUP BY hora
ORDER BY hora;

-- 3.1 Contactabilidad por hora (con tasas)
WITH base AS (
  SELECT
    EXTRACT(hour FROM date_ts) AS hora,
    lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) AS estado
  FROM llamadas
),
agregado AS (
  SELECT
    hora,
    COUNT(*) AS total_llamadas,
    SUM(
      CASE
        WHEN estado NOT LIKE '%voicemail%'
         AND estado NOT LIKE '%no answer%'
         AND estado NOT LIKE '%timeout%'
         AND estado NOT LIKE '%system error%'
        THEN 1 ELSE 0
      END
    ) AS llamadas_respondidas,
    SUM(
      CASE
        WHEN estado IN ('customer contacted','resolved','answered','transfer')
        THEN 1 ELSE 0
      END
    ) AS llamadas_contactadas
  FROM base
  GROUP BY hora
)
SELECT
  hora,
  total_llamadas,
  llamadas_respondidas,
  llamadas_contactadas
FROM agregado
ORDER BY hora;

