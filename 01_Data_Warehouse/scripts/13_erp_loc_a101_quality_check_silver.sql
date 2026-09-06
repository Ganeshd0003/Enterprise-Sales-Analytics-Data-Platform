USE DataWarehouse;
GO
-- =============================================================================
-- Quality Checks
-- =============================================================================

-- Check for Unwanted CID Format
-- Expectation: No Results
SELECT
    cid
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') != cid;

-- Data Standardization & Consistency
SELECT DISTINCT
    cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;