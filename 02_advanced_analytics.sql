WITH MonthlySales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS sales_month,
        ROUND(SUM(sales), 2) AS current_month_sales
    FROM public.superstore2
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month,
    current_month_sales AS sales_sar,
    LAG(current_month_sales) OVER (ORDER BY sales_month) AS previous_month_sales_sar,
    ROUND(
        ((current_month_sales - LAG(current_month_sales) OVER (ORDER BY sales_month)) 
        / LAG(current_month_sales) OVER (ORDER BY sales_month)) * 100, 2
    ) AS mom_growth_percentage
FROM MonthlySales
ORDER BY sales_month;

WITH RankedProducts AS (
    SELECT 
        region,
        sub_category,
        ROUND(SUM(profit), 2) AS total_profit_sar,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(profit) DESC) AS profit_rank
    FROM public.superstore2
    GROUP BY region, sub_category
)
SELECT 
    region,
    sub_category,
    total_profit_sar,
    profit_rank
FROM RankedProducts
WHERE profit_rank <= 3
ORDER BY region, profit_rank;
