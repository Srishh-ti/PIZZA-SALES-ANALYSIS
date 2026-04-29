-- Adding Data
create database pizzahut;
use pizzahut;
select * from pizzas;

create table orders(
order_id int not null primary key,
order_date date not null,
order_time time not null
);

create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null
);

-- Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_revenue 
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity) as qty
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by qty desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by total_quantity desc; 

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hour, count(order_id) from orders
group by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as count from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_pizzas_ordered_per_day from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, round(sum(pizzas.price * order_details.quantity),2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category as category, (round(sum(pizzas.price * order_details.quantity)/ 
(select sum(pizzas.price * order_details.quantity) as total_revenue from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id),2))*100 
as revenue_percent
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by category order by revenue_percent desc;

-- Analyze the cumulative revenue generated over time.
select order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, round(sum(pizzas.price * order_details.quantity),2) as revenue
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join orders 
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.name, pizza_types.category, sum(pizzas.price * order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name, pizza_types.category) as a) as b
where rn<=3;