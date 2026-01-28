SELECT
    *
FROM
    layoffs

--- Layoffs over time (monthly and yearly)
WITH mom_layoffs AS(
    SELECT
        to_char(layoff_date, 'YYYY') AS year,
        to_char(layoff_date, 'mm') AS month,
        SUM(total_laid_off) AS total_layoffs
    FROM
        layoffs
    GROUP BY
         to_char(layoff_date, 'YYYY'),
        to_char(layoff_date, 'mm')
)
SELECT
    year,
    month,
    total_layoffs,
    ROUND(
        100.0 * total_layoffs / LAG(total_layoffs) OVER(
            PARTITION BY year ORDER BY year, month), 2
    ) AS layoffs_over_month
FROM
    mom_layoffs
ORDER BY   
    year,
    month;

--- Peaks and troughs in layoff activity
WITH monthly_layoffs AS (
    SELECT
        TO_CHAR(layoff_date, 'YYYY-MM') AS month,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs
    GROUP BY 1
),
rolling_stats AS (
    SELECT
        month,
        total_layoffs,
        AVG(total_layoffs) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
        ) AS rolling_avg,
        STDDEV(total_layoffs) OVER (
            ORDER BY month
            ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
        ) AS rolling_std,
        LAG(total_layoffs) OVER (ORDER BY month) AS prev_month_layoffs
    FROM monthly_layoffs
),
final_classification AS (
    SELECT
        month,
        total_layoffs,
        ROUND(
            100.0 * (total_layoffs - prev_month_layoffs)
            / NULLIF(prev_month_layoffs, 0),
            2
        ) AS mom_pct_change,
        CASE
            WHEN total_layoffs > rolling_avg + rolling_std THEN 'Peak'
            WHEN total_layoffs < rolling_avg - rolling_std THEN 'Trough'
            ELSE 'Normal'
        END AS layoff_level_category
    FROM rolling_stats
)
SELECT
    month,
    total_layoffs,
    mom_pct_change,
    layoff_level_category
FROM final_classification
ORDER BY month;

--- Acceleration or deceleration periods
WITH monthly_layoffs AS (
    SELECT
        to_char(layoff_date, 'YYYY-MM') AS month_of_year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs
    GROUP BY 1
),
mom_changes AS (
    SELECT
        month_of_year,
        total_layoffs,
        total_layoffs - LAG(total_layoffs) OVER (ORDER BY month_of_year) 
        AS mom_change
    FROM
        monthly_layoffs
),
aceleration_cal AS (
    SELECT
        month_of_year,
        total_layoffs,
        mom_change,
        mom_change - LAG(mom_change) OVER (ORDER BY month_of_year) 
        AS acceleration
    FROM
        mom_changes
)
SELECT
    month_of_year,
    total_layoffs,
    mom_change,
    acceleration,
    CASE
    WHEN mom_change > 0 AND acceleration > 0 THEN 'Worsening Faster'
    WHEN mom_change > 0 AND acceleration < 0 THEN 'Worsening Slowing'
    WHEN mom_change < 0 AND acceleration > 0 THEN 'Stabilizing / Recovering'
    WHEN mom_change < 0 AND acceleration < 0 THEN 'Decline Accelerating'
    ELSE 'No Clear Trend'
END AS acceleration_trend
FROM
    aceleration_cal
ORDER BY
    month_of_year;

--- Total layoffs by industry
SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM
    layoffs
WHERE
    industry IS NOT NULL
GROUP BY 
    industry
ORDER BY 
    total_layoffs DESC;

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

--- Total Layoffs by countries
WITH total_layoffs_by_countries AS (
    SELECT
        country,
        SUM(total_laid_off) AS total_layoffs
    FROM
        layoffs
    GROUP BY
        country
)
SELECT
    country,
    total_layoffs
FROM
    total_layoffs_by_countries
WHERE
    total_layoffs IS NOT NULL
ORDER BY
    total_layoffs DESC;

---
SELECT
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM
    layoffs
WHERE
    industry IS NOT NULL
GROUP BY
    industry
ORDER BY
    total_layoffs DESC;

---
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





WITH monthly_layoffs AS (
    SELECT
        TO_CHAR(layoff_date, 'YYYY-MM') AS month_of_year,
        SUM(total_laid_off) AS total_layoffs
    FROM 
        layoffs
    GROUP BY
        TO_CHAR(layoff_date, 'YYYY-MM')
)
SELECT
    month_of_year,
    total_layoffs,
    ROUND(
        100.0 * (total_layoffs - LAG(total_layoffs) OVER (ORDER BY month_of_year))
        / NULLIF(LAG(total_layoffs) OVER (ORDER BY month_of_year), 0),
        2
    ) AS mom_layoffs_pct
FROM 
    monthly_layoffs
ORDER BY 
    month_of_year;



WITH monthly_layoffs AS (
    SELECT
        DATE_TRUNC('month', layoff_date) AS month,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs
    GROUP BY DATE_TRUNC('month', layoff_date)
),
lagged AS (
    SELECT
        month,
        total_layoffs,
        LAG(total_layoffs) OVER (ORDER BY month) AS prev_month_layoffs
    FROM monthly_layoffs
)
SELECT
    TO_CHAR(month, 'YYYY-MM') AS month_of_year,
    total_layoffs,
    ROUND(
        100.0 * (total_layoffs - prev_month_layoffs)
        / NULLIF(prev_month_layoffs, 0),
        2
    ) AS mom_layoffs_pct
FROM lagged
ORDER BY month;


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







