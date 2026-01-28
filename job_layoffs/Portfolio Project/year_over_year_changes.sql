--- Year over Year changes
WITH total_layoffs_per_year AS (
    SELECT
        EXTRACT(YEAR FROM layoff_date) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM
        layoffs
    GROUP BY
        EXTRACT(YEAR FROM layoff_date)
)
SELECT
    year,
    total_layoffs,
    ROUND(
        100.0 * (total_layoffs - LAG(total_layoffs) OVER(ORDER BY year))
         / NULLIF(LAG(total_layoffs) OVER (ORDER BY year), 0),
        2
    ) AS yoy_change
FROM
    total_layoffs_per_year
ORDER BY
    year;

