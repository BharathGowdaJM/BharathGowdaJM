drop database dannys_diner; 
CREATE database dannys_diner;
use dannys_diner;
CREATE TABLE sales(
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
show tables;
select * from members;

# 1. What is the total amount each customer spent at the restaurant?
select customer_id,sum(price) as Total_Amount_Spent from sales as s
 inner join menu as m using(product_id) group by customer_id;
  
# 2. How many days has each customer visited the restaurant? 
select customer_id,count(distinct order_date) as No_of_Visit_Days 
from sales group by customer_id; 

# 3. What was the first item from the menu purchased by each customer?

select * from (
select *,row_number() over(partition by customer_id order by order_date) as rn
 from sales as s inner join menu as m 
using(product_id) ) as t where rn = 1;

# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name,count(*) as cnt from sales as s
 inner join menu as m using(product_id) group by product_name
 order by cnt desc limit 1;
 
# 5. Which item was the most popular for each customer?

select * from (
select customer_id,product_name,count(*) as cnt,
rank() over(partition by customer_id order by count(*) desc) as rn
 from sales as s
 inner join menu as m using(product_id) group by customer_id,product_name) as t
 where rn = 1;
 

with product_sales as (
select customer_id,product_name,count(*) as cnt
 from sales as s inner join menu as m using(product_id)
 group by customer_id,product_name), rnk_CTE as (
select *,rank() over(partition by customer_id order by cnt desc) as rn
 from product_sales)
 select * from rnk_CTE where rn =1;
 
# 6. Which item was purchased first by the customer after they became a member?

with CTE1 as (
select S.*,m.price,m.product_name,mb.join_date from sales as s inner join menu as m using(product_id) 
inner join members as mb on s.customer_id = mb.customer_id and order_date > join_date), CTE2 as(

select *,rank() over(partition by customer_id order by order_date asc) as rn from CTE1)
select customer_id,product_name from CTE2 where rn = 1;

#number of orders palced by the customers after becomming member
select customer_id,count(order_date) as num_of_orders from(
select * from sales as s inner join members as mb using(customer_id) where order_date>join_date) 
as t group by customer_id;
 
 
 

 
 


 



