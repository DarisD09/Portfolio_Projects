--- average layoffs per event
WITH layoffs_and_events AS (
    SELECT
        industry,
        SUM(total_laid_off) AS total_layoffs,
        COUNT(*) AS event_count
    FROM
        layoffs
    GROUP BY
        industry
),
average_layoffs_per_events AS (
    SELECT
        industry,
        total_layoffs,
        event_count,
        total_layoffs / event_count AS avg_layoffs_per_event
    FROM
        layoffs_and_events
)
SELECT
    industry,
    total_layoffs,
    event_count,
    avg_layoffs_per_event
FROM
    average_layoffs_per_events
WHERE
    total_layoffs IS NOT NULL
ORDER BY
    avg_layoffs_per_event DESC;