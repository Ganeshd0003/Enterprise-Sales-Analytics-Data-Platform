-- =============================================================================
-- Quality Checks
-- =============================================================================
USE DataWarehouse;
GO

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results

SELECT
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;

-- Data Standardization & Consistency
SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info;