# E-commerce SQL Analysis

## Project Overview

This project presents an end-to-end e-commerce data analysis using SQL Server.

The objective is to analyze sales performance, customer behavior, product performance, seller performance, payment behavior, delivery efficiency, and customer satisfaction using a relational database containing multiple connected tables.

The project demonstrates practical SQL skills across data exploration, data quality checks, joins, aggregations, window functions, CTEs, time-based analysis, segmentation, and business reporting.

---

## Tools Used

- SQL Server
- SQL Server Management Studio (SSMS)

---

## Database Structure

The project uses multiple relational tables:

- customers
- orders
- order_items
- products
- sellers
- payments
- order_reviews
- geolocation
- category

These tables are connected through keys such as:

- customer_id
- order_id
- product_id
- seller_id

---

## SQL Skills Applied

- select statements
- joins
- aggregate functions
- group by
- distinct
- case statements
- date functions
- datediff
- datetrunc
- common table expressions (CTEs)
- window functions
- rank()
- lag()
- ntile()
- running totals
- year-over-year analysis
- month-over-month analysis
- customer segmentation
- RFM analysis
- part-to-whole analysis
- business reporting

---

## Project Analysis

### 1. Database Exploration

The first stage focused on understanding the structure of the database and the relationships between the different tables.

The analysis included:

- Exploring available tables and columns
- Counting rows across tables
- Identifying the overall date range
- Understanding the grain of each table
- Reviewing the main relationships between customers, orders, products, sellers, payments, and reviews

---

### 2. Data Quality

Data quality checks were performed before starting the analysis.

The checks included:

- Duplicate IDs
- Missing values
- Invalid or negative price values
- Invalid payment values
- Invalid order and delivery dates
- Review scores outside the expected range

---

### 3. Dimension Exploration

The main categorical dimensions were explored to understand how the business data could be segmented.

Dimensions included:

- Order Status
- Customer State
- Customer City
- Seller State
- Seller City
- Product Category
- Payment Type
- Review Score

---

### 4. Measures Exploration

High-level business metrics were calculated, including:

- Total Orders
- Total Customers
- Total Products
- Total Sellers
- Total Items
- Total Sales
- Total Freight
- Total Payment Value
- Average Item Price
- Average Review Score
- Average Delivery Time

---

### 5. Sales Analysis

Sales performance was analyzed across multiple dimensions.

The analysis included:

- Sales by Product Category
- Sales by Customer State
- Sales by Seller State
- Sales by Payment Type
- Monthly Sales
- Yearly Sales
- Average Payment Installments

---

### 6. Ranking Analysis

Ranking analysis was used to identify the strongest performers across the business.

The analysis included:

- Top 10 Products by Sales
- Top 10 Categories by Sales
- Top 10 Sellers by Sales
- Top 10 Customers by Spending
- Category Sales Ranking
- Seller Sales Ranking

The `rank()` window function was used to generate performance rankings.

---

### 7. Change Over Time Analysis

Sales performance was analyzed over time to identify business trends.

The analysis included:

- Monthly Sales
- Monthly Customers
- Monthly Average Order Value
- Yearly Sales

---

### 8. Year-over-Year Growth

CTEs and the `lag()` window function were used to compare yearly sales with the previous year.

The analysis calculates:

- Current Year Sales
- Previous Year Sales
- Year-over-Year Growth Percentage

Formula:

YoY Growth (%) =  
(Current Year Sales - Previous Year Sales) / Previous Year Sales × 100

---

### 9. Month-over-Month Growth

Monthly sales were compared with the previous month using the `lag()` window function.

The analysis calculates:

- Current Month Sales
- Previous Month Sales
- Sales Difference
- Month-over-Month Growth Percentage

Formula:

MoM Growth (%) =  
(Current Month Sales - Previous Month Sales) / Previous Month Sales × 100

---

### 10. Cumulative Analysis

Running totals were calculated to understand how sales accumulated over time.

The analysis included:

- Monthly Sales
- Cumulative Sales

---

### 11. Customer Analysis

A customer-level analysis was created to evaluate customer behavior and value.

The analysis included:

- Total Orders
- Total Spending
- Average Order Value
- First Order Date
- Last Order Date
- Customer Lifetime
- Customer Ranking

---

### 12. RFM Customer Segmentation

Customers were analyzed using the RFM framework:

- Recency
- Frequency
- Monetary Value

RFM scores were created using `ntile()` window functions to support customer segmentation and identify high-value customers.

---

### 13. Product Analysis

Product-level performance was analyzed using:

- Total Orders
- Total Items
- Total Sales
- Average Price
- Total Freight
- Product Sales Ranking

---

### 14. Seller Analysis

Seller performance was analyzed using:

- Total Orders
- Total Sales
- Average Item Price
- Total Freight
- Seller Ranking

---

### 15. Payment Analysis

Payment behavior was analyzed across different payment methods.

The analysis included:

- Payment Type
- Number of Orders
- Total Payment Value
- Average Payment Value
- Average Number of Installments

---

### 16. Review Analysis

Customer satisfaction was analyzed using review scores.

The analysis included:

- Review Score Distribution
- Average Review Score
- Average Review Score by Product Category

---

### 17. Logistics Analysis

Delivery and logistics performance were analyzed using order timestamps.

The analysis included:

- Average Delivery Time
- On-Time vs Late Deliveries
- Delivery Performance by Customer State
- Delivery Performance vs Customer Review Score

---

### 18. Part-to-Whole Analysis

The contribution of each product category to total sales was calculated using window functions.

This analysis helps identify which categories contribute the largest share of business revenue.

---

### 19. Performance Analysis

Seller performance was compared with average seller sales.

Sellers were classified as:

- Above Average
- Average
- Below Average

---

### 20. Final Business Reports

Final reporting layers were created for:

- Customers
- Products
- Sellers

These reports summarize key business metrics and rankings at the entity level.

---

## Key Business Questions

This project answers questions such as:

- Which product categories generate the highest sales?
- Which customers contribute the most revenue?
- Which sellers perform best?
- How are sales changing over time?
- What is the YoY and MoM growth?
- Which payment types are most frequently used?
- How long does delivery typically take?
- What percentage of orders are delivered late?
- Does late delivery affect customer review scores?
- Which customer states generate the highest sales?
- Which customers are high-value based on RFM behavior?
- Which categories contribute the largest share of total sales?

---

## Key Insights

- São Paulo (SP) was the highest-performing customer state, generating approximately **5.20M** in sales.
- Health & Beauty (`beleza_saude`) was the best-selling product category, generating approximately **1.26M** in sales.
- The highest-performing seller generated approximately **229.47K** in total sales.
- The highest-value customer generated approximately **13.44K** in total spending.
- Credit Card was the most frequently used payment method, appearing across **76,505 orders**.
- The overall average customer review score was **4.09 out of 5**.
- Average delivery time was approximately **12.5 days**.
- **91.89%** of delivered orders arrived on time, while **8.11%** were delivered late.
- On-time deliveries had an average review score of **4.29**, compared with only **2.57** for late deliveries.
- Delivery reliability appears to be strongly associated with customer satisfaction, with late deliveries showing substantially lower review scores.

---

## Project Structure

```text
ecommerce-sql-analysis
│
├── ecommerce_analysis.sql
├── README.md
├── data
│   └── ecommerce_dataset.csv
└── screenshots
    └── project_preview.png
