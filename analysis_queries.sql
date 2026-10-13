create database dubai_realestate;
-- ============================================
-- Dubai Real Estate Analytics
-- SQL Analysis Queries
-- Author: Yusuf Baig
-- Database: dubai_realestate
-- ============================================

USE dubai_realestate;

-- ============================================
-- SECTION 1: MARKET OVERVIEW
-- ============================================

-- Q1: Overall Market Snapshot (2024 Sales)
SELECT COUNT(transaction_id) AS total_transactions, 
       SUM(actual_worth) AS total_sales_value, 
       AVG(actual_worth) AS avg_sale_price
FROM transactions
WHERE trans_group_en = 'Sales' AND year = 2024;

-- Q2: Top 10 Areas by Transaction Volume
SELECT area_name_en, COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY area_name_en
ORDER BY transaction_count DESC
LIMIT 10;

-- Q3: Average Price per SQM by Property Type
SELECT property_type_en, 
       AVG(meter_sale_price) AS avg_price_per_sqm, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY property_type_en
ORDER BY avg_price_per_sqm DESC;

-- Q4: Monthly Transaction Trend (2024)
SELECT DATE_FORMAT(instance_date, '%Y-%m') AS month, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE year = 2024 AND trans_group_en = 'Sales'
GROUP BY DATE_FORMAT(instance_date, '%Y-%m')
ORDER BY month ASC;

-- Q5: Parking Impact on Price
SELECT has_parking, 
       AVG(meter_sale_price) AS avg_price_per_sqm, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY has_parking;


-- ============================================
-- SECTION 2: AREA & REGIONAL ANALYSIS
-- ============================================

-- Q6: Top 10 Areas by Total Sales Value (2024)
SELECT area_name_en, 
       SUM(actual_worth) AS total_sales_value, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales' AND year = 2024
GROUP BY area_name_en
ORDER BY SUM(actual_worth) DESC
LIMIT 10;

-- Q12: Top Areas by Avg Price/SQM (min 100 transactions)
SELECT area_name_en, 
       AVG(meter_sale_price) AS avg_price_per_sqm, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales' AND year = 2024
GROUP BY area_name_en
HAVING COUNT(transaction_id) > 100
ORDER BY AVG(meter_sale_price) DESC
LIMIT 10;

-- Q13: Metro Proximity Impact
SELECT 
    CASE WHEN nearest_metro_en IS NULL THEN 'No Metro' ELSE 'Has Metro' END AS has_metro,
    AVG(meter_sale_price) AS avg_price_per_sqm, 
    COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales' AND year = 2024
GROUP BY CASE WHEN nearest_metro_en IS NULL THEN 'No Metro' ELSE 'Has Metro' END;


-- ============================================
-- SECTION 3: PROPERTY ANALYSIS
-- ============================================

-- Q8: Top 5 Property Sub-Types
SELECT property_sub_type_en, 
       COUNT(transaction_id) AS transaction_count, 
       AVG(meter_sale_price) AS avg_price_per_sqm
FROM transactions
WHERE trans_group_en = 'Sales'
GROUP BY property_sub_type_en
ORDER BY COUNT(transaction_id) DESC
LIMIT 5;

-- Q9: Room Distribution for Flats
SELECT rooms_en, COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales' AND property_type_en = 'Flat'
GROUP BY rooms_en
ORDER BY transaction_count DESC;

-- Q11: Median Sale Price by Property Type (2024)
WITH ranked AS (
    SELECT property_type_en, actual_worth,
           ROW_NUMBER() OVER (PARTITION BY property_type_en ORDER BY actual_worth) AS rn,
           COUNT(*) OVER (PARTITION BY property_type_en) AS total
    FROM transactions
    WHERE trans_group_en = 'Sales' AND year = 2024
)
SELECT property_type_en,
       AVG(actual_worth) AS median_sale_price,
       MAX(total) AS transaction_count
FROM ranked
WHERE rn IN (FLOOR((total + 1) / 2), CEIL((total + 1) / 2))
GROUP BY property_type_en
ORDER BY median_sale_price DESC;

-- Q17: Price Bands Distribution
WITH bands AS (
    SELECT transaction_id, meter_sale_price,
           CASE WHEN actual_worth < 500000 THEN 'Budget'
                WHEN actual_worth BETWEEN 500000 AND 2000000 THEN 'Mid' 
                WHEN actual_worth BETWEEN 2000000 AND 5000000 THEN 'Premium'
                ELSE 'Luxury' 
           END AS price_bands
    FROM transactions
    WHERE trans_group_en = 'Sales' AND year = 2024
)
SELECT price_bands, 
       COUNT(transaction_id) AS transaction_count, 
       AVG(meter_sale_price) AS avg_price_per_sqm
