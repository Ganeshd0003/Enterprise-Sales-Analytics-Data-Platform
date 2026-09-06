USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.full_data_loading
AS
BEGIN
    SET NOCOUNT ON;

    -- 1)
    PRINT '>> Truncating table : silver.crm_cust_info'
    TRUNCATE TABLE silver.crm_cust_info;

    PRINT '>> Inserting Data into : silver.crm_cust_info'
    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        TRIM(cst_key) AS cst_key,
        TRIM(ISNULL(cst_firstname, 'n/a')) AS cst_firstname,
        TRIM(ISNULL(cst_lastname, 'n/a')) AS cst_lastname,
        CASE TRIM(ISNULL(cst_marital_status, ''))
            WHEN 'S' THEN 'Single'
            WHEN 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE TRIM(ISNULL(cst_gndr, ''))
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER
               (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS Flag
        FROM bronze.crm_cust_info
    ) t
    WHERE Flag = 1 AND t.cst_id IS NOT NULL;


    -- 2)
    PRINT '>> Truncating table : silver.crm_prd_info'
    TRUNCATE TABLE silver.crm_prd_info;

    PRINT '>> Inserting Data into : silver.crm_prd_info'
    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT TOP 1000
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
        SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
        prd_nm,
        ISNULL(prd_cost,0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'T' THEN 'Touring'
            WHEN 'S' THEN 'Other Sales'
            ELSE 'n/a'
        END AS prd_line,
        CAST (prd_start_dt AS DATE) AS prd_state_dt,
        CAST(
            DATEADD(
                DAY,
                -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            ) AS DATE
        ) AS prd_end_dt
    FROM bronze.crm_prd_info;


    -- 3)
    PRINT '>> Truncating table : silver.crm_sales_details'
    TRUNCATE TABLE silver.crm_sales_details;

    PRINT '>> Inserting Data into : silver.crm_sales_details'
    INSERT INTO silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    (
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            TRY_CONVERT(DATE,CAST(sls_order_dt AS varchar(8)),112) AS sls_order_dtt,
            TRY_CONVERT(DATE,CAST(sls_ship_dt AS VARCHAR(8)),112) AS sls_ship_dtt,
            TRY_CONVERT(DATE,CAST(sls_due_dt AS VARCHAR(8)),112) AS sls_due_dtt,
            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales < 0
                     OR sls_sales <> (sls_quantity * ABS(sls_price))
                THEN (sls_quantity * ABS(sls_price))
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE sls_price
            END AS sls_price
        FROM DataWarehouse.bronze.crm_sales_details
        WHERE TRY_CONVERT(
                  DATE,
                  CAST(sls_order_dt AS VARCHAR(8)),
                  112
              ) <= CAST(GETDATE() AS DATE)
    );


    -- 4)
    PRINT '>> Truncating table : silver.erp_cust_az12'
    TRUNCATE TABLE silver.erp_cust_az12;

    PRINT '>> Inserting Data into : silver.erp_cust_az12'
    INSERT INTO silver.erp_cust_az12
    (
        CID,
        BDATE,
        GEN
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid) - 3)
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > GETDATE() THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;


    -- 5)
    PRINT '>> Truncating table : silver.erp_loc_a101'
    TRUNCATE TABLE silver.erp_loc_a101;

    PRINT '>> Inserting Data into : silver.erp_loc_a101'
    INSERT INTO silver.erp_loc_a101
    (
        CID,
        CNTRY
    )
    (
        SELECT
            REPLACE(CID,'-','') AS CID,
            CASE
                WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
                WHEN TRIM(CNTRY) = '' OR TRIM(CNTRY) IS NULL THEN 'n/a'
                ELSE TRIM(CNTRY)
            END AS CNTRY
        FROM bronze.erp_loc_a101
    );


    -- 6)
    PRINT '>> Truncating table : silver.erp_px_cat_g1v2'
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    PRINT '>> Inserting Data into : silver.erp_px_cat_g1v2'
    INSERT INTO silver.erp_px_cat_g1v2
    (
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    )
    SELECT
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    FROM bronze.erp_px_cat_g1v2;

END;
GO