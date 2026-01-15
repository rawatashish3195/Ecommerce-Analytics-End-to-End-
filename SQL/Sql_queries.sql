-- =====================================
-- DATABASE & TABLE CREATION
-- =====================================

CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =====================================
-- SAMPLE DATA INSERTION
-- =====================================

INSERT INTO customers VALUES
(1, 'Amit Sharma', 'Delhi', '2024-01-10'),
(2, 'Neha Verma', 'Mumbai', '2024-02-15'),
(3, 'Rahul Singh', 'Bangalore', '2024-03-05'),
(4, 'Pooja Mehta', 'Delhi', '2024-03-20');

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000.00),
(102, 'Headphones', 'Electronics', 2000.00),
(103, 'Office Chair', 'Furniture', 7000.00),
(104, 'Smartphone', 'Electronics', 30000.00);

INSERT INTO orders VALUES
(1001, 1, '2024-04-01', 'Delivered'),
(1002, 2, '2024-04-03', 'Delivered'),
(1003, 1, '2024-04-05', 'Cancelled'),
(1004, 3, '2024-04-10', 'Delivered');

INSERT INTO order_items VALUES
(1, 1001, 101, 1),
(2, 1001, 102, 2),
(3, 1002, 104, 1),
(4, 1004, 103, 1);

-- =====================================
-- KPI 1: TOTAL REVENUE (DELIVERED ORDERS)
-- =====================================

SELECT 
    SUM(oi.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered';

-- =====================================
-- KPI 2: TOP 3 CUSTOMERS BY REVENUE
-- =====================================

WITH customer_revenue AS (
    SELECT 
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_revenue
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_name
)
SELECT customer_name, total_revenue
FROM (
    SELECT 
        customer_name,
        total_revenue,
        DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS rnk
    FROM customer_revenue
) ranked_customers
WHERE rnk <= 3;

-- =====================================
-- KPI 3: REPEAT VS ONE-TIME CUSTOMERS
-- =====================================

WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM customer_orders
GROUP BY customer_type;

-- =====================================
-- KPI 4: MONTHLY REVENUE TREND
-- =====================================

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * p.price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY month
ORDER BY month;
