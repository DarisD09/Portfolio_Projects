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