# Saudi Retail & E-Commerce Analytics Database (PostgreSQL)

## Project Overview
This project demonstrates the end-to-end processing, optimization, and analysis of an enterprise-level retail dataset containing ~10,000 transaction records. As a **Computer Engineer**, I built this project to showcase production-grade SQL development, transitioning a raw unstructured dataset into an optimized, business-ready relational database tailored for the **Kingdom of Saudi Arabia (KSA)** market.

### Core Technical Focus
* **Data Engineering:** Automated type casting, data cleaning, and localized data transformations.
* **Advanced Analytics:** Implemented complex reporting metrics using Window Functions and Common Table Expressions (CTEs).
* **Database Optimization:** Created database views for analytics abstraction and implemented B-Tree indexes to optimize query execution times.

---

## Repository Structure
```text
├── 01_data_cleaning_localization.sql  # Type modifications & KSA market conversion
├── 02_advanced_analytics.sql          # Window functions, CTEs, and MoM metrics
└── 03_database_optimization.sql       # Views, Indexes, and execution tuning
```

Phase 1: Data Infrastructure & KSA Localization
The raw input file suffered from strict type mismatch constraints (numeric metrics stored as text). This phase permanently restructures the table schemas and converts fields to reflect local market realities in Saudi Arabia (currency shifted to SAR, regions mapped to KSA provinces).

SQL
-- 1. Permanently fix structural data types
ALTER TABLE public.superstore2 
    ALTER COLUMN sales TYPE NUMERIC USING sales::numeric,
    ALTER COLUMN profit TYPE NUMERIC USING profit::numeric,
    ALTER COLUMN discount TYPE NUMERIC USING discount::numeric,
    ALTER COLUMN quantity TYPE INT USING quantity::integer,
    ALTER COLUMN order_date TYPE DATE USING order_date::date,
    ALTER COLUMN ship_date TYPE DATE USING ship_date::date;

-- 2. Localize market data to Saudi Arabia (SAR Currency & Regional Mapping)
UPDATE public.superstore2
SET 
    country = 'Saudi Arabia',
    region = CASE 
        WHEN region = 'West' THEN 'Western Province'
        WHEN region = 'East' THEN 'Eastern Province'
        WHEN region = 'Central' THEN 'Central Province'
        ELSE 'Southern Province'
    END,
    state = CASE 
        WHEN state IN ('California', 'Washington', 'Oregon') THEN 'Makkah Province'
        WHEN state IN ('New York', 'Pennsylvania', 'Ohio') THEN 'Riyadh Province'
        WHEN state IN ('Texas', 'Illinois', 'Florida') THEN 'Eastern Province'
        ELSE 'Medina Province'
    END,
    sales = ROUND(sales * 3.75, 2), -- 1 USD to 3.75 SAR
    profit = ROUND(profit * 3.75, 2);
Phase 2: Advanced Executive KPIs
These production queries demonstrate advanced diagnostic analytics requested by executive leadership to track financial momentum and supply-chain efficiency.

Query 1: Month-over-Month (MoM) Sales Growth Tracking
Utilizes a Common Table Expression (CTE) and the LAG() Window Function to calculate consecutive monthly growth percentages across fiscal years.

SQL
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
Query 2: Top 3 Most Profitable Product Categories by Province
Employs DENSE_RANK() partitioned over geographic regions to filter out low-performing SKUs for warehouse stock prioritization.

SQL
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
Phase 3: Database Engineering & Optimization
Leveraging computer engineering fundamentals to optimize data access patterns, reduce disk I/O bottlenecks, and protect data presentation layers.

1. View Abstraction Layer
Decouples base table schemas from Business Intelligence tools (e.g., Power BI/Tableau) by calculating derived attributes safely at the database level.

SQL
CREATE OR REPLACE VIEW public.vw_executive_summary AS
SELECT 
    order_id,
    order_date,
    customer_id,
    segment,
    region,
    state,
    category,
    sub_category,
    sales AS sales_sar,
    profit AS profit_sar,
    quantity,
    CASE 
        WHEN sales > 0 THEN ROUND((profit / sales) * 100, 2)
        ELSE 0
    END AS profit_margin_percentage
FROM public.superstore2;
2. B-Tree Performance Tuning (Indexing)
To eliminate heavy Seq Scan (Sequential Table Scans) operations over heavy date filtering or regional queries, explicit B-Tree indexes were added.

SQL
-- Accelerates time-series queries and chronological analytics
CREATE INDEX idx_superstore_order_date ON public.superstore2(order_date);

-- Accelerates composite filtering on geographic domains
CREATE INDEX idx_superstore_region_state ON public.superstore2(region, state);
To audit query performance improvements, execution paths can be validated using PostgreSQL diagnostic tools:

SQL
EXPLAIN ANALYZE 
SELECT * FROM public.superstore2 WHERE region = 'Central Province';
Contact & Professional Details
Profile: Computer Engineer

Target Focus: Data Engineering / Business Intelligence / Advanced Database Development

Location Focus: Kingdom of Saudi Arabia (Riyadh / Jeddah / Eastern Province)
