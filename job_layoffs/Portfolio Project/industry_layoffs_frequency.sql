--- Industry Layoff Frequency
WITH event_counts AS (
    SELECT
        industry,
        COUNT(*) AS event_count,
        COUNT(DISTINCT company) AS company_count,
        COUNT(DISTINCT to_char(layoff_date, 'YYYY-MM')) AS active_month
    FROM
        layoffs
    WHERE
        total_laid_off IS NOT NULL
    GROUP BY 
        industry
),
frequency_metrics AS(
    SELECT
        industry,
        event_count,
        company_count,
        active_month,
        ROUND(
            event_count::NUMERIC / NULLIF(company_count, 0),2
        ) AS event_per_company,
        ROUND(
            event_count::NUMERIC / NULLIF(active_month, 0),2
        ) AS event_per_month
    FROM
        event_counts
)
SELECT
    industry,
    event_count,
    company_count,
    active_month,
    event_per_company,
    event_per_month
FROM
    frequency_metrics
ORDER BY
    event_count DESC;