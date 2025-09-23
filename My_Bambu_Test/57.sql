WITH base AS (
  SELECT
    split_part(users, ';', 1) AS agente,
    lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) AS estado
  FROM llamadas
)
SELECT
  agente,
  COUNT(*) AS total_llamadas,
  COUNT(*) FILTER (
    WHERE estado LIKE '%customer contacted%'
       OR estado LIKE '%resolved%'
       OR estado LIKE '%transfer%'
       OR estado LIKE '%answered%'
  ) AS llamadas_contactadas,
  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE estado LIKE '%customer contacted%'
         OR estado LIKE '%resolved%'
         OR estado LIKE '%transfer%'
         OR estado LIKE '%answered%'
    ) / NULLIF(COUNT(*),0), 2
  ) AS tasa_contacto
FROM base
GROUP BY agente
HAVING COUNT(*) >= 100
ORDER BY tasa_contacto DESC;


SELECT
  nombre_agente,
  SUM(conversiones_exitosas) AS conversiones,
  SUM(clientes_unicos) AS clientes_unicos,
  ROUND(
    100.0 * SUM(conversiones_exitosas)::numeric / NULLIF(SUM(clientes_unicos),0), 2
  ) AS tasa_conversion
FROM conversiones
GROUP BY nombre_agente
HAVING SUM(clientes_unicos) >= 50
ORDER BY tasa_conversion DESC;