FROM bands 
GROUP BY price_bands
ORDER BY COUNT(transaction_id) DESC;


-- ============================================
-- SECTION 4: PROJECTS & TIME ANALYSIS
-- ============================================

-- Q14: Top 10 Projects by Total Sales (2024)
SELECT project_name_en, 
       SUM(actual_worth) AS total_sales_value, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales' AND year = 2024 AND project_name_en IS NOT NULL
GROUP BY project_name_en
ORDER BY SUM(actual_worth) DESC
LIMIT 10;

-- Q15: Month-over-Month Sales Growth (2024)
WITH monthly AS (
    SELECT DATE_FORMAT(instance_date, '%Y-%m') AS month, 
           SUM(actual_worth) AS total_sales_value
    FROM transactions
    WHERE year = 2024 AND trans_group_en = 'Sales'
    GROUP BY DATE_FORMAT(instance_date, '%Y-%m')
)
SELECT month, total_sales_value,
       LAG(total_sales_value) OVER (ORDER BY month ASC) AS prev_month_value,
       ROUND(
           (total_sales_value - LAG(total_sales_value) OVER (ORDER BY month ASC)) * 100.0 
           / LAG(total_sales_value) OVER (ORDER BY month ASC), 2
       ) AS growth_pct
FROM monthly
ORDER BY month ASC;

-- Q10: Quarterly Trend (2024)
SELECT quarter, 
       COUNT(transaction_id) AS transaction_count, 
       SUM(actual_worth) AS total_sales_value
FROM transactions
WHERE trans_group_en = 'Sales' AND year = 2024
GROUP BY quarter
ORDER BY quarter ASC;

-- Q20: Running Total of Sales by Month (2024)
WITH monthly AS (
    SELECT DATE_FORMAT(instance_date, '%Y-%m') AS month,
           SUM(actual_worth) AS monthly_sales
    FROM transactions
    WHERE trans_group_en = 'Sales' AND year = 2024
    GROUP BY DATE_FORMAT(instance_date, '%Y-%m')
)
SELECT month, monthly_sales,
       SUM(monthly_sales) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

-- Q7: YoY Sales Comparison (2023 vs 2024)
SELECT year, 
       SUM(actual_worth) AS total_sales_value, 
       COUNT(transaction_id) AS transaction_count
FROM transactions
WHERE trans_group_en = 'Sales' AND year IN (2023, 2024)
GROUP BY year
ORDER BY year ASC;


-- ============================================
-- SECTION 5: ADVANCED (WINDOW FUNCTIONS)
-- ============================================

-- Q16: Top 3 Properties per Area by Price
WITH ranked AS (
    SELECT area_name_en, transaction_id, actual_worth,
           RANK() OVER (PARTITION BY area_name_en ORDER BY actual_worth DESC) AS price_rank
    FROM transactions
    WHERE trans_group_en = 'Sales' AND year = 2024
)
SELECT area_name_en, transaction_id, actual_worth, price_rank
FROM ranked
WHERE price_rank <= 3
ORDER BY area_name_en, price_rank;

-- Q18: Top 3 Property Types per Area
WITH agg AS (
    SELECT area_name_en, property_type_en, COUNT(*) AS transaction_count
    FROM transactions
    WHERE trans_group_en = 'Sales' AND year = 2024
    GROUP BY area_name_en, property_type_en
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY area_name_en ORDER BY transaction_count DESC) AS area_rank
    FROM agg
)
SELECT area_name_en, property_type_en, transaction_count, area_rank
FROM ranked
WHERE area_rank <= 3
ORDER BY area_name_en, area_rank;

-- Q19: YoY Growth by Property Type
SELECT property_type_en,
       SUM(CASE WHEN year = 2023 THEN actual_worth ELSE 0 END) AS sales_2023,
       SUM(CASE WHEN year = 2024 THEN actual_worth ELSE 0 END) AS sales_2024,
       ROUND(
           (SUM(CASE WHEN year = 2024 THEN actual_worth ELSE 0 END) 
            - SUM(CASE WHEN year = 2023 THEN actual_worth ELSE 0 END)) * 100.0
           / NULLIF(SUM(CASE WHEN year = 2023 THEN actual_worth ELSE 0 END), 0), 2
       ) AS growth_pct
FROM transactions
WHERE trans_group_en = 'Sales' AND year IN (2023, 2024)
GROUP BY property_type_en
ORDER BY growth_pct DESC;

-- ============================================
-- END OF ANALYSIS QUERIES
-- Total: 20 queries
-- ============================================