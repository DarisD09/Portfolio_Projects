--- Country with the most layoffs every month
WITH total_layoffs_by_month_and_country AS (
    SELECT
        TO_CHAR(layoff_date, 'YYYY-MM') AS month_of_year,
        country,
        SUM(total_laid_off) AS total_layoffs
    FROM
        layoffs
    GROUP BY
        country,
        to_char(layoff_date, 'YYYY-MM')
        
),
rank_by_country AS (
    SELECT
        month_of_year,
        country,
        total_layoffs,
        RANK() OVER (PARTITION BY month_of_year ORDER BY total_layoffs DESC) AS
        country_rank
    FROM
        total_layoffs_by_month_and_country
    WHERE
        total_layoffs IS NOT NULL
)
SELECT
    month_of_year,
    country,
    total_layoffs, 
    country_rank
FROM
    rank_by_country
WHERE
    country_rank = 1
ORDER BY
    month_of_year;