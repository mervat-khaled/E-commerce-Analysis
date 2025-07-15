# E-commerce Analysis With MySQL Workbench And Tableau

## About the Data:

Maven Fuzzy Factory is a fictional toy company that operates an online shop. The Database has six tables, providing information about the user's website sessions, which pages were visited, their orders, the company's products, the items ordered, and the items refunded. 

Tables are: Orders, Order_items, Order_item_refunds, Products, Website_page_views, Website_sessions). 

### Entity Relation Diagram: 
![erd1.png](erd1.png) 

### You can find the Database  [Here](https://www.kaggle.com/datasets/lenhatnam2810/mavenfuzzyfactory)

### For importing the database into MySQL workbench we have used the DDL Statements in [maven_ddl.sql](https://github.com/mervat-khaled/E-commerce-Analysis/blob/main/maven_ddl.sql) 

# GOAL
Analyze customer behavior, products, and the company's overall performance since the website launched in March 2012 to 2014. we excluded 2015  from our analysis because it only has the first quarter. 

# Tools Used
MySQL Workbench for the querying of the data.
Tableau for the visualization.

# Contents:
* Company overall performance
* Customer Behavior Analysis
* Product Analysis

## 1- Overall Performance 
* First Question: Is there a steady growth between sessions and orders over time? And is there a seasonal trend?

SELECT  YEAR(ws.created_at) as year,quarter(ws.created_at) as quarter, ROUND(COUNT(DISTINCT ws.website_session_id),-3)as number_of_sessions,

ROUND(COUNT(DISTINCT o.order_id),-2) as number_of_orders
FROM website_sessions ws
LEFT JOIN orders o ON o.website_session_id = ws.website_session_id
where YEAR(ws.created_at) != 2015 
GROUP BY 1,2
ORDER BY 1;

![Graphs/sessions_orders.png](Graphs/sessions_orders.png)
