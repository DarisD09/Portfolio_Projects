WITH base AS (
  SELECT
    split_part(users, ' ', 1) AS equipo,
    COALESCE(NULLIF(last_wrap_up,''), wrap_up) AS estado
  FROM llamadas
)
SELECT
  equipo,
  COUNT(*) AS total_llamadas,
  ROUND(100.0 * AVG(
      CASE 
        WHEN lower(estado) NOT LIKE '%voicemail%' 
             AND lower(estado) NOT LIKE '%no answer%'
             AND lower(estado) NOT LIKE '%timeout%'
             AND lower(estado) NOT LIKE '%system error%'
        THEN 1 ELSE 0 END
    )::numeric, 1
  ) AS tasa_respuesta,
  ROUND(
    100.0 * AVG(
      CASE 
        WHEN lower(estado) LIKE '%customer contacted%'
             OR lower(estado) LIKE '%resolved%'
             OR lower(estado) LIKE '%transfer%'
             OR lower(estado) LIKE '%answered%'
        THEN 1 ELSE 0 END
    )::numeric, 1
  ) AS tasa_contacto,
  ROUND(
    COUNT(*) * AVG(
      CASE 
        WHEN lower(estado) LIKE '%customer contacted%'
             OR lower(estado) LIKE '%resolved%'
             OR lower(estado) LIKE '%transfer%'
             OR lower(estado) LIKE '%answered%'
        THEN 1 ELSE 0 END
    )::numeric
  ) AS contactos_efectivos
FROM base
WHERE equipo IN ('AS','LT')
GROUP BY equipo;

