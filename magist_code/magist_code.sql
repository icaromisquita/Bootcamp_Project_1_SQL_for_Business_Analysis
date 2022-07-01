USE magist;

# 1- How many orders are there in the dataset? 

SELECT COUNT(order_id)
FROM orders;

# 2 - Are orders actually delivered?

SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY  order_status;

#3 - Is Magist having user growth?
/* Does it have a growth in engagement? (custumer reviews)
*/

SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id)
FROM
    orders
GROUP BY year_ , month_
ORDER BY year_ , month_;

#4 - How many products are there in the products table?
SELECT COUNT(DISTINCT product_id) AS number_products
FROM products;

#5 - Which are the categories with most products? 
SELECT COUNT(DISTINCT product_id), product_category_name
FROM products
GROUP BY product_category_name 
ORDER BY COUNT(DISTINCT product_id) DESC;

#6 - How many of those products were present in actual transactions? 
/*
Does it have 
*/
SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;
    
#7 - What’s the price for the most expensive and cheapest products?
SELECT 
	MAX(price) AS most_expensive, MIN(price) AS cheapest
FROM
	order_items;

#8 - What are the highest and lowest payment values? 
SELECT 
	MAX(payment_value) AS highest_payment, 
    MIN(payment_value) AS lowest_payment
FROM
	order_payments;
---------------------------------------------------------------------------------------------
												# Business Questions 
 
/*
In relation to the products:
*/    
#What categories of tech products does Magist have?
SELECT DISTINCT(pro_trans.product_category_name_english) as TECH
FROM product_category_name_translation as pro_trans
	JOIN products as pro
   ON pro_trans.product_category_name = pro.product_category_name
   WHERE pro_trans.product_category_name_english
	IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") 
;

 
/*
How many products of these tech categories have been sold (within the time window of the database snapshot)? 
What percentage does that represent from the overall number of products sold?
*/
SELECT DISTINCT (pro_trans.product_category_name_english) AS tech, COUNT(oi.order_item_id) AS num_itens_sold
FROM product_category_name_translation as pro_trans
	JOIN products as pr
   ON pro_trans.product_category_name = pr.product_category_name
LEFT JOIN order_items as oi
		ON pr.product_id = oi.product_id
	LEFT JOIN orders as o
		ON oi.order_id = o.order_id
GROUP BY pro_trans.product_category_name_english 
HAVING pro_trans.product_category_name_english
		IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") 
;

# What’s the average price of the products being sold?

SELECT ROUND(AVG(price),2) AS avg_price , pro_trans.product_category_name_english 
FROM product_category_name_translation as pro_trans
	JOIN products as pr
   ON pro_trans.product_category_name = pr.product_category_name
LEFT JOIN order_items as oi
		ON pr.product_id = oi.product_id
GROUP BY pro_trans.product_category_name_english 
HAVING (pro_trans.product_category_name_english) 
	IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") ;
        
# Are expensive tech products popular? 

#SELECT DISTINCT(pro_trans.product_category_name_english) as TECH
SELECT *, COUNT(*) AS num_sold_itens, pro_trans.product_category_name_english as TECH,
	CASE
    WHEN ord_it.price > 500 THEN "Expensive"
    ELSE "Cheap"
END AS "price_range"
FROM product_category_name_translation as pro_trans
	JOIN products as pro
   ON pro_trans.product_category_name = pro.product_category_name
	JOIN order_items as ord_it
		ON pro.product_id = ord_it.product_id
WHERE pro_trans.product_category_name_english
	IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") 
GROUP BY price_range, pro_trans.product_category_name_english
;
   

# What’s the average time between the order being placed and the product being delivered?
SELECT ROUND(AVG(TIMESTAMPDIFF(day, order_purchase_timestamp, order_delivered_customer_date)),1) AS avg_deli_day
FROM orders;

# How many orders are delivered on time vs orders delivered with a delay?
SELECT COUNT(*),
    CASE
        WHEN TIMESTAMPDIFF(day, order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN "delayed"
        ELSE "OnTime"
    END AS "performance"
FROM orders
GROUP BY performance;

# Is there any pattern for delayed orders, e.g. big products being delayed more often?
# Tech X Non Tech
SELECT  pro_trans.product_category_name_english,  COUNT(*),
CASE
        WHEN TIMESTAMPDIFF(day, ord.order_delivered_customer_date, ord.order_estimated_delivery_date) > 0 THEN "delayed"
        ELSE "OnTime"
    END AS "performance"
    
FROM orders AS ord
	JOIN order_items AS ord_it
		ON ord.order_id = ord_it.order_id
	JOIN products AS pro
        ON ord_it.product_id = pro.product_id
	JOIN  product_category_name_translation as pro_trans
		ON pro.product_category_name = pro_trans.product_category_name
        
GROUP BY  product_category_name_english, performance
ORDER BY product_category_name_english, performance
;