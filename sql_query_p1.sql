-- ==========================================
-- Retail Sales Analysis SQL Project
-- Author: Fatima Zehra
-- Database: PostgreSQL
-- ==========================================

-- 1. Database Setup

CREATE DATABASE sql_project_p1;

-- CREATE TABLE

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE 
		retail_sales(
			transactions_id INT PRIMARY KEY,
			sale_date DATE,
			sale_time TIME,
			customer_id INT,
			gender VARCHAR(15),
			age INT,
			category VARCHAR(15),
			quantity INT,
			price_per_unit FLOAT,
			cogs FLOAT,
			total_sale FLOAT
);

-- DATA PREVIEW
SELECT
	* 
FROM retail_sales
LIMIT 15;

-- COUNT TOTAL ROWS
SELECT 
	COUNT(*)
FROM retail_sales;

-- =============================================================================
-- 2. NULL VALUE CHECK:
-- CHECK FOR ANY NULL VALUES IN THE DATASET AND DELETE RECORDS WITH MISSING DATA.
-- =============================================================================

SELECT
	*
FROM
	retail_sales
WHERE
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;
	
-- ==========================================
-- 3. DATA CLEANING - DELETING NULL VALUES
-- ==========================================

DELETE FROM retail_sales
WHERE
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;


-- ==========================================
-- 4. DATA EXPLORATION
-- ==========================================

-- 1. How many sales we have?
SELECT 
	COUNT(*) AS total_sales 
FROM retail_sales;

-- 2. How many customer we have?
SELECT 
	COUNT(DISTINCT customer_id) AS total_customer
FROM retail_sales;

-- Category Count: Identify all unique product categories in the dataset.

SELECT 
	DISTINCT category 
FROM retail_sales;


-- ==========================================
-- 5. BASIC SQL ANALYSIS
-- ==========================================

-- Question 1:
 -- Write a SQL query to determine the total number of sales transactions in the dataset.

SELECT COUNT(*) AS total_transaction FROM  retail_sales;

-- Question 2:
-- Write a SQL query to find the total number of unique customers who made purchases.

SELECT COUNT(DISTINCT customer_id) AS total_customer
FROM retail_sales;

-- Question 3:
-- Write a SQL query to calculate the total revenue generated from all sales transactions.

SELECT SUM(total_sale) AS total_revenue
FROM retail_sales;

-- Question 4:
-- Write a SQL query to identify the product category that generated the highest total revenue.

SELECT category, SUM(total_sale) AS highest_revenue
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Question 5:
-- Write a SQL query to calculate the average transaction value across all sales.

SELECT ROUND(AVG(total_sale)::numeric,2) AS avg_transaction_value
FROM retail_sales;

-- ==========================================
-- 5. INTERMEDIATE SQL ANALYSIS
-- ==========================================

-- Question 6:
-- Write a SQL query to determine the month that generated the highest total revenue in 2023.

SELECT 
	EXTRACT(MONTH FROM sale_date ) AS month,
	-- EXTRACT(YEAR FROM sale_date ) AS year,
	SUM(total_sale) AS revenue
FROM retail_sales
WHERE EXTRACT(YEAR FROM sale_date )= '2023'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Question 7:
-- Write a SQL query to identify which gender contributed the most to overall sales revenue.
SELECT 
	gender,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;


-- Supporting Analysis:
-- What is the minimum and maximum age of customers in the dataset?
SELECT 
	Min(age), 
	max(age) 
FROM retail_sales;

-- Question 8:
-- Write a SQL query to determine which customer age group generated the highest total sales revenue.
SELECT 
	CASE 
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 45 THEN '36-45'
		WHEN age BETWEEN 46 AND 55 THEN '46-55'
		ELSE '56+'
	END AS age_grp,
	SUM(total_sale)
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;


-- Question 9:
-- Write a SQL query to identify the product category that generated the highest total profit.

SELECT category ,
	SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Question 10:
-- Write a SQL query to calculate the average sales amount for each month and identify the month with the highest average sale in each year.
SELECT * FROM retail_sales;

SELECT 
	month, 
	year, 
	avg_sale
FROM 
(   
	SELECT 
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(Year FROM sale_date) as year,
		AVG(total_sale) avg_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank_year
	FROM retail_sales
	GROUP BY 1, 2
	-- Limit 1
) as t1
WHERE rank_year = 1;

-- Question 11:
-- Write a SQL query to identify the top 10 customers based on their total spending.

SELECT 
	customer_id,
	SUM(total_sale) AS top_customers
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Question 12:
-- Write a SQL query to rank product categories based on the total revenue they generated.

SELECT 
	category,
	SUM(total_sale) AS revenue,
	RANK() OVER(ORDER BY SUM(total_sale) DESC) AS category_rkn
FROM retail_sales
GROUP BY 1;

-- ==========================================
-- 7. ADVANCED SQL ANALYSIS
-- ==========================================

-- Question 13:
-- Write a SQL query to calculate month-over-month (MoM) revenue growth percentage by comparing each month's revenue with the previous month.

WITH monthly_sales AS( 
SELECT 
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY 1, 2
),

sales_growth AS (
SELECT 
	month,
	year,
	revenue,
	LAG(revenue) OVER(
		ORDER BY year, month
	) AS prev_revenue
FROM monthly_sales
)
SELECT 
	month,
	year, 
	revenue,
	prev_revenue,
	ROUND(
		(
			(revenue - prev_revenue )
			/ prev_revenue * 100)::NUMERIC,
		2
	) AS growth_percentage
FROM sales_growth;



-- Question 14:
-- Write a SQL query to identify high-value customers whose total spending exceeds the average customer spending.

WITH customer_sales AS ( 
SELECT 
	distinct customer_id,
	SUM(total_sale) AS spending
FROM retail_sales
GROUP BY 1
order by 2 desc
)

SELECT *
FROM customer_sales 
WHERE spending > ( 
	SELECT 
		AVG(spending)
	FROM customer_sales
	);

-- Question 15:
-- Write a SQL query to calculate the cumulative (running total) revenue over time.

SELECT 
	sale_date,
	SUM(total_sale) AS daily_sales,
	SUM(SUM(total_sale))OVER(
		ORDER BY sale_date 
	)AS running_total
FROM retail_sales
GROUP BY 1;



-- Question 16:
-- Write a SQL query to determine the percentage contribution of the top 10 customers to total sales revenue.

WITH top_10_customer AS(
	SELECT
		customer_id,
		SUM(total_sale) AS customer_total_sale
	FROM retail_sales
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10
),

overall_sale AS(
	SELECT
		SUM(total_sale) AS total_sale
	FROM retail_sales
)

SELECT 
	ROUND((SUM(t.customer_total_sale) * 100 / o.total_sale)::NUMERIC ,2)
	AS top_10_customer_percentage
FROM top_10_customer AS t
CROSS JOIN overall_sale AS o
GROUP BY o.total_sale;

--==============================
-- 			End Project
--==============================	















