USE company;

                                                    -- Funnel Analysis ( View Product → Add to Cart → Purchase)
-- Funnel Stage: Total Users -- 99941
SELECT COUNT(DISTINCT customer_id) AS total_users
FROM customers_dataset;    


-- Funnel Stage: Users who placed orders -- 99441
SELECT COUNT(DISTINCT customer_id) AS users_with_orders
FROM olist_orders_dataset;

-- Funnel Stage: Orders created -- 99441
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset;

-- Funnel Stage: Delivered Orders (FINAL STAGE) -- 96478  =>  ~97% of orders are successfully delivered
SELECT COUNT(*) AS delivered_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered';
							-- The dataset primarily contains completed transactions, so funnel drop-offs are minimal. 
							-- I shifted focus to analyzing delivery performance and customer behavior.
 
-- Query 1:- Delivery Performance
SELECT order_status, COUNT(*)     -- Insights
FROM olist_orders_dataset		  -- Delivered -> 96,478 ->	97.02% ,   Canceled -> 625 -> 0.63% ,  Unavailable -> 609 -> 0.61%
GROUP BY order_status;			  -- Shipped -> 1,107 -> 1.11%,  Invoiced -> 314 -> 0.32%, Processing -> 301 -> 0.30%


-- Query 2 :- Delivery Time Analysis  -- 12.49 days
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- Query 3 :- Repeat vs new
SELECT COUNT(*) AS repeat_users
FROM (
    SELECT 										-- Total Users: 99441
        c.customer_unique_id					-- Repeat Users: 2,997 (3.01%)
	FROM olist_orders_dataset o					-- One-time Users: 96,444 (96.99%)
    JOIN customers_dataset c 
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(o.order_id) > 1
) t;

-- Query 4 :- Revenue Analysis
SELECT SUM(oi.price) AS total_revenue        -- Total Revenue = 1,32,21,498.11
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi 
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- Query 5 :- Monthly Revenue Trend
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi 
ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;


