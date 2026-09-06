USE DataWarehouse;
GO


-- =============================================================================
-- Create Report: gold.report_products
-- Purpose: This report consolidates key product metrics and behaviors.
-- =============================================================================


IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
DROP VIEW gold.report_products;
GO


CREATE VIEW gold.report_products AS


WITH base_query AS
(
    /* ============================================================================
    1. Base Query
    Retrieves product and sales information from fact and product dimension
    ============================================================================
    */


    SELECT

        -- Sales information
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,


        -- Product information
        p.product_id,
        p.product_key,
        p.product_name,
        p.category_id,
        p.category,
        p.subcategory,
        p.cost,
        p.product_line,
        p.start_date,
        p.maintenance


    FROM DataWarehouse.gold.fact_sales AS f


    LEFT JOIN DataWarehouse.gold.dim_products AS p

        -- Match sales with products
        ON f.product_key = p.product_key


    WHERE f.order_date IS NOT NULL
),



product_aggregations AS
(
    /*
    ============================================================================
    2. Product Aggregations
    Summarizes sales performance at product level
    ============================================================================
    */


    SELECT


        product_id,
        product_key,
        product_name,
        category_id,
        category,
        subcategory,
        cost,
        product_line,
        start_date,
        maintenance,


        -- Product lifespan in months
        DATEDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan,


        -- Latest sale date
        MAX(order_date) AS last_sale_date,


        -- Total number of orders
        COUNT(DISTINCT order_number) AS total_orders,


        -- Total customers who purchased product
        COUNT(DISTINCT customer_key) AS total_customers,


        -- Total revenue
        SUM(sales_amount) AS total_sales,


        -- Total quantity sold
        SUM(quantity) AS total_quantity,


        -- Average selling price
        ROUND(
            AVG(
                CAST(sales_amount AS FLOAT) 
                / NULLIF(quantity,0)
            ),
            2
        ) AS avg_selling_price



    FROM base_query


    GROUP BY

        product_id,
        product_key,
        product_name,
        category_id,
        category,
        subcategory,
        cost,
        product_line,
        start_date,
        maintenance
)



/*
============================================================================
3. Final Product Report
Adds product segmentation and additional KPIs
============================================================================
*/


SELECT


    -- Product details
    product_id,
    product_key,
    product_name,
    category_id,
    category,
    subcategory,
    cost,
    product_line,
    start_date,
    maintenance,


    -- Last sale information
    last_sale_date,


    -- Months since last sale
    DATEDIFF(
        MONTH,
        last_sale_date,
        GETDATE()
    ) AS recency_in_months,


    -- Product performance segment
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,


    -- Product lifecycle
    lifespan,


    -- Sales metrics
    total_orders,
    total_sales,
    total_quantity,
    total_customers,


    -- Pricing metric
    avg_selling_price,


    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,


    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue


FROM product_aggregations;
GO