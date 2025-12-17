/*
-- =============================================================================
-- Script: Load Bronze Layer
-- Description: Truncates and loads raw data from CSV files into Bronze tables.
-- =============================================================================
  Script Purpose:
      This script creates tables in the "bronze" schema, dropping existing tables
        if the already exist.
        Run this scrip to re-define the DDL structure of "bronze" Tables
-- =============================================================================     

-------------------------------------------------------------------------------
WARNING / OPTIMIZATION NOTE:
This script is written for MySQL. However, during development, it was 
identified that SQL Server (T-SQL) would be a more efficient choice for 
this Bronze Layer process due to:
1. Better support for complex Stored Procedures.
2. Superior Bulk Insert capabilities and error logging.
3. Native integration with enterprise ETL tools.
-------------------------------------------------------------------------------
*/

DELIMITER $$

CREATE PROCEDURE bronze.load_bronze()
BEGIN


	LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm_cust_info.csv'
	INTO TABLE bronze.crm_custo_info
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	TRUNCATE TABLE bronze.crm_prd_info;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
	INTO TABLE bronze.crm_prd_info
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	TRUNCATE TABLE bronze.crm_sales_details;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
	INTO TABLE bronze.crm_sales_details
	FIELDS TERMINATED BY ',' 
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	TRUNCATE TABLE bronze.erp_cust_az12;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
	INTO TABLE bronze.erp_cust_az12
	FIELDS TERMINATED BY ',' 
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	TRUNCATE TABLE bronze.erp_loc_a101o;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
	INTO TABLE bronze.erp_loc_a101
	FIELDS TERMINATED BY ',' 
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
	INTO TABLE bronze.erp_px_cat_g1v2
	FIELDS TERMINATED BY ',' 
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	SELECT
	  LOAD_FILE('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv');
END$$

DELIMITER ;
