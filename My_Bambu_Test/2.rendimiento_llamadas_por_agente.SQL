WITH llamadas_por_agente AS (
  SELECT
    split_part(users, ';', 1) AS agente_principal,
    COALESCE(NULLIF(last_wrap_up, ''), wrap_up) AS estado,
    duration_ms,
    date_ts
  FROM llamadas
)
SELECT
  agente_principal,
  COUNT(*) AS total_llamadas,
  SUM(duration_ms)/60000.0 AS minutos_hablados,
  ROUND(AVG(CASE WHEN lower(estado) NOT LIKE '%voicemail%' 
                     AND lower(estado) NOT LIKE '%no answer%'
                     AND lower(estado) NOT LIKE '%timeout%'
                     AND lower(estado) NOT LIKE '%system error%'
                 THEN 1 ELSE 0 END)::numeric, 3) AS tasa_respuesta,
  ROUND(AVG(CASE WHEN lower(estado) LIKE '%customer contacted%'
                     OR lower(estado) LIKE '%resolved%'
                     OR lower(estado) LIKE '%transfer%'
                     OR lower(estado) LIKE '%answered%'
                 THEN 1 ELSE 0 END)::numeric, 3) AS tasa_contacto
FROM llamadas_por_agente
GROUP BY agente_principal
HAVING COUNT(*) >= 30
ORDER BY tasa_contacto DESC, total_llamadas DESC
LIMIT 20;
