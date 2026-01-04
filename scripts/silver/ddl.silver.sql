## 🥈 Silver Layer – Data Cleansing & Transformation

The Silver Layer is responsible for cleansing, standardizing, and deduplicating data
ingested from the Bronze Layer.  
Data in this layer is prepared for analytical modeling and consumption in the Gold Layer.

The Silver Layer applies business logic, data validation, and data quality corrections
to ensure reliable and consistent datasets.

---

CREATE PROCEDURE silver.load_silver()
BEGIN

TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE
	WHEN UPPER(TRIM(cst_marital_status)) = "S" THEN "Single"
    WHEN UPPER(TRIM(cst_marital_status)) = "M" THEN "Married"
    ELSE "n/a"
END AS cst_marital_status,
CASE
	WHEN UPPER(TRIM(cst_gndr)) = "F" THEN "female"
    WHEN UPPER(TRIM(cst_gndr)) = "M" THEN "Male"
    ELSE "n/a"
END AS cst_gndr,
cst_create_date
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;


TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
    prd_id,
    cast_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    COALESCE(
        CAST(NULLIF(TRIM(prd_cost), '') AS DECIMAL(10,2)),
        0
    ) AS prd_cost,
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        DATE_SUB(
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
            INTERVAL 1 DAY
        ) AS DATE
    ) AS prd_end_dt
FROM bronze.crm_prd_info;

TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
    sls_prd_key,
    sls_cust_id ,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
    )
    
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
END AS sls_due_dt,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
from bronze.crm_sales_details;

TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (
cid,
bdate,
gen
)
SELECT 
-- We removed first 3 string value to conect a keys
CASE WHEN cid LIKE "NAS%" THEN SUBSTRING(cid, 4, LENGTH(cid))
	ELSE cid
END cid,
-- case for a birthday in the future to not have it.
CASE WHEN bdate > CURDATE() THEN NULL
	ELSE bdate
END AS bdate,
-- Data normalization, by maping and put more friendly value.
CASE WHEN UPPER(TRIM(gen)) IN ("F", "FEMALE") THEN "Female"
	WHEN UPPER(TRIM(gen)) IN ("M", "MALE") THEN "Male"
    ELSE "n/a"
END AS gen
FROM bronze.erp_cust_az12;

TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101
(cid, centry)
SELECT
REPLACE(cid, "-", "") cid,
CASE WHEN TRIM(cntry) = "DE" Then "Germany"
	WHEN TRIM(cntry) IN ("US", "USA") Then "United States"
    WHEN TRIM(cntry) = "" or cntry IS NULL THEN "n/a"
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101; 

TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2
SELECT 
id,
cat,
subcat,
maintenance
 FROM bronze.erp_px_cat_g1v2;
 END$$

DELIMITER ;


## 🔄 ETL Process – Stored Procedure: `silver.load_silver`

The ETL process is implemented as a stored procedure and performs a full data reload
(`TRUNCATE + INSERT`) for all Silver tables.

---

### 1️⃣ `silver.crm_cust_info`
- customer deduplication using `ROW_NUMBER()`
- selection of the most recent record based on `cst_create_date`
- data normalization:
  - marital status (`S → Single`, `M → Married`)
  - gender (`F → Female`, `M → Male`)
- removal of leading and trailing spaces (`TRIM`)
- filtering out records with missing customer keys

---

### 2️⃣ `silver.crm_prd_info`
- extraction of `cat_id` and the actual `prd_key` from the product key
- product line normalization:
  - Mountain
  - Road
  - Touring
  - Other Sales
- product cost validation:
  - NULL or empty values → `0`
- derivation of product validity range:
  - `prd_end_dt` calculated using the `LEAD()` window function

---

### 3️⃣ `silver.crm_sales_details`
- date validation (expected format `YYYYMMDD`)
- conversion of invalid dates to `NULL`
- sales amount correction:
  - recalculation as `quantity * price` when source values are incorrect
- protection against division by zero using `NULLIF`

---

### 4️⃣ `silver.erp_cust_az12`
- customer key cleansing (`NASxxx → xxx`)
- validation of birth dates (future dates removed)
- gender normalization (`F/FEMALE → Female`, `M/MALE → Male`)

---

### 5️⃣ `silver.erp_loc_a101`
- customer identifier standardization
- country code mapping:
  - `DE → Germany`
  - `US / USA → United States`
- handling of missing or empty values (`n/a`)

---

### 6️⃣ `silver.erp_px_cat_g1v2`
- direct load of reference data without transformation
- table used as a lookup dimension in downstream layers

---

## ✅ Silver Layer – Summary
- cleansed and standardized data
- applied business rules and validations
- consistent and reliable data types
- prepared for fact and dimension modeling in the Gold Layer
