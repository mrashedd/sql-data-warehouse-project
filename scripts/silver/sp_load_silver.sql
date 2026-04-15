/*
Purpose:
    This stored procedure loads the Silver layer of the data warehouse by transforming
    and cleaning raw data from the Bronze layer. It standardizes formats, removes duplicates,
    fixes invalid values, and ensures data consistency for downstream analytics.

    The procedure processes both CRM and ERP datasets and logs execution time for each step.
*/

CREATE OR ALTER PROCEDURE silver.load_silver_layer AS
BEGIN
	DECLARE 
		@start_time DATETIME, 
		@end_date DATETIME, 
		@layer_start_time DATETIME, 
		@layer_end_time DATETIME;

	BEGIN TRY

		PRINT('------------------');
		PRINT('Loading CRM Tables');
		PRINT('------------------');

		SET @layer_start_time = GETDATE();

		-- Load CRM Customer Info
		SET @start_time = GETDATE();

		PRINT('Truncating Table: silver.crm_customer_info');
		TRUNCATE TABLE silver.crm_customer_info;

		PRINT('>> Inserting Data into: silver.crm_customer_info');
		INSERT INTO silver.crm_customer_info (
			customer_id,
			customer_key,
			customer_firstname,
			customer_lastname,
			customer_marital_status,
			customer_gender,
			customer_create_date
		)
		SELECT 
			customer_id,
			TRIM(customer_key),
			TRIM(customer_firstname),
			TRIM(customer_lastname),

			-- Standardize marital status values
			CASE UPPER(TRIM(customer_marital_status))
				WHEN 'M' THEN 'Married'
				WHEN 'S' THEN 'Single'
				ELSE 'Unknown'
			END,

			-- Standardize gender values
			CASE UPPER(TRIM(customer_gender))
				WHEN 'M' THEN 'Male'
				WHEN 'F' THEN 'Female'
				ELSE 'Unknown'
			END,

			customer_create_date
		FROM (
			-- Keep only the latest record per customer
			SELECT *,
				ROW_NUMBER() OVER(
					PARTITION BY customer_id 
					ORDER BY customer_create_date DESC
				) AS is_unique
			FROM bronze.crm_customer_info
		) t
		WHERE is_unique = 1 
		  AND customer_id IS NOT NULL;

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load CRM Product Info
		SET @start_time = GETDATE();

		PRINT('Truncating Table: silver.crm_product_info');
		TRUNCATE TABLE silver.crm_product_info;

		PRINT('>> Inserting Data into: silver.crm_product_info');
		INSERT INTO silver.crm_product_info(
			product_id,
			product_key,
			product_category_id,
			product_name,
			product_cost,
			product_line,
			product_start_date,
			product_end_date
		)
		SELECT 
			product_id,

			-- Extract product key (remove prefix)
			SUBSTRING(TRIM(product_key),7,LEN(product_key)),

			-- Derive category id from key
			REPLACE(SUBSTRING(TRIM(product_key),1,5),'-','_'),

			TRIM(product_name),

			-- Replace NULL cost with 0
			COALESCE(product_cost,'0'),

			-- Map product line codes to descriptive values
			CASE TRIM(UPPER(product_line))
				WHEN 'R' THEN 'Road'
				WHEN 'M' THEN 'Mountain'
				WHEN 'T' THEN 'Touring'
				WHEN 'S' THEN 'Other Sales'
				ELSE 'Unknown'
			END,

			product_start_date,

			-- Derive end date using next record (SCD logic)
			DATEADD(DAY, -1,
				LEAD(product_start_date) OVER(
					PARTITION BY product_key 
					ORDER BY product_start_date
				)
			)
		FROM bronze.crm_product_info;

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load CRM Sales Details
		SET @start_time = GETDATE();

		PRINT('Truncating Table: silver.crm_sales_details');
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT('>> Inserting Data into: silver.crm_sales_details');
		INSERT INTO silver.crm_sales_details(
			sales_order_num,
			sales_product_key,
			sales_customer_id,
			sales_order_date,
			sales_ship_date,
			sales_due_date,
			sales_sales,
			sales_quantity,
			sales_price
		)
		SELECT
			TRIM(sales_order_num),
			TRIM(sales_product_key),
			sales_customer_id,

			-- Validate and convert date fields from INT format (YYYYMMDD)
			CASE 
				WHEN LEN(CAST(sales_order_date AS varchar(8))) = 8
				AND TRY_CONVERT(date, CAST(sales_order_date AS varchar(8))) IS NOT NULL
				THEN TRY_CONVERT(date, CAST(sales_order_date AS varchar(8)))
			END,

			CASE 
				WHEN LEN(CAST(sales_ship_date AS varchar(8))) = 8
				AND TRY_CONVERT(date, CAST(sales_ship_date AS varchar(8))) IS NOT NULL
				THEN TRY_CONVERT(date, CAST(sales_ship_date AS varchar(8)))
			END,

			CASE 
				WHEN LEN(CAST(sales_due_date AS varchar(8))) = 8
				AND TRY_CONVERT(date, CAST(sales_due_date AS varchar(8))) IS NOT NULL
				THEN TRY_CONVERT(date, CAST(sales_due_date AS varchar(8)))
			END,

			-- Fix inconsistent sales values
			CASE
				WHEN sales_sales IS NULL 
				  OR sales_sales <= 0 
				  OR sales_sales != sales_quantity * ABS(sales_price)
				THEN sales_quantity * ABS(sales_price)
				ELSE sales_sales
			END,

			sales_quantity,

			-- Derive price if missing or invalid
			CASE
				WHEN sales_price IS NULL OR sales_price <= 0
				THEN ABS(sales_sales) / NULLIF(sales_quantity,0)
				ELSE sales_price
			END

		FROM bronze.crm_sales_details;
		
		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');

		PRINT('--------------------------------------');
		PRINT('All CRM Tables are loaded successfully');
		PRINT('--------------------------------------');

		PRINT('Loading ERP Tables');
		PRINT('------------------');

		-- Load ERP Customer
		SET @start_time = GETDATE();

		PRINT('Truncating Table: silver.erp_cust_az12');
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT('>> Inserting Data into: silver.erp_cust_az12');
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			-- Remove prefix from customer id
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				ELSE cid
			END,

			-- Remove future birthdates
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END,

			-- Standardize gender values
			CASE
				WHEN TRIM(UPPER(gen)) IN ('M','MALE') THEN 'Male'
				WHEN TRIM(UPPER(gen)) IN ('F','FEMALE') THEN 'Female'
				ELSE 'Unknown'
			END
		FROM bronze.erp_cust_az12;
		
		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load ERP Location
		SET @start_time = GETDATE();

		PRINT('Truncating Table: silver.erp_loc_a101');
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT('>> Inserting Data into: silver.erp_loc_a101');
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT
			REPLACE(cid,'-',''),

			-- Standardize country names
			CASE
				WHEN TRIM(UPPER(cntry)) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(UPPER(cntry)) = 'DE' THEN 'Germany'
				WHEN TRIM(UPPER(cntry)) = '' OR cntry IS NULL THEN 'Unknown'
				ELSE TRIM(cntry)
			END
		FROM bronze.erp_loc_a101;

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load ERP Product Categories (no transformation needed)
		SET @start_time = GETDATE();

		PRINT('Truncating Table: silver.erp_px_cat_g1v2');
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');

		SET @layer_end_time = GETDATE();

		PRINT('--------------------------------------');
		PRINT('All ERP Tables are loaded successfully');
		PRINT('--------------------------------------');

		PRINT('Silver Layer is loaded successfully');
		PRINT('Silver Layer Loading time: ' 
			+ CAST(DATEDIFF(SECOND, @layer_start_time, @layer_end_time) AS NVARCHAR(50)) + ' sec');

	END TRY
	BEGIN CATCH
		PRINT('------------------------------------------');
		PRINT('Error occurred during loading Silver layer');
		PRINT('Error Message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50)));
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(50)));
		PRINT('------------------------------------------');
	END CATCH
END;
