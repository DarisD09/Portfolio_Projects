-- Contactabilidad por estado (Categorizado)
WITH llamadas_normalizadas AS (
    SELECT 
        CASE
            WHEN lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) IN 
                 ('customer contacted','resolved','answered','transfer') 
                THEN 'Contactados'
            WHEN lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) IN 
                 ('no answer','voicemail','busy','out of service') 
                THEN 'No Contactados'
            WHEN lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE 'system error%' 
              OR lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE '%skipped%' 
              OR lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) LIKE '%throttled%' 
              OR lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) = 'fax' 
                THEN 'Errores Técnicos'
            ELSE 'Otros'
        END AS categoria_estado
    FROM llamadas
)
SELECT 
    categoria_estado,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM llamadas_normalizadas
GROUP BY categoria_estado
ORDER BY total DESC;

-- Contactabilidad por estado (Detallado)
SELECT 
    lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) AS estado,
    COUNT(*) AS total
FROM llamadas
GROUP BY 1
ORDER BY total DESC;