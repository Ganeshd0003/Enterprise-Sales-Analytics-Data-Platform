USE DataWarehouse;
GO
-- =============================================================================
-- Quality Checks
-- =============================================================================

-- Check for Unwanted CID Format
-- Expectation: No Results
SELECT
    cid
FROM bronze.erp_cust_az12
WHERE cid LIKE 'NAS%';

-- Check for Invalid Birth Dates
-- Expectation: No Results
SELECT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT
    gen
FROM bronze.erp_cust_az12;