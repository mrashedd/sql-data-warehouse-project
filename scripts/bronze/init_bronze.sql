/*
Purpose:
	This script initializes the "bronze" layer of a data warehouse by recreating
	raw staging tables for CRM and ERP source systems. It ensures a clean state
	by dropping existing tables (if they exist) and then creating new ones to
	store incoming raw data without transformations.
*/

-- Recreate CRM Customer Information table
IF OBJECT_ID('bronze.crm_customer_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_customer_info;

CREATE TABLE bronze.crm_customer_info (
    customer_id int,
    customer_key nvarchar(50) NULL,
    customer_firstname nvarchar(50) NULL,
    customer_lastname nvarchar(50) NULL,
    customer_marital_status nvarchar(10) NULL,
    customer_gender nvarchar(10) NULL,
    customer_create_date date NULL
);

-- Recreate CRM Product Information table
IF OBJECT_ID('bronze.crm_product_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_product_info;

CREATE TABLE bronze.crm_product_info (
    product_id int,
    product_key nvarchar(50) NULL,
    product_name nvarchar(50) NULL,
    product_cost float NULL,
    product_line nvarchar(10) NULL,
    product_start_date date NULL,
    product_end_date date NULL
);

-- Recreate CRM Sales Details table
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sales_order_num nvarchar(50) NULL,
    sales_product_key nvarchar(50) NULL,
    sales_customer_id int NULL,
    sales_order_date int NULL,   -- Stored as integer (likely YYYYMMDD format)
    sales_ship_date int NULL,
    sales_due_date int NULL,
    sales_sales float NULL,
    sales_quantity int NULL,
    sales_price float NULL
);

-- Recreate ERP Customer table
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid nvarchar(50),
    bdate date,
    gen nvarchar(10)
);

-- Recreate ERP Product Category table
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id nvarchar(50),
    cat nvarchar(50),
    subcat nvarchar(50),
    maintenance nvarchar(50)
);

-- Recreate ERP Location table
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid nvarchar(50),
    cntry nvarchar(50)
);
