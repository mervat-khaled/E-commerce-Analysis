USE mavenfuzzyfactory;

# I want to know the price of each product


SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

SELECT
          distinct(o.price_usd), p.product_id, p.product_name
        FROM
        products p
        JOIN
            orders o ON p.product_id = o.primary_product_id
where o.items_purchased = 1
group by p.product_id
ORDER BY o.price_usd DESC; 

/* Which products are bringing in the most money? */

SELECT  p.product_id,
p.product_name,
ROUND(sum(o.price_usd),-3) AS product_total_revenue, #round to the nearest thousand
ROUND(sum(o.items_purchased),-3) AS total_items_pruchased,

ROUND((sum(o.items_purchased) / 
(SELECT SUM(items_purchased)FROM orders)),2)* 100 as product_share_percentage_byQuantity,
ROUND((sum(o.price_usd) / 
(SELECT SUM(price_usd)FROM orders)),2)* 100 as product_share_percentage_byPrice
FROM
  products p
 JOIN
order_items  oir ON p.product_id = oir.product_id

Join orders o on o.order_id = oir.order_id
WHERE YEAR(o.created_at) != 2015
GROUP BY p.product_name
ORDER BY  product_total_revenue DESC ;

#What is the  product return rate and total refund amount?
 
 SELECT  * FROM order_item_refunds LIMIT 5;
 
SELECT 
p.product_id,
p.product_name,
 ROUND(SUM(oir.refund_amount_usd),-3) AS total_refund_amount,
    ROUND(COUNT(DISTINCT oir.order_id) / COUNT(o.order_id) * 100,
            2) AS products_rutern_rate
            FROM
  products p
 JOIN
order_items oi ON p.product_id = oi.product_id

JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN order_item_refunds oir
    ON   o.order_id  = oir.order_id 
WHERE YEAR(o.created_at) != 2015
GROUP BY 2
ORDER BY products_rutern_rate DESC
; 



-- SELECT * FROM products;
-- 
-- CREATE TABLE RELEASEInterval AS
-- SELECT p.product_id, p.product_name ,o.*,
--  
-- CASE 
-- WHEN o.created_at BETWEEN '2012-03-19' AND '2013-01-06' THEN 'P1'
-- WHEN o.created_at BETWEEN '2013-01-06' AND '2013-12-12' THEN 'P2' 
-- WHEN o.created_at BETWEEN '2013-12-12' AND '2014-02-05' THEN 'P3'
-- ELSE 'p4'
-- END AS release_interval
-- FROM products p
-- Join orders o ON  p.product_id = o.primary_product_id;

ALTER TABLE orders 
ADD revenue_month VARCHAR(20),
ADD revenue_year INT,
ADD  release_interval CHAR(2);
 
 ########################################
 
UPDATE orders 
SET 
    revenue_month = (SELECT 
            MONTHNAME(created_at)
        ),
    revenue_year = (SELECT 
            YEAR(created_at)
        ),
    release_interval = CASE
        WHEN created_at BETWEEN '2012-03-19' AND '2013-01-06' THEN 'P1'
        WHEN created_at BETWEEN '2013-01-06' AND '2013-12-12' THEN 'P2'
        WHEN created_at BETWEEN '2013-12-12' AND '2014-02-05' THEN 'P3'
        ELSE 'p4'
    END;
    
    
# Sample 

SELECT * from orders 
WHERE mod(order_id,100) = 6;
 
 SELECT * from order_items 
WHERE mod(order_id,100) = 6;

SELECT COUNT(*) FROM order_items;

 SELECT * from website_pageviews
WHERE mod(website_session_id,100) = 6;

SELECT * from website_sessions
WHERE mod(website_session_id,100) = 6;
-- SELECT 
--     MONTHNAME(created_at) AS month,
--     product_name,release_interval,
--     ROUND(SUM(price_usd)*100) AS total_revenue,
--     (SUM(price_usd) / 
--     (SELECT SUM(price_usd) FROM RELEASEInterval 
--     WHERE MONTHNAME(created_at) = MONTHNAME(r.created_at))) *100 AS revenue_percentage
-- FROM
--     RELEASEInterval r
-- GROUP BY product_name, month
-- ORDER BY  min(month),revenue_percentage DESC;
-- 

-- # product seaonality
 
SELECT 
    p.product_id,
    p.product_name,
    o.revenue_month,
    ROUND(SUM(o.price_usd)*100,-3) AS total_revenue #round to the nearest thousand 
    
FROM
    orders o
     JOIN 
     order_items oi ON o.order_id = oi.order_id
     JOIN
    products  p ON  oi.product_id =p.product_id 
    

GROUP BY  p.product_name, o.revenue_month
ORDER BY  o.revenue_month;

# Gross Profit Margin for each product : over years

SELECT 
     year,
     product_name,
(total_sales - total_cost) * 100 / total_sales as Gross_Profit_Margin


FROM

(SELECT 
    YEAR(o.created_at) AS year,
    p.product_name,
    SUM(o.items_purchased*o.cogs_usd) as total_cost,
    SUM(o.items_purchased * o.price_usd) as total_sales
    
FROM
    orders o
     JOIN 
     order_items oi ON o.order_id = oi.order_id
     JOIN
    products  p ON  oi.product_id =p.product_id 
    WHERE YEAR(o.created_at) != 2015
    
GROUP BY  1,2
order by 1) as a 
;

#Product groups revenue/ items purchased over years
-- 
With  Product_group 
  AS (
    SELECT p.product_name As product_name,
                   o.revenue_year AS year,
           ROUND(SUM(o.price_usd)) AS total_revenue,
           ROUND(sum(o.items_purchased)) AS total_items_purchased
           -- ROUND(COUNT(DISTINCT o.items_purchased) / COUNT(DISTINCT ws.website_session_id) *100,
   --  2
--     ) AS conversion_rate
           
    FROM orders o
    LEFT JOIN website_sessions ws ON ws.website_session_id = o.website_session_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products  p ON  oi.product_id = p.product_id
    WHERE YEAR(o.created_at) != 2015
    GROUP BY 1, 2)

SELECT
   product_name,
	year,
    total_revenue,
    total_items_purchased,
    NTILE(3) OVER (
        PARTITION BY year
        ORDER BY total_revenue Desc)
        product_group
FROM 
    Product_group;



