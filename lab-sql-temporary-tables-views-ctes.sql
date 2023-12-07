# LAB | Temporary Tables, Views and CTEs

-- Create and use Temporary Tables, Views and Common Table Expressions (CTEs) in SQL to simplify complex queries and improve query performance.

## Introduction

-- Welcome to the Temporary Tables, Views and CTEs lab!
-- In this lab, you will be working with the [Sakila](https://dev.mysql.com/doc/sakila/en/) database on movie rentals. The goal of this lab is to help you practice and gain proficiency in using views, CTEs, and temporary tables in SQL queries.
-- Temporary tables are physical tables stored in the database that can store intermediate results for a specific query or stored procedure. Views and CTEs, on the other hand, are virtual tables that do not store data on their own and are derived from one or more tables or views. They can be used to simplify complex queries. Views are also used to provide controlled access to data without granting direct access to the underlying tables.
-- Through this lab, you will practice how to create and manipulate temporary tables, views, and CTEs. By the end of the lab, you will have gained proficiency in using these concepts to simplify complex queries and analyze data effectively.

## Challenge

-- **Creating a Customer Summary Report**

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.
USE sakila;
# - Step 1: Create a View
#First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_information AS (
	SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS "rental_count"
    FROM customer c
    JOIN rental r ON r.customer_id = c.customer_id
    GROUP BY 1, 2, 3
    );

# - Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 
# to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS (
	SELECT cri.customer_id, sum(p.amount) AS "total_amount_paid"
    FROM customer_rental_information cri
    JOIN payment p ON cri.customer_id = p.customer_id
    GROUP BY 1
    );

# - Step 3: Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 
WITH customer_summary_report AS (
	SELECT cri.customer_id, cri.first_name, cri.email, cri.rental_count, cps.total_amount_paid
	FROM customer_rental_information cri
	JOIN customer_payment_summary cps ON cps.customer_id = cri.customer_id
)
SELECT first_name, email, rental_count, total_amount_paid
FROM customer_summary_report;


#Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH customer_summary_report AS (
	SELECT cri.customer_id, cri.first_name, cri.email, cri.rental_count, cps.total_amount_paid
	FROM customer_rental_information cri
	JOIN customer_payment_summary cps ON cps.customer_id = cri.customer_id
)
SELECT 
	first_name, 
	email, 
    rental_count, 
    total_amount_paid, 
    total_amount_paid/rental_count AS 'average_payment_per_rental'
FROM customer_summary_report
GROUP BY 1,2,3,4;