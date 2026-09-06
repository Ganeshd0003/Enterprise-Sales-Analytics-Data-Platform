USE DataWarehouse;
GO
-- =============================================================================
-- Quality Checks
-- =============================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check for Invalid Product Keys
-- Expectation: No Results
SELECT
    sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key
    FROM silver.crm_prd_info
);

-- Check for Invalid Customer IDs
-- Expectation: No Results
SELECT
    sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM silver.crm_cust_info
);

-- Check for Invalid Order Dates
-- Expectation: No Results
SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101
   OR TRY_CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) IS NULL;

-- Check for Invalid Shipping Dates
-- Expectation: No Results
SELECT
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LEN(sls_ship_dt) != 8
   OR sls_ship_dt > 20500101
   OR TRY_CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) IS NULL;

-- Check for Invalid Due Dates
-- Expectation: No Results
SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR TRY_CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) IS NULL;

-- Check Data Consistency: Sales = Quantity × Price
-- Sales must not be NULL, zero, or negative
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * ABS(sls_price)
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;