USE DataWarehouse;
GO
-- WE ARE DOING CHANGES IN TABLE AND ADD COLUMN AND MODIFY DATE COLUMN SO WE NEED TO MODIFY EXISTING TABLE'S METADATA

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details
(
	sls_ord_num	VARCHAR(20),
	sls_prd_key	VARCHAR(20),
	sls_cust_id	INT,
	sls_order_dt DATE,
	sls_ship_dt	DATE,
	sls_due_dt	DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price DECIMAL(10,2),
	dwh_created_date DATETIME2 DEFAULT GETDATE()
);


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
	SELECT sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      TRY_CONVERT(DATE,CAST(sls_order_dt AS varchar(8)),112) AS sls_order_dtt,
      TRY_CONVERT(DATE,CAST(sls_ship_dt AS VARCHAR(8)),112) AS sls_ship_dtt,
      TRY_CONVERT(DATE,CAST(sls_due_dt AS VARCHAR(8)),112) AS sls_due_dtt,
      CASE
        WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales <> (sls_quantity * ABS(sls_price))
            THEN (sls_quantity * ABS(sls_price))
        ELSE sls_sales
      END AS sls_sales,
      sls_quantity,
      CASE
        WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales/ NULLIF(sls_quantity,0)
        ELSE sls_price
      END AS sls_price
 FROM DataWarehouse.bronze.crm_sales_details
);