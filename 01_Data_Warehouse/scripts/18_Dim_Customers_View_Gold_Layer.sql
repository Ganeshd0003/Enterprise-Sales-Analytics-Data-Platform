USE DataWarehouse;
GO

CREATE OR ALTER VIEW gold.dim_customers AS
(
	SELECT
		ROW_NUMBER() OVER(ORDER BY cst_key) AS customer_key, -- Surrogate key
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		el.CNTRY AS country,
		ci.cst_marital_status AS marital_status,
		COALESCE(NULLIF(ci.cst_gndr, 'n/a'), ec.GEN, 'n/a') AS gender,
		ec.BDATE birthdate,
		ci.cst_Create_date AS create_date
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_loc_a101 AS el
		ON ci.cst_key = el.CID
	LEFT JOIN silver.erp_cust_az12 AS ec
		on ci.cst_key = ec.CID
);