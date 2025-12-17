# Data Warehouse and Analytics Project

Welcome toe the **Data Warehouse and Analytics Project** repository! 🤠
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as portfolio project,
highlights industry best practices in data engineering and analytics. 

------------

## Project Requirements 

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using MySQL to consolidate sale data, enabling analytical reportin and informed decision-making. 

#### Specifications
- **Data Sources** : Import data from two sources systems (ERP and CRM) provided as CVS files.
- **Data Quality** : Cleanse and resolve data quality issues prior to analysis.
- **Integration** : Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope** : Focus on the latest dataset only; historization of data is not required.
- **Documentation** : Provide clear documentation of the data model to support both business steakholder and analytics teams.

------------


💡 Implementation Notes & Lessons Learned
Database Engine: MySQL 8.0

While this script is implemented in MySQL, it is important to note the architectural trade-offs:

Procedures: Although MySQL supports stored procedures, the implementation of complex ETL logic and error handling is much more robust in SQL Server (T-SQL).

Performance: For large-scale data warehousing, SQL Server’s integration services and advanced indexing often provide better performance for "Bronze to Silver" transformations.

Project Context: This script serves as a functional demonstration of the Medallion Architecture. 
In a production enterprise environment, I would recommend migrating this logic to SQL Server to leverage advanced logging, TRY-CATCH blocks, and automated job scheduling.

------------

### BI: Analytics and Reporting (Data Analytics)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
-  **Product Performance**
-   **Sales Trends**

  These insights empower steakholder with key business metrics, enabling strategic decision-making.

------------

## ⛊ License

This project is licensed under the [MIT License](License). You are free to use, modify, and share this project with proper attribution.

## ⭐ About

Hello There! I am **Dawid**, an aspiring Data Engineer. This is my first Data Engineering project, created as part of my portfolio.

My goal is to continuously improve my skills and start my career as a Data Engineer.













