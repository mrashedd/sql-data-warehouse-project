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

## 🥉 Bronze Layer (Raw Data)

### Description
The Bronze layer stores raw data ingested from CRM and ERP systems without transformations.

---

### Table: `crm_customer_info`
**Description:** Raw customer data from CRM system

| Column Name | Data Type | Description |
|------------|----------|------------|
| customer_id | INT | Unique identifier for customer |
| customer_key | NVARCHAR | Business key from source system |
| customer_firstname | NVARCHAR | Customer first name |
| customer_lastname | NVARCHAR | Customer last name |
| customer_marital_status | NVARCHAR | Marital status |
| customer_gender | NVARCHAR | Gender |
| customer_create_date | DATE | Record creation date |

---

### Table: `crm_product_info`
**Description:** Raw product data from CRM system

| Column Name | Data Type | Description |
|------------|----------|------------|
| product_id | INT | Unique product identifier |
| product_name | NVARCHAR | Product name |
| product_category | NVARCHAR | Product category |
| product_subcategory | NVARCHAR | Product subcategory |

---

### Table: `crm_sales_details`
**Description:** Raw sales transactions from CRM system

| Column Name | Data Type | Description |
|------------|----------|------------|
| sales_id | INT | Unique sales transaction ID |
| customer_id | INT | Customer reference |
| product_id | INT | Product reference |
| sales_amount | DECIMAL | Total transaction value |
| sales_date | DATE | Date of sale |
| sales_due_date | DATE | Expected completion/payment date |

---

### Table: `erp_customer_details`
**Description:** Additional customer attributes from ERP system

| Column Name | Data Type | Description |
|------------|----------|------------|
| customer_id | INT | Customer identifier |
| additional_attributes | NVARCHAR | Extra customer details |

---

### Table: `erp_product_details`
**Description:** Additional product attributes from ERP system

| Column Name | Data Type | Description |
|------------|----------|------------|
| product_id | INT | Product identifier |
| additional_attributes | NVARCHAR | Extra product details |

---

## 🥈 Silver Layer (Cleaned & Standardized)

### Description
The Silver layer transforms and cleans raw data:
- Removes duplicates
- Standardizes formats
- Resolves inconsistencies
- Integrates CRM and ERP data

---

### Table: `dim_customers`
**Description:** Consolidated and cleaned customer dimension

| Column Name | Data Type | Description |
|------------|----------|------------|
| customer_id | INT | Unique customer identifier |
| full_name | NVARCHAR | Customer full name |
| gender | NVARCHAR | Standardized gender |
| marital_status | NVARCHAR | Standardized marital status |
| create_date | DATE | Customer creation date |

---

### Table: `dim_products`
**Description:** Consolidated and enriched product dimension

| Column Name | Data Type | Description |
|------------|----------|------------|
| product_id | INT | Unique product identifier |
| product_name | NVARCHAR | Product name |
| category | NVARCHAR | Product category |
| subcategory | NVARCHAR | Product subcategory |

---

### Table: `fact_sales_clean`
**Description:** Cleaned and validated sales transactions

| Column Name | Data Type | Description |
|------------|----------|------------|
| sales_id | INT | Unique sales ID |
| customer_id | INT | Reference to customer |
| product_id | INT | Reference to product |
| sales_amount | DECIMAL | Transaction value |
| sales_date | DATE | Date of transaction |

---

## 🥇 Gold Layer (Business-Ready – Star Schema)

### Description
The Gold layer contains analytics-ready data modeled as a **star schema**.

---

### ⭐ Fact Table: `fact_sales`
**Description:** Central fact table storing sales transactions

| Column Name | Data Type | Description |
|------------|----------|------------|
| sales_id | INT | Unique sales identifier |
| customer_id | INT | Foreign key to dim_customers |
| product_id | INT | Foreign key to dim_products |
| sales_amount | DECIMAL | Total sales value |
| sales_date | DATE | Date of sale |

---

### 📘 Dimension Table: `dim_customers`
**Description:** Customer dimension for analysis

| Column Name | Data Type | Description |
|------------|----------|------------|
| customer_id | INT | Primary key |
| full_name | NVARCHAR | Customer full name |
| gender | NVARCHAR | Gender |
| marital_status | NVARCHAR | Marital status |

---

### 📘 Dimension Table: `dim_products`
**Description:** Product dimension for analysis

| Column Name | Data Type | Description |
|------------|----------|------------|
| product_id | INT | Primary key |
| product_name | NVARCHAR | Product name |
| category | NVARCHAR | Product category |
| subcategory | NVARCHAR | Product subcategory |

---

## 🔗 Relationships (Star Schema)

- `fact_sales.customer_id` → `dim_customers.customer_id`
- `fact_sales.product_id` → `dim_products.product_id`

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
