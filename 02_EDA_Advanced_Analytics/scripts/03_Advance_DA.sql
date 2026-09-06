USE DataWarehouse;
GO


-- =====================================================
-- 1. SALES TREND ANALYSIS OVER TIME
-- Purpose:
-- Analyze how sales performance changes by year and month
-- =====================================================

SELECT
    YEAR(order_date) AS year,
    DATENAME(MONTH, order_date) AS month,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    YEAR(order_date),
    DATENAME(MONTH, order_date)
ORDER BY 
    year;



-- =====================================================
-- 2. SALES PERFORMANCE BY COUNTRY
-- Purpose:
-- Calculate total revenue generated from each country
-- =====================================================

SELECT
    c.country,
    SUM(s.sales_amount) AS total_sales
FROM gold.dim_customers AS c
INNER JOIN gold.fact_sales AS s
    ON c.customer_key = s.customer_key
GROUP BY 
    c.country
ORDER BY 
    c.country;



-- =====================================================
-- 3. TOP SELLING PRODUCT BY COUNTRY
-- Purpose:
-- Identify the highest revenue product in each country
-- =====================================================

SELECT *
FROM
(
    SELECT

        -- Rank products inside each country by sales
        RANK() OVER(
            PARTITION BY country 
            ORDER BY total_sales_by_product DESC
        ) AS rn,

        t.country,
        t.product_name,
        t.total_sales_by_product

    FROM
    (

        -- Calculate product revenue by country
        SELECT
            c.country,
            p.product_name,
            SUM(s.sales_amount) AS total_sales_by_product

        FROM gold.fact_sales AS s

        INNER JOIN gold.dim_products AS p
            ON s.product_key = p.product_key

        INNER JOIN gold.dim_customers AS c
            ON s.customer_key = c.customer_key

        GROUP BY
            c.country,
            p.product_name

    ) t

) tt

-- Return only the highest selling product per country
WHERE tt.rn = 1;



-- =====================================================
-- 4. BEST SALES YEAR BY COUNTRY
-- Purpose:
-- Find the year with maximum sales for selected countries
-- =====================================================

WITH cte1 AS
(
    -- Calculate yearly sales for each country
    SELECT
        c.country,
        SUM(s.sales_amount) AS total_sales,
        YEAR(s.order_date) AS year

    FROM gold.fact_sales AS s

    INNER JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key

    WHERE s.order_date IS NOT NULL

    GROUP BY
        c.country,
        YEAR(s.order_date)
),


cte2 AS
(
    -- Rank years based on highest sales per country
    SELECT
        RANK() OVER(
            PARTITION BY country 
            ORDER BY total_sales DESC
        ) AS rnk,

        *

    FROM cte1

    WHERE country IN 
    (
        'Germany',
        'United States',
        'Australia',
        'United Kingdom',
        'Canada',
        'France'
    )
)


-- Return best performing sales year
SELECT *
FROM cte2
WHERE rnk = 1;



-- =====================================================
-- 5. WORST SALES YEAR BY COUNTRY
-- Purpose:
-- Find the year with minimum sales for selected countries
-- =====================================================

WITH cte1 AS
(
    -- Calculate yearly sales for each country
    SELECT
        c.country,
        SUM(s.sales_amount) AS total_sales,
        YEAR(s.order_date) AS year

    FROM gold.fact_sales AS s

    INNER JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key

    WHERE s.order_date IS NOT NULL

    GROUP BY
        c.country,
        YEAR(s.order_date)
),


cte2 AS
(
    -- Rank years based on lowest sales per country
    SELECT
        RANK() OVER(
            PARTITION BY country 
            ORDER BY total_sales ASC
        ) AS rnk,

        *

    FROM cte1

    WHERE country IN 
    (
        'Germany',
        'United States',
        'Australia',
        'United Kingdom',
        'Canada',
        'France'
    )
)


-- Return lowest performing sales year
SELECT *
FROM cte2
WHERE rnk = 1;