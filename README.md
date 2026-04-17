# 📊 SQL Data Warehouse Project

## 📌 Overview

This project demonstrates the design and implementation of a **SQL Server-based data warehouse** using the **Medallion Architecture (Bronze → Silver → Gold)**.

Raw data from CRM and ERP systems is ingested, cleaned, and transformed into a curated **Sales Data Mart**, modeled as a **star schema** to support analytical reporting and business intelligence.

---

## 👨‍💻 About Me

I am a data engineering enthusiast focused on building scalable data solutions and improving my skills in **data modeling, ETL processes, and SQL development**.

This project represents a hands-on implementation of:

* End-to-end data warehouse design
* Data integration from multiple systems
* Transforming raw data into business-ready insights

It reflects how real-world data pipelines are built to support **analytics, reporting, and decision-making**.

---

## 🏗 Architecture

![Data Warehouse Architecture](./docs/High%20Level%20Architecture.png)

The project follows a layered Medallion approach:

* **Bronze Layer**
  Raw ingestion of CRM and ERP data (no transformations)

* **Silver Layer**
  Data cleaning and standardization:

  * Deduplication
  * Data type consistency
  * Data integration

* **Gold Layer (Data Mart)**
  Business-ready **Sales Data Mart**:

  * Star schema design
  * Optimized for analytical queries
  * Supports BI and reporting use cases

---

## 🔗 Data Sources

* **CRM System**

  * Customers
  * Products
  * Sales transactions

* **ERP System**

  * Additional customer attributes
  * Additional product attributes

---

## 🧠 Data Model

The Gold layer is structured as a **star schema**:

* Central **fact table** for sales transactions
* Supporting **dimension tables** for customers and products

📄 Full table and column-level documentation:
👉 **[DATA_CATALOG.md](./DATA_CATALOG.md)**

---

## 🚀 Key Highlights

* Built a complete **data warehouse pipeline**
* Applied **Medallion Architecture (Bronze → Silver → Gold)**
* Designed a **Sales Data Mart using Star Schema**
* Integrated **multiple data sources (CRM + ERP)**
* Ensured **data quality and consistency** through transformations

---

## 📏 Business Logic

* CRM provides **core transactional data**, ERP provides **data enrichment**
* Data is **cleaned and deduplicated** in the Silver layer
* Only **validated data** is loaded into the Gold layer
* Sales data is stored at **transaction grain (one row per order line)**
* `sales_amount = price × quantity`

---

## 📌 Notes

* The Gold layer represents a **business-oriented data mart**
* The architecture ensures **scalability and maintainability**
* The model is optimized for **BI tools and analytical workloads**

---
