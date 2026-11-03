CREATE DATABASE IF NOT EXISTS dubai_realestate;
USE dubai_realestate;

-- =========================================================
-- DUBAI REAL ESTATE ANALYTICS
-- AI-assisted SQL analysis | MySQL
-- Dataset: Dubai Land Department transactions, 2020-2024
-- Cleaned dataset: 286,303 rows, 34 columns
-- =========================================================


-- =========================================================
-- SECTION 1: DATA VALIDATION
-- =========================================================

-- Q1: Check total records and date range
SELECT
    COUNT(*) AS total_records,
    MIN(instance_date) AS first_transaction_date,
    MAX(instance_date) AS last_transaction_date,
    COUNT(DISTINCT transaction_id) AS unique_transactions
FROM transactions;


-- Q2: Check for duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- Q3: Check missing values in important analytical columns
SELECT
    COUNT(*) AS total_records,
    SUM(actual_worth IS NULL) AS missing_actual_worth,
    SUM(price_per_sqm IS NULL) AS missing_price_per_sqm,
    SUM(area_name_en IS NULL OR TRIM(area_name_en) = '') AS missing_area,
    SUM(property_type_en IS NULL OR TRIM(property_type_en) = '') AS missing_property_type,
    SUM(instance_date IS NULL) AS missing_transaction_date
FROM transactions;


-- =========================================================
-- SECTION 2: MARKET OVERVIEW
-- =========================================================

-- Q4: Overall sales market snapshot (2020-2024)
SELECT
    COUNT(*) AS total_sales_transactions,
    ROUND(SUM(actual_worth), 2) AS total_sales_value_aed,
    ROUND(AVG(actual_worth), 2) AS average_sale_price_aed,
    ROUND(AVG(price_per_sqm), 2) AS average_price_per_sqm
FROM transactions
WHERE trans_group_en = 'Sales'
  AND actual_worth > 0;


-- Q5: Top 10 areas by transaction volume
SELECT
    area_name_en,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY area_name_en
ORDER BY transaction_count DESC
LIMIT 10;


-- Q6: Average price per square metre by property type
SELECT
    property_type_en,
    ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND price_per_sqm > 0
GROUP BY property_type_en
ORDER BY avg_price_per_sqm DESC;


-- Q7: Yearly transaction trend
SELECT
    `year`,
    COUNT(*) AS transaction_count,
    ROUND(SUM(actual_worth), 2) AS total_sales_value_aed,
    ROUND(AVG(actual_worth), 2) AS average_sale_price_aed
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY `year`
ORDER BY `year`;


-- Q8: Monthly transaction trend
SELECT
    DATE_FORMAT(instance_date, '%Y-%m') AS transaction_month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(actual_worth), 2) AS monthly_sales_value_aed
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY DATE_FORMAT(instance_date, '%Y-%m')
ORDER BY transaction_month;


-- Q9: Parking availability and average price per sqm
SELECT
    has_parking,
    ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND price_per_sqm > 0
GROUP BY has_parking
ORDER BY avg_price_per_sqm DESC;


-- =========================================================
-- SECTION 3: AREA AND REGIONAL ANALYSIS
-- =========================================================

-- Q10: Top 10 areas by total sales value
SELECT
    area_name_en,
    ROUND(SUM(actual_worth), 2) AS total_sales_value_aed,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND actual_worth > 0
GROUP BY area_name_en
ORDER BY total_sales_value_aed DESC
LIMIT 10;


-- Q11: Top 10 areas by average price per sqm
-- Only areas with at least 100 sales transactions are included
SELECT
    area_name_en,
    ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND price_per_sqm > 0
  AND area_name_en IS NOT NULL
GROUP BY area_name_en
HAVING COUNT(*) >= 100
ORDER BY avg_price_per_sqm DESC
LIMIT 10;


-- Q12: Compare transactions by metro information availability
-- Non-null metro information does not prove actual proximity
SELECT
    CASE
        WHEN nearest_metro_en IS NULL OR TRIM(nearest_metro_en) = ''
            THEN 'Metro information unavailable'
        ELSE 'Metro information available'
    END AS metro_information_status,
    ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND price_per_sqm > 0
GROUP BY metro_information_status;


-- =========================================================
-- SECTION 4: PROPERTY ANALYSIS
-- =========================================================

-- Q13: Top 5 property sub-types by transaction volume
SELECT
    property_sub_type_en,
    COUNT(*) AS transaction_count,
    ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm
FROM transactions
WHERE trans_group_en = 'Sales'
  AND property_sub_type_en IS NOT NULL
