--CREATE DATABASE DataBank;
USE DataBank;

CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(9)
);

CREATE TABLE customer_nodes (
    customer_id INT,
    region_id INT,
    node_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

CREATE TABLE customer_transactions (
    customer_id INT,
    txn_date DATE,
    txn_type VARCHAR(10),
    txn_amount INT
);

INSERT INTO regions (region_id, region_name) VALUES
(1, 'Australia'),
(2, 'America'),
(3, 'Africa'),
(4, 'Europe'),
(5, 'Asia');

INSERT INTO customer_nodes (customer_id, region_id, node_id, start_date, end_date) VALUES
(1, 3, 4, '2020-01-02', '2020-01-03'),
(2, 3, 5, '2020-01-03', '2020-01-17'),
(3, 5, 4, '2020-01-27', '2020-02-18'),
(4, 5, 4, '2020-01-07', '2020-01-19'),
(5, 3, 3, '2020-01-15', '2020-01-23'),
(1, 3, 2, '2020-01-04', '2020-01-14'),
(2, 3, 3, '2020-01-18', '2020-02-01'),
(3, 5, 2, '2020-02-19', '2020-03-16'),
(4, 5, 1, '2020-01-20', '2020-01-29'),
(5, 3, 2, '2020-01-24', '2020-01-26'),
(1, 3, 5, '2020-01-15', '9999-12-31'), -- Active node placeholder
(2, 3, 5, '2020-02-02', '9999-12-31'),
(3, 5, 5, '2020-03-17', '9999-12-31'),
(4, 5, 2, '2020-01-30', '9999-12-31'),
(5, 3, 4, '2020-01-27', '9999-12-31');


INSERT INTO customer_transactions (customer_id, txn_date, txn_type, txn_amount) VALUES
(1, '2020-01-02', 'deposit', 312),
(2, '2020-01-03', 'deposit', 450),
(3, '2020-01-27', 'deposit', 220),
(4, '2020-01-07', 'deposit', 650),
(5, '2020-01-15', 'deposit', 800),
(1, '2020-01-05', 'withdrawal', 100),
(2, '2020-01-20', 'purchase', 150),
(3, '2020-02-10', 'withdrawal', 50),
(4, '2020-01-25', 'purchase', 200),
(5, '2020-01-22', 'withdrawal', 300),
(1, '2020-01-28', 'purchase', 85),
(2, '2020-02-15', 'deposit', 300),
(3, '2020-03-05', 'purchase', 120),
(4, '2020-02-11', 'deposit', 150),
(5, '2020-02-05', 'deposit', 250);

SELECT * FROM regions;

--A part
--Q1
SELECT COUNT(DISTINCT node_id) AS unique_nodes_count 
FROM customer_nodes;
--Q2
SELECT r.region_name, COUNT(DISTINCT cn.node_id) AS nodes_per_region
FROM customer_nodes cn
JOIN regions r ON cn.region_id = r.region_id
GROUP BY r.region_name;
--Q3
SELECT r.region_name, COUNT(DISTINCT cn.customer_id) AS customer_count
FROM customer_nodes cn
JOIN regions r ON cn.region_id = r.region_id
GROUP BY r.region_name;
--Q4
SELECT AVG(DATEDIFF(day, start_date, end_date)) AS avg_reallocation_days
FROM customer_nodes
WHERE end_date != '9999-12-31';
--Q5
WITH node_durations AS (
    SELECT 
        r.region_name,
        DATEDIFF(day, cn.start_date, cn.end_date) AS duration
    FROM customer_nodes cn
    JOIN regions r ON cn.region_id = r.region_id
    WHERE cn.end_date != '9999-12-31'
)
SELECT DISTINCT
    region_name,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY region_name) AS median_days,
    PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY region_name) AS percentile_80_days,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY region_name) AS percentile_95_days
FROM node_durations;

--B Part
--1.
SELECT 
    txn_type,
    COUNT(*) AS unique_transaction_count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

--2.
WITH customer_deposit_summary AS (
    SELECT 
        customer_id,
        COUNT(*) AS deposit_count,
        SUM(txn_amount) AS total_deposit_amount
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)
SELECT 
    AVG(deposit_count) AS avg_historical_deposit_count,
    AVG(total_deposit_amount) AS avg_historical_deposit_amount
FROM customer_deposit_summary;
--3.
WITH monthly_customer_activity AS (
    SELECT 
        customer_id,
        DATEPART(month, txn_date) AS month_number,
        DATENAME(month, txn_date) AS month_name,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
    FROM customer_transactions
    GROUP BY customer_id, DATEPART(month, txn_date), DATENAME(month, txn_date)
)
SELECT 
    month_number,
    month_name,
    COUNT(DISTINCT customer_id) AS active_customer_count
FROM monthly_customer_activity
WHERE deposit_count > 1 
  AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY month_number, month_name
ORDER BY month_number;