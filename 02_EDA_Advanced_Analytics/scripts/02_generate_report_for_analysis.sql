USE DataWarehouse;
GO


-- =====================================================
-- KPI / MEASURE EXPLORATION REPORT
-- Purpose:
-- Calculate key business metrics from sales data
-- =====================================================


-- Total revenue generated from all sales
SELECT 
    'Total Sales' AS measure_name,
    CAST(SUM(sales_amount) AS DECIMAL(18,2)) AS measure_value
FROM gold.fact_sales


UNION ALL


-- Total quantity of products sold
SELECT 
    'Total Quantity',
    CAST(SUM(quantity) AS DECIMAL(18,2))
FROM gold.fact_sales


UNION ALL


-- Average selling price across all transactions
SELECT 
    'Average Price',
    CAST(AVG(price) AS DECIMAL(18,2))
FROM gold.fact_sales


UNION ALL


-- Total number of unique orders
SELECT 
    'Total Orders',
    COUNT(DISTINCT order_number)
FROM gold.fact_sales


UNION ALL


-- Total number of sales transactions
SELECT 
    'Total Transactions',
    COUNT(*)
FROM gold.fact_sales


UNION ALL


-- Total number of unique products available
SELECT 
    'Total Products',
    COUNT(DISTINCT product_key)
FROM gold.dim_products


UNION ALL


-- Total number of customers who purchased products
SELECT 
    'Total Customers',
    COUNT(DISTINCT customer_key)
FROM gold.fact_sales;