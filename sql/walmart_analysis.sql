/*=============================================================================
                  WALMART RETAIL SALES - BUSINESS ANALYTICS SUITE
=============================================================================*/
USE walmart;

-- Data Verification & Ingestion Baseline
SELECT COUNT(*) AS total_records FROM sales;
SELECT * FROM sales LIMIT 5;

-- Check distinct store branches and locations
SELECT COUNT(DISTINCT branch) AS total_branches, COUNT(DISTINCT city) AS total_cities FROM sales;

-- Identify minimum and maximum transaction quantities
SELECT MIN(quantity) AS min_qty, MAX(quantity) AS max_qty FROM sales;


/*=============================================================================
Q1: Payment Method Distribution & Volume
Evaluate different payment methods, total transaction counts, and quantities sold.
=============================================================================*/
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS total_qty_sold,
    ROUND(SUM(total), 2) AS total_revenue
FROM sales
GROUP BY payment_method
ORDER BY no_payments DESC;


/*=============================================================================
Q2: Highest-Rated Product Category per Store Branch
Display the branch, top category by customer satisfaction, and average rating.
=============================================================================*/
SELECT 
    branch, 
    category, 
    ROUND(avg_rating, 2) AS avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM sales
    GROUP BY branch, category
) AS ranked_categories
WHERE rnk = 1;


/*=============================================================================
Q3: Peak Footfall & Busiest Day of the Week per Branch
Identify which day of the week generates the highest transaction count per store.
=============================================================================*/
SELECT 
    branch, 
    day_name, 
    no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(sale_date) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM sales
    GROUP BY branch, day_name
) AS ranked_days
WHERE rnk = 1;


/*=============================================================================
Q4: Aggregate Item Quantities Sold by Payment Channel
Determine inventory velocity by payment method.
=============================================================================*/
SELECT 
    payment_method,
    SUM(quantity) AS total_qty_sold,
    ROUND(AVG(quantity), 2) AS avg_qty_per_trans
FROM sales
GROUP BY payment_method;


/*=============================================================================
Q5: Product Category Customer Satisfaction Rating by City
Calculate average, minimum, and maximum customer ratings per city and category.
=============================================================================*/
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY city, category
ORDER BY city, avg_rating DESC;


/*=============================================================================
Q6: Category Profitability & Net Return Contribution
Calculate total net profit generated per product line.
=============================================================================*/
SELECT 
    category,
    ROUND(SUM(total), 2) AS gross_revenue,
    ROUND(SUM(total * profit_margin), 2) AS total_profit,
    ROUND(AVG(profit_margin) * 100, 2) AS avg_profit_margin_pct
FROM sales
GROUP BY category
ORDER BY total_profit DESC;


/*=============================================================================
Q7: Dominant Customer Payment Preference by Branch
Identify the most preferred payment method in each individual branch.
=============================================================================*/
WITH payment_ranks AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM sales
    GROUP BY branch, payment_method
)
SELECT 
    branch, 
    payment_method AS preferred_payment_method,
    total_trans
FROM payment_ranks
WHERE rnk = 1;


/*=============================================================================
Q8: Operating Shift Sales Performance & Transaction Distribution
Categorize transactions into Morning (< 12 PM), Afternoon (12-5 PM), and Evening (> 5 PM).
=============================================================================*/
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(sale_time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(sale_time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices,
    ROUND(SUM(total), 2) AS shift_revenue
FROM sales
GROUP BY branch, shift
ORDER BY branch, shift_revenue DESC;


/*=============================================================================
Q9: Year-over-Year (YoY) Revenue Decrease Ratio (2022 vs 2023)
Detect branches exhibiting the sharpest revenue contraction across consecutive years.
=============================================================================*/
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM sales
    WHERE YEAR(sale_date) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM sales
    WHERE YEAR(sale_date) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    ROUND(r2022.revenue, 2) AS revenue_2022,
    ROUND(r2023.revenue, 2) AS revenue_2023,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_pct
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_pct DESC
LIMIT 5;


/*=============================================================================
Q10: Data Integrity & Anomalous Transaction Auditing
Detect missing, blank, or orphaned transactions.
=============================================================================*/
SELECT *
FROM sales
WHERE payment_method IS NULL
   OR payment_method = ''
   OR total <= 0;
