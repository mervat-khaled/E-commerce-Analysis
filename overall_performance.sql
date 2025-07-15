
USE mavenfuzzyfactory;


 SELECT records, count(*)
    FROM
    (
        SELECT user_id, count(*) as records
        FROM orders
        GROUP BY 1
)a
 GROUP BY 1
;

-- 
-- -- -- -- 
/*  EXPLOAR EACH TABLE COL DISTINCT VALUES  */

SELECT * FROM website_pageviews LIMIT 10;

SELECT DISTINCT
    pageview_url, COUNT(pageview_url) AS value_count
FROM
    website_pageviews
GROUP BY pageview_url
ORDER BY value_count DESC;


#===========================================================


#What is the  product return rate  over the time with total refund amount?
 
SELECT 
 YEAR( o.created_at) AS year,
 ROUND(SUM(oir.refund_amount_usd),-3) AS total_refund_amount_usd,
    ROUND(COUNT(DISTINCT oir.order_id) / COUNT(o.order_id) * 100,
            2) AS return_rate
            FROM
            orders o
    
        LEFT JOIN order_item_refunds oir
    ON   o.order_id  = oir.order_id
    WHERE YEAR(o.created_at) != 2015
GROUP BY year
ORDER BY year
;



#SUM of sessions and orders by year and quarter

SELECT  YEAR(ws.created_at) as year,quarter(ws.created_at) as quarter, ROUND(COUNT(DISTINCT ws.website_session_id),-3)as number_of_sessions,

ROUND(COUNT(DISTINCT o.order_id),-2) as number_of_orders
FROM website_sessions ws
LEFT JOIN orders o ON o.website_session_id = ws.website_session_id
where YEAR(ws.created_at) != 2015 
GROUP BY 1,2
ORDER BY 1;



#From which campaign came the most sessions and orders?

SELECT  * FROM website_sessions LIMIT 10;

SELECT  YEAR(ws.created_at) as year,quarter(ws.created_at) as quarter ,utm_campaign, ROUND(COUNT(DISTINCT ws.website_session_id))as number_of_sessions,

ROUND(COUNT(DISTINCT o.order_id)) as number_of_orders
FROM website_sessions ws
LEFT JOIN orders o ON o.website_session_id = ws.website_session_id
where YEAR(ws.created_at) != 2015 AND utm_campaign  IN ('nonbrand','brand')
GROUP BY 1,2,3
ORDER BY 1;


#From which source came the most sessions and orders?


SELECT  YEAR(ws.created_at) as year,quarter(ws.created_at) as quarter ,utm_source, ROUND(COUNT(DISTINCT ws.website_session_id))as number_of_sessions,

ROUND(COUNT(DISTINCT o.order_id)) as number_of_orders
FROM website_sessions ws
LEFT JOIN orders o ON o.website_session_id = ws.website_session_id
where YEAR(ws.created_at) != 2015 AND utm_source  IN ('gsearch','bsearch')
GROUP BY 1,2,3
ORDER BY 1;


# what is the company performance over the time? for this quetsion We wiil check the total revenue and the conversion rate

-- 
SELECT 
    YEAR(ws.created_at) AS year,
    quarter(ws.created_at) as quarter,
    ROUND(SUM(o.price_usd),-3) AS total_revenue,
    ROUND(COUNT(DISTINCT o.order_id) / 
              COUNT(DISTINCT ws.website_session_id) *100,2 )as conversion_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_idutm_content
    WHERE YEAR(ws.created_at) != 2015
GROUP BY 1,2
ORDER BY min(ws.created_at) 
;


# Gross Profit Margin: over years
SELECT 
     year,
(total_sales - total_cost) * 100 / total_sales as Gross_Profit_Margin
     
     
FROM
    (SELECT YEAR(created_at) AS year,SUM(items_purchased*cogs_usd) as total_cost,
    SUM(items_purchased * price_usd) as total_sales
    FROM orders
  group by 1 )  as a
WHERE year != 2015
;
