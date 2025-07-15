
USE mavenfuzzyfactory;

SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

/* In this analysis, we will try to answer the question Of where potential customers came from. */

#exploar tables
SHOW TABLES;

DESCRIBE website_pageviews;
DESCRIBE website_sessions;

SELECT pageview_url , COUNT(*) as value_count
FROM website_pageviews 
GROUP BY 1;

SELECT utm_campaign , COUNT(*) as value_count
FROM website_sessions
GROUP BY 1;

SELECT utm_source, COUNT(*) as value_count
FROM website_sessions
GROUP BY 1;


SELECT device_type, COUNT(*) as value_count
FROM website_sessions
GROUP BY 1;

/* Q: Is repeat customer a potintial more likely to buy a product?!*/

SELECT YEAR(ws.created_at) as year, 
              is_repeat_session2,
              COUNT(is_repeat_session2) As number_of_sessions,
              ROUND(COUNT(DISTINCT o.order_id) / 
              COUNT(DISTINCT ws.website_session_id) *100,2 )as conversion_rate
FROM
    website_sessions ws 
         Left  JOIN orders o
     ON  ws.website_session_id = o.website_session_id 
     WHERE YEAR(ws.created_at) != 2015
GROUP BY 1,2
;


#portion of revenue from repeated customers and new ones, over years.. 


WITH total_sales_by_years as 
 (SELECT revenue_year,
               is_repeat_session2,
              ROUND(SUM(o.price_usd))total_revenue
FROM
    website_sessions ws 
         JOIN orders o
     ON  ws.website_session_id = o.website_session_id
     GROUP BY 1,2
     ORDER BY 1
    ) 
SELECT 
revenue_year,
               is_repeat_session2,
               total_revenue,
               total_revenue / sum(total_revenue) over (partition by revenue_year) as portion_Of_revenue
               
FROM 
total_sales_by_years
WHERE  revenue_year != 2015

GROUP BY 1,2
ORDER BY 1;



#Comparing AVERGE ORDER VALUE (AOV)  For Repeated Customers and New Customers BY QUARTER AND YEARS .. 


WITH AOV as 
 (SELECT 
				  YEAR(o.created_at) year,
                  QUARTER(o.created_at) quarter,
               is_repeat_session2,
              ROUND(COUNT(DISTINCT o.order_id)) total_orders,
              ROUND(SUM(o.price_usd))total_revenue
FROM
    website_sessions ws 
         JOIN orders o
     ON  ws.website_session_id = o.website_session_id
     
     GROUP BY 1,2,3
     ORDER BY 1
    ) 
SELECT 
         
          year,
          quarter,
               is_repeat_session2,
               total_revenue/ total_orders  as AOV
               
FROM 
AOV
WHERE year != 2015
GROUP BY 1,2,3
ORDER BY 1;

#Retention RATE..USER ENGAGMENT BASED ON FIRST SESSION..


SELECT first_term,
Period,
first_value(cohort_retained) over (partition by first_term order by period) as cohort_size,
cohort_retained,
cohort_retained *1.0  / 
first_value(cohort_retained) over (partition by first_term order by period) as percentage_retained
FROM(SELECT a.first_term, Coalesce(a.end_term - a.first_term,0) AS Period,
            COUNT(DISTINCT a.user_id) AS cohort_retained
FROM(
 SELECT user_id, min(YEAR(created_at)) as first_term,
                               max(YEAR(created_at)) as end_term
 
            FROM website_sessions
            GROUP BY 1) a
JOIN website_sessions b on a.user_id = b.user_id
WHERE first_term != 2015
GROUP BY 1,2
            )aa
;

#Comparing Conversion Rate for Campaigns 

SELECT  YEAR(ws.created_at) as year ,utm_campaign AS Campaigns, 
ROUND(COUNT(DISTINCT o.order_id) / 
              COUNT(DISTINCT ws.website_session_id) *100,2 )as conversion_rate
FROM website_sessions ws
LEFT JOIN orders o ON o.website_session_id = ws.website_session_id
where YEAR(ws.created_at) != 2015 AND utm_campaign  IN ('nonbrand','brand')
GROUP BY 1,2
ORDER BY 1;

