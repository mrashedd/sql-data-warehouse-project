/*
Purpose:
This stored procedure loads raw data into the Bronze layer of the data warehouse
from external CSV files. It performs a full refresh by truncating existing tables
and bulk inserting fresh data for CRM and ERP source systems, while logging load times
and handling errors.

Parameters: None
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze_layer AS
BEGIN
	DECLARE 
		@start_time DATETIME, 
		@end_date DATETIME, 
		@bronze_start_time DATETIME, 
		@bronze_end_time DATETIME;

	BEGIN TRY

		PRINT('------------------');
		PRINT('Loading CRM Tables');
		PRINT('------------------');

		SET @bronze_start_time = GETDATE();

		-- Load CRM Customer Info
		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.crm_customer_info');
		TRUNCATE TABLE bronze.crm_customer_info;

		PRINT('>> Inserting Data into: bronze.crm_customer_info');
		BULK INSERT bronze.crm_customer_info
		FROM 'D:\SQL 30 hours course\Data warehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,          -- Skip header row in CSV
			FIELDTERMINATOR = ',', -- Columns separated by comma
			ROWTERMINATOR = '\n',  -- Rows separated by new line
			TABLOCK                -- Improves bulk insert performance
		);

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load CRM Product Info
		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.crm_product_info');
		TRUNCATE TABLE bronze.crm_product_info;

		PRINT('>> Inserting Data into: bronze.crm_product_info');
		BULK INSERT bronze.crm_product_info
		FROM 'D:\SQL 30 hours course\Data warehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load CRM Sales Details
		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.crm_sales_details');
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT('>> Inserting Data into: bronze.crm_sales_details');
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\SQL 30 hours course\Data warehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');

		PRINT('--------------------------------------');
		PRINT('All CRM Tables are loaded successfully');
		PRINT('--------------------------------------');

		PRINT('Loading ERP Tables');
		PRINT('------------------');

		-- Load ERP Customer
		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.erp_cust_az12');
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT('>> Inserting Data into: bronze.erp_cust_az12');
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\SQL 30 hours course\Data warehouse Project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load ERP Location
		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.erp_loc_a101');
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT('>> Inserting Data into: bronze.erp_loc_a101');
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\SQL 30 hours course\Data warehouse Project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');
		PRINT('------------------');

		-- Load ERP Product Categories
		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.erp_px_cat_g1v2');
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT('>> Inserting Data into: bronze.erp_px_cat_g1v2');
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\SQL 30 hours course\Data warehouse Project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);

		SET @end_date = GETDATE();
		PRINT('Loading time: ' + CAST(DATEDIFF(SECOND, @start_time, @end_date) AS NVARCHAR(50)) + ' sec');

		SET @bronze_end_time = GETDATE();

		PRINT('--------------------------------------');
		PRINT('All ERP Tables are loaded successfully');
		PRINT('--------------------------------------');

		PRINT('Bronze Layer is loaded successfully');
		PRINT('Bronze Layer Loading time: ' 
			+ CAST(DATEDIFF(SECOND, @bronze_start_time, @bronze_end_time) AS NVARCHAR(50)) + ' sec');

	END TRY
	BEGIN CATCH
		PRINT('------------------------------------------');
		PRINT('Error occurred during loading bronze layer');
		PRINT('Error Message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50)));
		PRINT('Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(50)));
		PRINT('------------------------------------------');
	END CATCH
END;
