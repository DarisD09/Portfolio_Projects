# Global Layoffs Analysis (2020–2023)

## Overview
This project explores global layoff data from 2020 to 2023 to understand **how layoffs evolved over time**, **where they were most concentrated**, and **which industries were most affected**.

The goal of the analysis is not just to count layoffs, but to understand their **patterns, volatility, and underlying behavior** at both a short-term (monthly) and long-term (yearly) level.  
All analysis was done using **SQL**, with the output structured to support dashboard visualization.



##  Questions This Project Answers
This case study was built to answer a few core questions:

- How did layoffs change over time on a monthly and yearly basis?
- How large were the year-over-year swings in total layoffs?
- Which countries experienced the most layoffs each month?
- Which industries face layoffs most often?
- Which industries experience the most severe layoffs per event?
- Can we objectively identify periods of unusually high or low layoff activity?



##  Tools Used
- **PostgreSQL** 
- **VS Code**
- **Git & GitHub** 
- **Power BI** 

## Power BI Dashboard

🔗 **Live Dashboard:**  
[Global Layoffs Dashboard – Power BI](https://app.powerbi.com/view?r=eyJrIjoiZjc4M2I4YmItMTNmOC00NmVlLTg0N2UtNGYwNjFlMzFjM2Y4IiwidCI6IjJjZmNkYzkzLTRmM2MtNDExOS05NDAyLWMwOTdlYTA2MmU2YyJ9)

##  How the Analysis Was Done
Each SQL file in this project focuses on answering **one specific analytical question**. This keeps the analysis modular, easy to follow, and easy to validate.

---

###  Layoffs Over Time (Monthly Trends)
**Query:** `layoffs_overtime.sql`

This query aggregates total layoffs by month and calculates **month-over-month percentage change**, resetting at the start of each year.

```SQL
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
```

### Monthly Layoffs with MoM Change (Sample)
| Year | Month | Total Layoffs | MoM Change (%) |
|------|-------|---------------|----------------|
| 2020 | 3     | 9,628         | NULL           |
| 2020 | 4     | 26,710        | 177.42         |
| 2020 | 5     | 25,804        | -3.39          |
| 2020 | 6     | 7,627         | -70.44         |
| 2020 | 7     | 7,112         | -6.75          |
| 2020 | 8     | 1,969         | -72.31         |
| 2020 | 9     | 609           | -69.07         |
| 2020 | 10    | 450           | -26.11         |
| 2020 | 11    | 237           | -47.33         |
| 2020 | 12    | 852           | 259.49         |
| 2021 | 1     | 6,813         | NULL           |
| 2021 | 2     | 868           | -87.26         |
| 2021 | 3     | 47            | -94.59         |
| 2021 | 4     | 261           | 455.32         |
---
**Note:** Month-over-Month (MoM) change is calculated **within each year**.  
January values are shown as `NULL` because there is no prior month available for comparison within the same year.


**What this shows:**  
Layoffs tend to move in sharp spikes rather than smooth trends. Periods of economic stress are followed by partial recoveries, not immediate stabilization.

---

###  Year-over-Year Changes
**Query:**  `year_over_year_changes.sql`

This section summarizes total layoffs at a yearly level and calculates the year-over-year percentage change to highlight broader structural shifts.

```SQL
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
```
### Year-over-Year Layoff Changes
| Year | Total Layoffs | YoY Change (%) |
|------|---------------|----------------|
| 2020 | 80,998        | NULL           |
| 2021 | 15,823        | **-80.46**     |
| 2022 | 160,661       | **915.36**     |
| 2023 | 125,677       | **-21.78**     |
---
**Note:** Year-over-Year (YoY) change is calculated relative to the previous year.  
The first year is shown as `NULL` because there is no prior year available for comparison.


**Key takeaways:**
- Layoffs dropped sharply in **2021**, following the initial COVID shock 
- **2022 saw a massive rebound**, becoming the most severe year in the dataset  
- In **2023**, layoffs declined again, though they remained elevated  

This view helps explain why certain months show extreme volatility.

---

### Identifying Peaks and Troughs
**Query:** `peaks_and_troughs.sql`

Layoff levels are classified using rolling averages and rolling standard deviation.  
- **Peak** indicates unusually high layoff activity relative to surrounding months  
- **Normal** represents expected levels within historical volatility  
- **Trough** (if present) indicates unusually low activity  

This approach helps distinguish true anomalies from regular month-to-month fluctuations.

```SQL
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
```
### Peaks and Troughs in Layoff Activity (Sample)
| Month   | Total Layoffs | MoM Change (%) | Layoff Level |
|---------|---------------|----------------|--------------|
| 2020-03 | 9,628         | NULL           | **Normal**   |
| 2020-04 | 26,710        | 177.42         | **Peak**     |
| 2020-05 | 25,804        | -3.39          | **Peak**     |
| 2020-06 | 7,627         | -70.44         | **Normal**   |
| 2020-07 | 7,112         | -6.75          | **Normal**   |
| 2020-08 | 1,969         | -72.31         | **Normal**   |
| 2020-09 | 609           | -69.07         | **Normal**   |
| 2020-10 | 450           | -26.11         | **Normal**   |
| 2020-11 | 237           | -47.33         | **Normal**   |
| 2020-12 | 852           | 259.49         | **Normal**   |
| 2021-01 | 6,813         | 699.65         | **Peak**     |
| 2021-02 | 868           | -87.26         | **Normal**   |
| 2021-03 | 47            | -94.59         | **Normal**   |
| 2021-04 | 261           | 455.32         | **Normal**   |
| 2021-06 | 2,434         | 832.57         | **Peak**     |
---
**Why this matters:**  
Not every high-layoff month is an anomaly. This approach highlights only the months that truly stand out compared to historical behavior.

---

### Layoff Frequency by Industry
**Query:** `industry_layoffs_frequency.sql`

This section examines how frequently layoffs occur across industries by analyzing event volume, company participation, and active months.


```SQL
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
```
### Industry Layoff Frequency (Sample)
| Industry        | Event Count | Company Count | Active Months | Events per Company | Events per Month |
|-----------------|-------------|---------------|---------------|--------------------|------------------|
| Finance         | 200         | 170           | 21            | 1.18               | 9.52             |
| Retail          | 132         | 103           | 22            | 1.28               | 6.00             |
| Healthcare      | 120         | 105           | 20            | 1.14               | 6.00             |
| Transportation  | 109         | 80            | 19            | 1.36               | 5.74             |
| Marketing       | 103         | 93            | 18            | 1.11               | 5.72             |
| Food            | 94          | 74            | 23            | 1.27               | 4.09             |
| Consumer        | 86          | 72            | 19            | 1.19               | 4.53             |
| Other           | 78          | 69            | 19            | 1.13               | 4.11             |
| Real Estate     | 76          | 51            | 21            | 1.49               | 3.62             |
| Education       | 67          | 51            | 22            | 1.31               | 3.05             |

---
**Insight:**  
Some industries experience layoffs frequently, even if the total number of affected employees is relatively moderate.

---

###  Layoff Severity by Industry
**Query:** `average_layoffs_per_event.sql`

This section measures **layoff severity** by calculating the average number of employees affected per layoff event.


```SQL
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
```
### Average Layoffs per Event by Industry (Sample)
| Industry        | Total Layoffs | Event Count | Avg Layoffs per Event |
|-----------------|---------------|-------------|-----------------------|
| Hardware        | 13,828        | 13          | 1,063                 |
| Consumer        | 45,182        | 101         | 447                   |
| Sales           | 13,216        | 34          | 388                   |
| Other           | 35,789        | 106         | 337                   |
| Fitness         | 8,748         | 26          | 336                   |
| Travel          | 17,159        | 57          | 301                   |
| Construction    | 3,863         | 13          | 297                   |
| Retail          | 43,613        | 163         | 267                   |
| Transportation  | 33,748        | 129         | 261                   |
| Food            | 22,855        | 115         | 198                   |
---
**Note:**  
Average layoffs per event measures **severity**, not frequency.  
Industries at the top of this table tend to experience fewer layoff events, but each event affects a larger number of employees.


**Insight:**  
Industries with fewer layoff events can still be high-risk if those events tend to be large and concentrated.

---

###  Country with the Most Layoffs Each Month
**Query:** `top_country_per_month.sql`

Countries are ranked monthly based on total layoffs, identifying the top country for each period.

```SQL
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
```
### Country with the Most Layoffs per Month (Sample)
| Month     | Country        | Total Layoffs | Rank |
|-----------|----------------|---------------|------|
| 2020-03   | United States  | 7,850         | 1    |
| 2020-04   | United States  | 19,821        | 1    |
| 2020-05   | United States  | 14,674        | 1    |
| 2020-06   | United States  | 3,926         | 1    |
| 2020-07   | Netherlands    | 4,375         | 1    |
| 2020-08   | United States  | 1,456         | 1    |
| 2020-09   | United States  | 567           | 1    |
| 2020-10   | India          | 250           | 1    |
| 2020-11   | United States  | 237           | 1    |
| 2020-12   | India          | 600           | 1    |
| 2021-01   | India          | 3,600         | 1    |
| 2021-02   | India          | 400           | 1    |
| 2021-03   | United States  | 47            | 1    |
| 2021-04   | United States  | 261           | 1    |
| 2021-06   | United States  | 2,434         | 1    |
---
**Insight:**  
The United States leads in most months, though other countries temporarily emerge during region-specific disruptions.


## Key Takeaways
- Layoffs behave differently across industries: some are driven by **frequency**, others by **severity**
- Economic shocks create clear, measurable spikes in layoff activity
- Monthly volatility makes more sense when viewed alongside yearly trends
- Country and industry context is essential to understanding raw layoff numbers


## Conclusion
This analysis shows that layoffs are not driven by a single factor, but by a combination of **timing, geography, and industry dynamics**. While certain periods experienced sharp, short-term spikes driven by economic shocks, broader year-over-year trends provide essential context for understanding those fluctuations.

Geographically, layoffs are heavily concentrated in a small number of countries, with the United States leading most months, though leadership occasionally shifts during region-specific disruptions. At the industry level, the data reveals a clear distinction between **frequency** and **severity**: some industries experience layoffs repeatedly in smaller waves, while others are impacted through fewer but significantly larger events.

By combining time-series analysis, statistical classification, and industry-level metrics, this project demonstrates how raw layoff counts can be transformed into actionable insights. These findings highlight the importance of analyzing workforce reductions from multiple angles rather than relying on single summary metrics.


## Dataset
Public layoffs dataset, cleaned and standardized for analysis.

## Signed By:
**Daris Daniel**