GROUP BY property_sub_type_en
ORDER BY transaction_count DESC
LIMIT 5;


-- Q14: Room distribution for flats
SELECT
    rooms_en,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND property_type_en = 'Flat'
  AND rooms_en IS NOT NULL
GROUP BY rooms_en
ORDER BY transaction_count DESC;


-- Q15: Median sale price by property type
WITH ranked_transactions AS (
    SELECT
        property_type_en,
        actual_worth,
        ROW_NUMBER() OVER (
            PARTITION BY property_type_en
            ORDER BY actual_worth
        ) AS row_num,
        COUNT(*) OVER (
            PARTITION BY property_type_en
        ) AS total_rows
    FROM transactions
    WHERE trans_group_en = 'Sales'
      AND actual_worth > 0
      AND property_type_en IS NOT NULL
)
SELECT
    property_type_en,
    ROUND(AVG(actual_worth), 2) AS median_sale_price_aed,
    MAX(total_rows) AS transaction_count
FROM ranked_transactions
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    CEIL((total_rows + 1) / 2)
)
GROUP BY property_type_en
ORDER BY median_sale_price_aed DESC;


-- Q16: Distribution of transactions across sale price bands
WITH price_categories AS (
    SELECT
        transaction_id,
        actual_worth,
        CASE
            WHEN actual_worth < 500000 THEN 'Budget: Below AED 500K'
            WHEN actual_worth < 2000000 THEN 'Mid-range: AED 500K-2M'
            WHEN actual_worth < 5000000 THEN 'Premium: AED 2M-5M'
            ELSE 'Luxury: AED 5M+'
        END AS price_band
    FROM transactions
    WHERE trans_group_en = 'Sales'
      AND actual_worth > 0
)
SELECT
    price_band,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS transaction_percentage,
    ROUND(AVG(actual_worth), 2) AS avg_sale_price_aed
FROM price_categories
GROUP BY price_band
ORDER BY transaction_count DESC;


-- =========================================================
-- SECTION 5: PROJECT ANALYSIS
-- =========================================================

-- Q17: Top 10 projects by total sales value
SELECT
    project_name_en,
    ROUND(SUM(actual_worth), 2) AS total_sales_value_aed,
    COUNT(*) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
  AND actual_worth > 0
  AND project_name_en IS NOT NULL
  AND TRIM(project_name_en) <> ''
GROUP BY project_name_en
ORDER BY total_sales_value_aed DESC
LIMIT 10;


-- =========================================================
-- SECTION 6: TIME SERIES ANALYSIS
-- =========================================================

-- Q18: Month-over-month sales growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(instance_date, '%Y-%m') AS sales_month,
        SUM(actual_worth) AS total_sales_value
    FROM transactions
    WHERE trans_group_en = 'Sales'
      AND actual_worth > 0
    GROUP BY DATE_FORMAT(instance_date, '%Y-%m')
),
sales_with_previous_month AS (
    SELECT
        sales_month,
        total_sales_value,
        LAG(total_sales_value) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    ROUND(total_sales_value, 2) AS current_month_sales,
    ROUND(previous_month_sales, 2) AS previous_month_sales,
    ROUND(
        (total_sales_value - previous_month_sales)
        * 100.0 / NULLIF(previous_month_sales, 0),
        2
    ) AS month_over_month_growth_pct
FROM sales_with_previous_month
ORDER BY sales_month;


-- Q19: Quarterly sales trend
SELECT
    `year`,
    `quarter`,
    COUNT(*) AS transaction_count,
    ROUND(SUM(actual_worth), 2) AS total_sales_value_aed
FROM transactions
WHERE trans_group_en = 'Sales'
  AND actual_worth > 0
GROUP BY `year`, `quarter`
ORDER BY `year`, `quarter`;


-- Q20: Running total of monthly sales value
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(instance_date, '%Y-%m') AS sales_month,
        SUM(actual_worth) AS monthly_sales_value
    FROM transactions
    WHERE trans_group_en = 'Sales'
      AND actual_worth > 0
    GROUP BY DATE_FORMAT(instance_date, '%Y-%m')
)
SELECT
    sales_month,
    ROUND(monthly_sales_value, 2) AS monthly_sales_value,
    ROUND(
        SUM(monthly_sales_value) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_sales_value
FROM monthly_sales
ORDER BY sales_month;


-- =========================================================
-- END OF DUBAI REAL ESTATE ANALYSIS
-- 20 analytical queries
-- =========================================================
