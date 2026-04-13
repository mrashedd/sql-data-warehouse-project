/*
Purpose:
This script ensures a clean setup of the 'data_warehouse' database by dropping it if it exists,
then recreating it along with a layered architecture using three schemas: bronze, silver, and gold.
This structure is commonly used in data warehousing for staging, transformation, and presentation layers.
*/

USE master;

-- Check if the database already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'data_warehouse')
BEGIN
    -- Force disconnect all users to allow safe deletion
    ALTER DATABASE data_warehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Drop the existing database
    DROP DATABASE data_warehouse;
END;
GO

-- Create a fresh database
CREATE DATABASE data_warehouse;
GO

-- Switch context to the new database
USE data_warehouse;
GO

-- Create schemas representing different data layers
CREATE SCHEMA bronze;  -- Raw / ingested data
GO

CREATE SCHEMA silver;  -- Cleaned and transformed data
GO

CREATE SCHEMA gold;    -- Business-ready / aggregated data
GO
