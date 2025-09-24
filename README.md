# 📊 Análisis de Rendimiento de Agentes – MyBambu

## Introducción
Este proyecto explora el desempeño de agentes de servicio al cliente de **MyBambu**, enfocándose en métricas de **conversión**, **contactabilidad** y **eficiencia operativa**.  

La meta es identificar agentes con alto y bajo rendimiento, entender los factores que influyen en las conversiones y generar recomendaciones estratégicas para mejorar procesos y resultados.

## Las preguntas que quería responder a través de este análisis fueron: 

1. Analisis del rendimiento en los agentes por eficiencia en conversiones
2. Analisis de rendimiento de los agentes en las llamadas
3. Analisis de contactabilidad por estado, horas y equipos de trabajo. (AS y LT)
4. Recomendaciones para optimizar el proceso y decisión sobre los agentes segun su rendimiento.
5. Qué otras métricas sugeriria, adoptar y por qué.


Los datos provienen de registros de **Conversiones** y **Llamadas**.

## Herramientas Utilizadas
- **SQL (PostgreSQL):** creación de tablas, carga de datos y consultas de análisis.  
- **Power BI:** construcción de dashboards interactivos.  
- **Git & GitHub:** control de versiones y documentación.  

## Dashboard Interactivo  
Para explorar más a fondo los datos y métricas en tiempo real, puede acceder al dashboard de Power BI en el siguiente enlace: [Ver Dashboard](https://app.powerbi.com/view?r=eyJrIjoiZDNmMWZiZmMtMDI2NC00YWZhLTgzMTQtMTYyM2YwOGI2OTBjIiwidCI6IjJjZmNkYzkzLTRmM2MtNDExOS05NDAyLWMwOTdlYTA2MmU2YyJ9)  


## El Análisis
Cada **SQL Query** de este proyecto está diseñada para responder a un aspecto clave del negocio en el área de **atención al cliente y ventas** de MyBambu. 

A continuación se detalla cómo cada una aporta al entendimiento del desempeño de los agentes y la operación:

## 1. Rendimiento de agentes por eficiencia en conversiones

###  Top 10 y Bottom 10 agentes en términos de conversión
Con los siguientes queries podremos identificar a los 10 agentes con mejor y peor desempeño en términos de tasa de conversión, con el fin de comparar resultados, detectar brechas de rendimiento y definir acciones de mejora.
```SQL
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
```

### Top 10 Agentes por Tasa de Conversión
| Nombre Agente       | Conversiones Exitosas | Clientes Únicos | Tasa de Conversión |
|----------------------|-----------------------|-----------------|---------------------|
| <span style="color:limegreen">CARLOS V. CARO</span> | <span style="color:limegreen">19</span>  | <span style="color:limegreen">78</span>   | <span style="color:limegreen">0.2436</span> |
| <span style="color:limegreen">CARLOS ESCOBOZA</span> | <span style="color:limegreen">75</span>  | <span style="color:limegreen">393</span>  | <span style="color:limegreen">0.1908</span> |
| <span style="color:limegreen">MARIA HERNANDEZ</span> | <span style="color:limegreen">21</span>  | <span style="color:limegreen">112</span>  | <span style="color:limegreen">0.1875</span> |
| CARLOS CARVAJAL     | 541                   | 3056            | 0.1770              |
| KENIA COTA          | 681                   | 3901            | 0.1746              |
| AARON CRUZ          | 30                    | 189             | 0.1587              |
| ALEX PEREA          | 731                   | 4827            | 0.1514              |
| MARIA LOZADA        | 12                    | 83              | 0.1446              |
| VALERIA DUARTE      | 19                    | 132             | 0.1439              |
| MIGUEL LOPEZ MELICOFF | 73                  | 510             | 0.1431              |


---

### Bottom 10 Agentes por Tasa de Conversión (Orden Descendente)
| Nombre Agente       | Conversiones Exitosas | Clientes Únicos | Tasa de Conversión |
|----------------------|-----------------------|-----------------|---------------------|
| <span style="color:red">PERLA GARCIA</span> | <span style="color:red">0</span>   | <span style="color:red">71</span>   | <span style="color:red">0.0000</span> |
| <span style="color:red">JUAN PINEDA</span>  | <span style="color:red">1</span>   | <span style="color:red">54</span>   | <span style="color:red">0.0185</span> |
| <span style="color:red">RODOLFO CALERI RUIBAL</span> | <span style="color:red">120</span> | <span style="color:red">4681</span> | <span style="color:red">0.0256</span> |
| GINA BERRUETA       | 215                   | 7664            | 0.0281              |
| FABIAN LOPEZ        | 129                   | 4348            | 0.0297              |
| JAMES GARCIA        | 91                    | 2980            | 0.0305              |
| EDWIN MONSALVE      | 53                    | 1669            | 0.0318              |
| MARIA ZEA           | 35                    | 1077            | 0.0325              |
| PAULINA HARO        | 270                   | 8286            | 0.0326              |
| ANGELICA FORERO FORERO | 465                 | 13960           | 0.0333              |

---
*Los agentes con bajo desempeño (ej. Rodolfo Caleri, Gina Berrueta) manejan carteras muy grandes pero convierten poco. Esto puede deberse a **listas de baja calidad, horarios menos efectivos o falta de capacitación en técnicas de cierre.** En contraste, los top performers muestran que, con buena preparación y foco, incluso volúmenes altos pueden sostener una conversión estable.*  

### Insight del análisis
- **Top performers efectivos:** Agentes como Carlos V. Caro (24%), Carlos Escoboza (19%) y María Hernández (18%) convierten entre 18 y 24 clientes por cada 100 atendidos, muy por encima del promedio. Esto refleja un dominio sólido en la gestión de oportunidades y técnicas de cierre.

- **Escala con calidad:** Carlos Carvajal (17.7%),  Kenia Cota (17.5%) y Alex Perea (15.1%) destacan porque, aun manejando altos volúmenes de 3,000–4,800 clientes únicos, mantienen tasas de conversión estables, logrando 17–18 conversiones por cada 100 clientes. Este balance entre cantidad y calidad debe servir como modelo para otros agentes.

- **Riesgo de fuga de valor:** En contraste, agentes como Rodolfo Caleri (2.5%), Gina Berrueta (2.8%) y Angélica Forero (3.3%) atienden grandes carteras (4,600–13,900 clientes) pero apenas convierten entre 2 y 3 clientes por cada 100 atendidos. Esto implica que la mayoría de las oportunidades no generan retorno.

- Esta brecha evidencia la necesidad de **replicar las buenas prácticas de los top performers**, fortalecer la capacitación en los agentes con bajo desempeño y evaluar la calidad de las listas de clientes asignadas para asegurar condiciones más equitativas.  

## 2. Rendimiento de los agentes en las llamadas
El siguiente query mide el desempeño de las llamadas por agente, calculando total de llamadas, minutos hablados, tasa de respuesta y tasa de contacto. Su fin es mostrar a los 20 agentes con más de 30 llamadas, priorizando la mayor tasa de contacto y luego el volumen de llamadas.

```SQL
WITH parsed AS (
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
FROM parsed
GROUP BY agente_principal
HAVING COUNT(*) >= 30
ORDER BY tasa_contacto DESC, total_llamadas DESC
LIMIT 20;
```
### Rendimiento de los Agentes por Llamada (Top 20)

<div style="max-height:300px; overflow-y:auto;">

| Agente Principal                                | Total Llamadas | Minutos Hablados | Tasa Respuesta | Tasa Contacto |
|-------------------------------------------------|----------------|------------------|----------------|---------------|
| LT CM Alexia Vergara Ruiz                       | 189            | 2.83             | 0.947          | 0.873         |
| AS IN Giovan Adolfo Torres Cardenas             | 665            | 13.93            | 0.920          | 0.845         |
| AS IN Carlos Ascanio Dias                       | 568            | 10.54            | 0.942          | 0.843         |
| AS IN Martha Estella Bautista Castillo          | 567            | 9.16             | 0.884          | 0.824         |
| AS IN Yiset Valentina Uribe Ahumada             | 767            | 10.89            | 0.909          | 0.823         |
| AS IN Adrian Camilo Pineda Barrera              | 452            | 9.22             | 0.907          | 0.823         |
| AS IN Laura Hernandez                           | 597            | 9.55             | 0.920          | 0.809         |
| AS IN Diana Narvaez Galan                       | 531            | 9.64             | 0.895          | 0.804         |
| AS IN Lucila Cardenas                           | 673            | 10.84            | 0.915          | 0.801         |
| LT IN Isaac Manning Gracia                      | 614            | 9.34             | 0.914          | 0.796         |
| AS IN Darwuin David Hernandez Sotillo           | 791            | 9.10             | 0.934          | 0.791         |
| AS IN Cristian David Mayorga Mongui             | 576            | 8.37             | 0.918          | 0.788         |
| AS IN Ayelin Vanesa Mercado Fontalvo            | 556            | 8.47             | 0.923          | 0.788         |
| AS IN Johan Pardo Ballen                        | 560            | 7.38             | 0.938          | 0.786         |
| AS IN Jose Manuel Morales Camargo               | 476            | 12.81            | 0.847          | 0.786         |
| LT CM Jafet Ceballos Palomino                   | 278            | 6.42             | 0.906          | 0.781         |
| LT CM Elmer Cordova Escarcega                   | 193            | 3.35             | 0.886          | 0.777         |
| AS IN Ander Joel Cortes Vivas                   | 919            | 14.66            | 0.976          | 0.762         |
| LT IN Pedro Penichet Solorio                    | 653            | 14.36            | 0.865          | 0.757         |
| AS Kelly Johanna Torres                         | 40             | 2.08             | 0.800          | 0.750         |

</div>

---

*Las diferencias en tasa de contacto pueden deberse a **variaciones en la calidad de las listas asignadas, al nivel de experiencia del agente o incluso a diferencias en campañas.** Validar estas hipótesis ayudaría a definir si el bajo desempeño es atribuible al agente o a factores externos.*

### Observación importante

**Se detecta una inconsistencia en la métrica de minutos hablados:** por ejemplo, LT CM Alexia Vergara Ruiz aparece con 189 llamadas y solo 2.83 minutos en total, lo que equivale a menos de 1 segundo por llamada. Esto sugiere que el campo **duration_ms** podría no estar reflejando el tiempo real de conversación, sino quizás un valor truncado o mal mapeado en la base de datos. Esta limitación debe considerarse antes de tomar decisiones basadas en esta métrica.

---
### Insight del análisis

**Altas tasas de respuesta y contacto**
- La mayoría de los agentes mantienen tasas de respuesta superiores al 90% y de contacto entre 80% y 87%, lo que refleja buena eficiencia operativa.
- Destacan LT CM Alexia Vergara Ruiz (94.7% respuesta / 87.3% contacto) y AS IN Carlos Ascanio Dias (94.2% / 84.3%), como ejemplos de balance entre volumen y efectividad.

**Volumen de llamadas vs. minutos hablados**

- Agentes como AS IN Ander Joel Cortes Vivas (919 llamadas, 14,663 min registrados) y AS IN Giovan Adolfo Torres Cardenas (665 llamadas, 13,928 min) muestran altos volúmenes y tiempo en llamadas, aunque con tasas de contacto algo más bajas (76–84%).
- En contraste, agentes con menos llamadas como LT CM Alexia Vergara Ruiz (189 llamadas, 2.83 min según registro) mantienen tasas de contacto sólidas (87.3%), aunque la métrica de minutos hablados parece inconsistente y debe validarse.

**Oportunidades de mejora**

- Algunos agentes presentan tasas de contacto por debajo del 78%, como Pedro Penichet Solorio (75.7%) y Kelly Johanna Torres (75%). Esto sugiere revisar la calidad de las listas o reforzar capacitación en técnicas de conexión.

**Acciones sugeridas**

- Validar la métrica de duración antes de usarla en reportes, asegurando que refleje el tiempo real hablado.
- Replicar prácticas de los agentes con >80% tasa de contacto y alto volumen.
- Analizar a los agentes con alto volumen pero baja tasa de contacto, para identificar si el problema está en la gestión del tiempo, calidad de leads o técnicas de conexión.

En general, los datos reflejan un equipo con **buen desempeño promedio**, aunque existe una **brecha clara entre agentes con más volumen pero menor contacto** y aquellos con menos llamadas pero más efectivos en la conexión.


## 3.0. Contactabilidad por estado

Este query busca analizar la distribución de llamadas según su estado final (ej. message played, no answer, voicemail, customer contacted), con el fin de identificar en qué categorías se concentran más intentos y así medir la efectividad real del contacto.

```SQL
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
```
---

*El análisis revela que casi el 92% de las llamadas no logran contacto directo con clientes, mientras que solo un 6% corresponde a interacciones efectivas. Esto refleja una gran brecha entre intentos y resultados reales.*

### Contactabilidad por Estado (Categorizado)

| Categoría        | Total   | Porcentaje |
|------------------|---------|------------|
| Otros            | 408,573 | 65.31%     |
| No Contactados   | 169,638 | 27.11%     |
| Contactados      | 37,704  | 6.03%      |
| Errores Técnicos | 9,720   | 1.55%      |

---

### Ejemplos de categorización:

- **Contactados:** customer contacted, resolved
- **No Contactados:** voicemail, no answer, busy
- **Errores Técnicos:** system error, skipped, throttled
- **Otros:** Estados no estandarizados o ambiguos

---

```SQL
-- Contactabilidad por estado (Detallado)
SELECT 
    lower(COALESCE(NULLIF(last_wrap_up,''), wrap_up)) AS estado,
    COUNT(*) AS total
FROM llamadas
GROUP BY 1
ORDER BY total DESC;
```

### Contactabilidad por Estado (Detallado)

<div style="max-height:300px; overflow-y:auto;">

| Estado                                           | Total   |
|--------------------------------------------------|---------|
| message played                                   | 165,740 |
| inin-outbound-no-answer                          | 99,919  |
| no answer                                        | 86,573  |
| voicemail                                        | 76,490  |
| inin-outbound-disconnect                         | 50,774  |
| customer contacted                               | 22,441  |
| inin-outbound-sit-callable                       | 20,586  |
| inin-outbound-number_could_not_be_dialed         | 15,699  |
| resolved                                         | 15,263  |
| call interruption                                | 14,243  |
| inin-outbound-sit-uncallable                     | 13,563  |
| inin-outbound-busy                               | 8,244   |
| system error                                     | 7,975   |
| not resolved - escalated                         | 6,842   |
| out of service                                   | 6,344   |
| inin-wrap-up-timeout                             | 3,237   |
| hung- up                                         | 2,963   |
| updates provided                                 | 1,528   |
| inin-outbound-failed-to-reach-agent              | 1,178   |
| wrong number                                     | 936     |
| inin-outbound-externally-throttled               | 766     |
| reschedule – any agent                           | 750     |
| answered by a family member                      | 698     |
| do not call – account approved                   | 611     |
| do not call – risk close                         | 236     |
| busy                                             | 231     |
| inin-outbound-zone-blocked-skipped               | 225     |
| information provided                             | 218     |
| inin-outbound-preview-skipped                    | 217     |
| inin-outbound-no-callable-numbers-skipped        | 177     |
| test call                                        | 164     |
| inin-outbound-number-uncallable-skipped          | 145     |
| inin-outbound-contact-attempt-limit-skipped      | 138     |
| do not call                                      | 131     |
| issue identified                                 | 66      |
| inin-outbound-number-attempt-limit-skipped       | 62      |
| inin-outbound-failed-to-reach-flow               | 56      |
| inin-outbound-fax                                | 54      |
| inin-wrap-up-deleted                             | 43      |
| english speaker                                  | 35      |
| inin-outbound-transferred-to-flow                | 21      |
| call dropped / disconnected                      | 18      |
| inin-outbound-contact-uncallable-skipped         | 15      |
| inin-outbound-machine                            | 14      |
| inin-outbound-campaign-recycle-cancelled-recall  | 5       |
| inin-outbound-live-voice                         | 1       |

</div>

---

### Insight del análisis

1. **Altos volúmenes en intentos sin contacto**  
   - Los estados más frecuentes son **“message played” (165,740)**, **“no answer” (86,573)** y **“voicemail” (76,490)**. Esto indica que una gran parte de los intentos de contacto **no culminan en interacción directa con el cliente**, lo cual limita la efectividad global de la campaña.  

2. **Contactos efectivos bajos en comparación**  
   - Solo **22,441 casos como “customer contacted”** y **15,263 como “resolved”** se registran como interacciones exitosas. Esto representa menos del **15% del total** frente a estados fallidos o intermedios, lo que muestra una **brecha significativa entre intentos y conversiones reales**.  

3. **Problemas técnicos y operativos**  
   - Estados como **“system error” (7,975)**, **“call interruption” (14,243)** y **“inin-outbound-failed-to-reach-agent” (1,178)** reflejan incidencias técnicas que afectan la eficiencia. Reducir estos fallos podría incrementar la contactabilidad sin necesidad de aumentar el volumen de llamadas.  

**Conclusión:** La mayor parte de los intentos no logran contacto directo con clientes. Se recomienda **optimizar las bases de datos**, mejorar los **horarios de marcación**, y **reforzar la infraestructura técnica** para disminuir errores y elevar la tasa de contactos efectivos.  


## 3.1. Contactabilidad por Hora
Este query busca analizar la efectividad de las llamadas según la hora del día, identificando en qué franjas horarias se concentran más intentos, respuestas y contactos efectivos para optimizar la estrategia de marcación.

```SQL
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
```
---

### Distribución de Llamadas por Hora

<div style="max-height:300px; overflow-y:auto;">

## 3.1. Contactabilidad por Hora

| Hora | Total Llamadas | Llamadas Respondidas | Llamadas Contactadas |
|------|----------------|-----------------------|-----------------------|
| 0    | 193            | 192                   | 0                     |
| 7    | 7              | 7                     | 4                     |
| 8    | 18,587         | 13,044                | 1,101                 |
| 9    | 32,499         | 25,564                | 1,712                 |
| 10   | 42,583         | 30,343                | 2,668                 |
| 11   | 57,326         | 36,048                | 3,891                 |
| 12   | 59,579         | 37,812                | 4,363                 |
| 13   | 55,436         | 37,463                | 3,752                 |
| 14   | 66,950         | 46,667                | 4,315                 |
| 15   | 51,731         | 34,636                | 4,077                 |
| 16   | 48,344         | 33,167                | 3,441                 |
| 17   | 43,648         | 31,023                | 2,927                 |
| 18   | 42,672         | 30,720                | 2,603                 |
| 19   | 35,910         | 28,318                | 1,869                 |
| 20   | 26,511         | 24,161                | 733                   |
| 21   | 21,423         | 20,853                | 106                   |
| 22   | 13,290         | 12,778                | 84                    |
| 23   | 8,946          | 8,564                 | 58                    |


</div>

---
*Nota:* **“Llamadas respondidas”** incluye interacciones que no siempre culminaron en un contacto válido (ej. contestaciones sin conversación útil). Por eso, la métrica clave para evaluar efectividad real es **“Llamadas contactadas”**.

---

### Insights del Análisis

El análisis muestra la distribución de llamadas por hora, diferenciando entre intentos totales, llamadas respondidas y contactos efectivos.  
La mayor productividad ocurre entre **10:00 y 15:00 horas**, mientras que en la noche (20:00–23:00) se observa un uso ineficiente de recursos.

- **Horas pico (10:00–15:00):** mayores volúmenes e interacciones efectivas, con más de **4,000 contactos por hora** en promedio.  
- **Descenso tarde-noche:** a partir de las **17:00 h**, las llamadas se mantienen altas pero los contactos efectivos caen progresivamente.  
- **Horas nocturnas (20:00–23:00):** se realizaron más de **21,000 intentos** con apenas **250 contactos efectivos**, mostrando baja rentabilidad operativa.  

**Conclusión:** Los esfuerzos deberían concentrarse en **horas laborales centrales (10:00–15:00)**, reduciendo llamadas en la noche para mejorar la eficiencia global.


### 3.2. Contactabilidad por Equipo
---
Este query busca comparar el desempeño entre los equipos AS y LT, midiendo el total de llamadas, la tasa de respuesta y la tasa de contacto, para identificar cuál equipo logra mayor efectividad en la gestión de llamadas.

```SQL
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
```
---

### Resultados Comparativos por Equipo

| Equipo | Total Llamadas | Tasa de Respuesta | Tasa de Contacto | Contactos Efectivos |
|--------|----------------|-------------------|------------------|----------------------|
| AS     | 162,448        | 23.4%             | 14.1%            | 22,900               |
| LT     | 76,290         | 44.1%             | 26.7%            | 20,300               |

---
*El análisis muestra que, aunque el equipo AS realizó más llamadas (162,448), el equipo LT obtuvo una tasa de respuesta (44.1%) y contacto (26.7%) mucho más alta que la del equipo AS (23.4% y 14.1% respectivamente).*

- **Volumen de llamadas:**

  - El equipo AS maneja un volumen mucho mayor de llamadas (162,448) en comparación con LT (76,290).
  - Esto refleja que AS asume más carga operativa y mayor esfuerzo de ejecución.

- **Tasa de respuesta:**

  - El equipo LT destaca con una tasa de respuesta del 44.1%, frente al 23.4% de AS.
  - En términos prácticos, LT logra que casi la mitad de sus intentos sean atendidos, mientras que AS no alcanza ni una cuarta parte.

- **Tasa de contacto:**

  - LT nuevamente supera con un 26.7% de efectividad frente al 14.1% de AS.
  - Es decir, cada llamada de LT tiene casi el doble de probabilidad de convertirse en un contacto real con el cliente.

- **Contactos efectivos:**
  - El equipo AS genera más contactos efectivos en números absolutos (22,900) por su alto volumen de llamadas.
  - Sin embargo, el equipo LT, con apenas la mitad de llamadas, logra casi el mismo número (20,300), demostrando una productividad relativa mucho mayor.

---

### Explicación de las diferencias observadas
Una posible explicación es que **LT reciba bases de datos más depuradas o llamadas en horarios más efectivos**, mientras que AS asume más volumen en horarios con menor respuesta.  
Otro caso puede ser que AS no esté aplicando las mismas prácticas de conexión o guiones de cierre que LT.

---

### Impacto Potencial
Si el equipo **AS alcanzara las tasas de eficiencia del equipo LT**, manteniendo su volumen actual de llamadas:
- Podría **superar los 43,000 contactos efectivos** (casi el **doble** de lo que logra hoy).
- Esto **no requeriría aumentar costos ni volumen**, únicamente **replicar las prácticas y estrategias de LT** (horarios, calidad de bases, técnicas de marcación).


 
## 4. Recomendaciones Estratégicas Basadas en el Análisis de Agentes

### 1. Optimización del proceso

**Mejorar la eficiencia operativa**

- Monitorear a los agentes con baja tasa de contacto para identificar si el problema está en técnicas, horarios o calidad de listas.
- Replicar las prácticas de los agentes con mayor tasa de contacto y conversión como modelo para los demás.
- Diseñar un playbook estandarizado con guiones, manejo de objeciones y técnicas de cierre.
- Implementar role plays y entrenamientos cruzados liderados por top performers.

**Optimizar la carga de trabajo**

- Evitar sobrecargar a agentes con alto volumen pero baja efectividad, ya que esto diluye los resultados.
- Distribuir llamadas de forma equilibrada, priorizando calidad sobre cantidad.
- Asignar casos complejos a los agentes con mayor consistencia y experiencia.

**Agilidad en la gestión**

- Revisar los flujos de llamadas para eliminar pasos redundantes o cuellos de botella.
- Implementar guías rápidas y checklists para llamadas repetitivas.
- Usar dashboards en tiempo real para que supervisores puedan intervenir proactivamente.

---

### 2. Decisiones sobre agentes según rendimiento

**Top performers (ej. Juliana Zapata, Paula Sepúlveda)**

- Reconocer públicamente su desempeño e incentivarlos con campañas de alto valor.
- Utilizarlos como mentores internos para transferir sus prácticas exitosas.

**Agentes con bajo rendimiento**

- Evaluar si el bajo desempeño proviene de capacitación, gestión del tiempo o calidad de leads.
- Brindar coaching focalizado y establecer planes de mejora con metas claras.
- Hacer seguimiento semanal para medir avances.

**Agentes con desempeño intermedio (alto volumen, efectividad moderada)**

- Revisar la calidad de listas asignadas para descartar problemas externos.
- Reforzar la capacitación en resolución en primer contacto y técnicas de conexión.
- Potenciarlos con entrenamiento cruzado, ya que representan el grupo clave para elevar el estándar general.

---

### 3. Impacto esperado
- Mejora en la satisfacción del cliente y en la tasa de conversión.
- Mayor motivación y competitividad en el equipo gracias a la retroalimentación y el reconocimiento.
- Reducción de ineficiencias operativas y mejor aprovechamiento de los recursos existentes.
- Potencial de crecimiento sin necesidad de aumentar costos operativos.

---

## Conclusión
El análisis muestra un rango amplio de desempeño entre agentes: algunos altamente efectivos y otros que requieren apoyo adicional. La clave está en estandarizar las mejores prácticas, optimizar la carga operativa y reforzar la capacitación, lo que permitirá cerrar la brecha y aumentar la consistencia de resultados sin incrementar costos.  

En general, los datos muestran patrones claros, pero también es probable que existan **factores estructurales** (bases de datos, campañas, horarios) que expliquen las brechas de desempeño. Por eso, las recomendaciones no deben enfocarse únicamente en los agentes, sino también en validar y mejorar los procesos operativos y la calidad de la información usada en las campañas.


## 5. Qué otras métricas sugeriría, adoptar y por qué

### Conversión por franja horaria
- **Qué mide:** porcentaje de llamadas que terminan en conversión según la hora del día.  
- **Por qué adoptarla:** permite identificar las horas con mayor efectividad, optimizando la asignación de recursos y enfocando a los mejores agentes en las franjas de mayor valor.  

### Resolución en el Primer Contacto (RPC)
- **Qué mide:** proporción de clientes que quedan resueltos en el primer intento, sin necesidad de llamadas adicionales.  
- **Por qué adoptarla:** refleja calidad de atención y eficiencia. Un alto RPC reduce costos, evita saturación de líneas y mejora la satisfacción del cliente.  

### Eficiencia relativa por agente (conversiones / llamadas efectivas)
- **Qué mide:** el desempeño real de cada agente ajustado al número de contactos efectivos, eliminando distorsiones por volumen.  
- **Por qué adoptarla:** ayuda a diferenciar entre agentes con alto volumen pero baja efectividad y aquellos que, aunque manejen menos contactos, logran más cierres.  

---

### Sugerencia adicional
Recomendaría implementar métricas como **Conversión por Contacto** y **AHT**, pero actualmente los datos presentan inconsistencias (ej. más conversiones que contactos, duración mal registrada). Estas métricas serían extremadamente valiosas una vez se garantice que la data se estructura correctamente con identificadores únicos y duración precisa.  

---

### Impacto esperado
Adoptar estas métricas no solo permitirá evaluar el desempeño operativo de manera más justa y completa, sino que también fortalecerá la **experiencia del cliente**, reducirá costos y guiará decisiones estratégicas sobre **asignación de recursos y formación de agentes**.

---

## Firmado por:
**Daris Daniel Abad**

**Fecha:** 24 de septiembre de 2025

