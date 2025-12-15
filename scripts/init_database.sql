/*
=========================================================
Create Data Warehouse Database
=========================================================
Script Purpose:
This script creates a new MySQL database named "DataWarehouse".
If the database already exists, it will be dropped and recreated.

The Data Warehouse follows a Bronze / Silver / Gold layered architecture.
Each layer is represented by dedicated tables within the database.

WARNING:
    Running this script will DROP the entire "DataWarehouse" database if it exists.
    ALL data will be permanently deleted.
    Use with caution and only in development environments.
=========================================================
*/


-- Drop database if it already exists
DROP DATABASE IF EXISTS DataWarehouse;

-- Create new database
CREATE DATABASE DataWarehouse;

-- Select the database
USE DataWarehouse;

-- =========================================
-- Bronze Layer (Raw Data)
-- =========================================
CREATE TABLE bronze;

-- =========================================
-- Silver Layer (Cleaned & Transformed Data)
-- =========================================
CREATE TABLE silver;

-- =========================================
-- Gold Layer (Analytics Ready)
-- =========================================
CREATE TABLE gold;

