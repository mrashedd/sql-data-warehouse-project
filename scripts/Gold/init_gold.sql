/*
Purpose:
    This script creates or updates the Gold layer views in the data warehouse.
    It defines dimension tables (customers and products) and a fact table (sales)
    following a Star Schema data model. The views transform and integrate data 
    from the Silver layer into clean, business-ready structures optimized for 
    analytical querying and reporting.
*/

-- ============================================
-- Customer Dimension
-- ============================================
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key, -- Generate surrogate key
    cc.customer_id,
    cc.customer_key AS customer_number,
    cc.customer_firstname AS first_name,
    cc.customer_lastname AS last_name,
    el.cntry AS country,
    cc.customer_marital_status AS marital_status,
    CASE
        -- If CRM gender is 'unknown', fallback to ERP value
        WHEN LOWER(cc.customer_gender) = 'unknown' THEN COALESCE(ec.gen, 'Unknown')
        ELSE cc.customer_gender
    END AS gender,
    ec.bdate AS birthdate,
    cc.customer_create_date AS create_date
FROM silver.crm_customer_info cc
LEFT JOIN silver.erp_cust_az12 ec
    ON cc.customer_key = ec.cid
LEFT JOIN silver.erp_loc_a101 el
    ON cc.customer_key = el.cid;

GO

-- ============================================
-- Product Dimension
-- ============================================
CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_start_date, product_id) AS product_key, -- Generate surrogate key
    cp.product_id,
    cp.product_key AS product_number,
    cp.product_name,
    cp.product_category_id AS category_id,
    ep.cat AS category,
    ep.subcat AS subcategory,
    ep.maintenance,
    cp.product_cost AS cost,
    cp.product_line,
    cp.product_start_date AS start_date
FROM silver.crm_product_info cp
LEFT JOIN silver.erp_px_cat_g1v2 ep
    ON cp.product_category_id = ep.id
WHERE cp.product_end_date IS NULL; -- Keep only active products

GO

-- ============================================
-- Sales Fact Table
-- ============================================
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    sales_order_num AS order_number,
    dp.product_key,
    dc.customer_key,
    sales_order_date AS order_date,
    sales_ship_date AS shipping_date,
    sales_due_date AS due_date,
    sales_price AS price,
    sales_quantity AS quantity,
    sales_sales AS sales_amount
FROM silver.crm_sales_details cs
LEFT JOIN gold.dim_customers dc
    ON cs.sales_customer_id = dc.customer_id
LEFT JOIN gold.dim_products dp
    ON cs.sales_product_key = dp.product_number;
