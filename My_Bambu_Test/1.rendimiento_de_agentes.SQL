-- Los 10 agentes con el rendimiento mas alto en terminos de conversion
SELECT 
    nombre_agente,
    SUM(conversiones_exitosas) AS conversiones_exitosas,
    SUM(clientes_unicos) AS clientes_unicos,
    ROUND(SUM(conversiones_exitosas)::numeric / NULLIF(SUM(clientes_unicos), 0), 4) AS tasa_conversion
FROM conversiones
GROUP BY nombre_agente
HAVING SUM(clientes_unicos) >= 50
ORDER BY tasa_conversion DESC, conversiones_exitosas DESC
LIMIT 10;


-- Los 10 agentes con el rendimiento mas bajo en terminos de conversion
SELECT 
    nombre_agente,
    SUM(conversiones_exitosas) AS conversiones_exitosas,
    SUM(clientes_unicos) AS clientes_unicos,
    ROUND(SUM(conversiones_exitosas)::numeric / NULLIF(SUM(clientes_unicos), 0), 4) AS tasa_conversion
FROM conversiones
GROUP BY nombre_agente
HAVING SUM(clientes_unicos) >= 50
ORDER BY tasa_conversion ASC, conversiones_exitosas ASC
LIMIT 10;