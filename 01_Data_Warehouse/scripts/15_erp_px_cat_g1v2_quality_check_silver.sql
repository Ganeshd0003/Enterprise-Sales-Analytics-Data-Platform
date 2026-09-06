USE DataWarehouse;
GO
-- =============================================================================
-- Quality Checks
-- =============================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    id
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id);

-- Data Standardization & Consistency
SELECT DISTINCT
    cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
    subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2;