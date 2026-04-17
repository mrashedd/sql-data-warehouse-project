# 📊 Data Catalog – SQL Data Warehouse Project

## 📌 Project Overview
This project implements a **data warehouse** using SQL Server following the **Medallion Architecture** (Bronze → Silver → Gold).

The goal is to integrate and transform data from multiple source systems into a structured **star schema** to support analytics and reporting.

### 🏗 Architecture
- **Bronze Layer** → Raw data ingestion from source systems
- **Silver Layer** → Cleaned and standardized data
- **Gold Layer** → Business-ready data modeled as a **star schema**

---

## 🔗 Data Sources

### CRM System
The CRM system provides core business transaction data:
- Customer information
- Product information
- Sales transactions

### ERP System
The ERP system enriches CRM data with additional details:
- Extended customer attributes
- Additional product attributes

---

## 🥇 Gold Layer (Business-Ready – Star Schema)

### Description
The Gold layer contains analytics-ready data modeled as a **star schema**.

---

### ⭐ Fact Table: `fact_sales`
**Description:** Central fact table storing sales transactions

| Column Name | Data Type | Description |
|------------|----------|------------|
| order_number |	NVARCHAR(50) |	A unique alphanumeric identifier for each sales order (e.g., 'SO54496') |
| product_key |	INT |	Surrogate key linking the order to the product dimension table |
| customer_key |	INT |	Surrogate key linking the order to the customer dimension table |
| order_date |	DATE |	The date when the order was placed |
| shipping_date |	DATE |	The date when the order was shipped to the customer |
| due_date |	DATE |	The date when the order payment was due |
| price |	INT |	The price per unit of the product for the line item, in whole currency units (e.g., 25) |
| quantity | INT |	The number of units of the product ordered for the line item (e.g., 1) |
| sales_amount | INT |	The total monetary value of the sale for the line item, in whole currency units (e.g., 25) |

---

### 📘 Dimension Table: `dim_customers`
**Description:** Customer dimension for analysis

| Column Name | Data Type | Description |
|------------|----------|------------|
| customer_key | INT | Surrogate key |
| customer_id | INT | Unique identifier for each customer |
| customer_number | NVARCHAR | Alphanumeric identifier representing the customer, used for tracking and referencing |
| first_name | NVARCHAR | Customer's first name |
| last_name | NVARCHAR | Customer's last name |
| country | NVARCHAR | Customer's country (e.g., 'Australia') |
| marital_status | NVARCHAR | Customer's marital_status (e.g., 'Married', 'Single') |
| gender | NVARCHAR | Customer's gender (e.g., 'Male', 'Female', 'Unknown') |
| birthdate | DATE | Customer's birthdate formatted as YYYY-MM-DD (e.g., 1971-10-06)|
| create_date	| DATE |	The date and time when the customer record was created in the system |
---

### 📘 Dimension Table: `dim_products`
**Description:** Product dimension for analysis

| Column Name | Data Type | Description |
|------------|----------|------------|
| product_key |	INT	| Surrogate key uniquely identifying each product record in the product dimension table |
| product_id |	INT |	A unique identifier assigned to the product for internal tracking and referencing |
| product_number |	NVARCHAR(50) |	A structured alphanumeric code representing the product, often used for categorization or inventory |
| product_name |	NVARCHAR(50) |	Descriptive name of the product, including key details such as type, color, and size |
| category_id |	NVARCHAR(50) |	A unique identifier for the product's category, linking to its high-level classification |
| category |	NVARCHAR(50) |	The broader classification of the product (e.g., Bikes, Components) to group related items |
| subcategory |	NVARCHAR(50) |	A more detailed classification of the product within the category, such as product type |
| maintenance |	NVARCHAR(50) |	Indicates whether the product requires maintenance (e.g., 'Yes', 'No') |
| cost |	INT |	The cost or base price of the product, measured in monetary units |
| product_line |	NVARCHAR(50) |	The specific product line or series to which the product belongs (e.g., Road, Mountain) |
| start_date |	DATE |	The date when the product became available for sale or use, stored in | 


---

## 🔗 Relationships (Star Schema)

- `fact_sales.customer_key` → `dim_customers.customer_key`
- `fact_sales.product_key` → `dim_products.product_key`

---

## 📏 Business Rules

- Customer and product data are **integrated from CRM and ERP systems**
- CRM provides core transactional data, while ERP enriches attributes
- Duplicate records are removed during the Silver layer
- Only **valid and cleaned transactions** are loaded into the Gold layer
- Sales data is stored at the **transaction level (grain = one row per sale)**

---

## 🧾 Naming Conventions

| Pattern | Meaning |
|--------|--------|
| `fact_` | Fact tables |
| `dim_` | Dimension tables |
| `crm_` | CRM source tables |
| `erp_` | ERP source tables |

---

## 📌 Notes

- The data model follows a **star schema** for efficient querying
- The Medallion architecture ensures data quality and scalability
- The Gold layer is optimized for BI tools and reporting

---
