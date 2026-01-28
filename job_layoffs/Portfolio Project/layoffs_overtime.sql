--- Layoffs over time (monthly and yearly)
WITH monthly_layoffs AS (
    SELECT
        DATE_TRUNC('month', layoff_date) AS month,
        EXTRACT(YEAR FROM layoff_date) AS year,
        EXTRACT(MONTH FROM layoff_date) AS month_num,
        SUM(total_laid_off) AS total_layoffs
    FROM 
        layoffs
    GROUP BY
        DATE_TRUNC('month', layoff_date),
        EXTRACT(YEAR FROM layoff_date),
        EXTRACT(MONTH FROM layoff_date)
)
SELECT
    year,
    month_num AS month,
    total_layoffs,
    ROUND(
        100.0 * (total_layoffs - LAG(total_layoffs) OVER (
            PARTITION BY year
            ORDER BY month_num
        ))
        / NULLIF(
            LAG(total_layoffs) OVER (
                PARTITION BY year
                ORDER BY month_num
            ), 0
        ),
        2
    ) AS mom_layoffs_pct
FROM 
    monthly_layoffs
ORDER BY 
    year, 
    month_num;