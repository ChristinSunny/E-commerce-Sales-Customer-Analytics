create database e_commerce;

use e_commerce; 

-- 1. TOTAL ORDERS
select count(distinct order_id) as total_order from orders;

--2. TOTAL CANCELLED ORDERS
select count(distinct order_id) as total_cancelled_order from orders where order_status='cancelled';

--3. TOTAL COMPLETED ORDERS

select count(DISTINCT order_id) AS total_completed_orders from orders WHERE order_status='completed';

--4. TOTAL SALES REVENUE

select sum(line_total) as Total_revenue from order_items oi inner join orders o on oi.order_id=o.order_id where o.order_status='completed';

-- 5. net sales after refund

select
  (select sum(oi.line_total)
   from order_items oi
   join orders o on o.order_id = oi.order_id
   where o.order_status <> 'cancelled')
  -
  (select COALESCE(SUM(r.amount), 0)
   FROM refunds r
   JOIN orders o ON o.order_id = r.order_id
   WHERE o.order_status <> 'cancelled') AS net_sales;


--6. AVERAGE ORDER VALUES

select ROUND(SUM(order_total) * 1.0 / COUNT(DISTINCT order_id), 2) AS AOV
FROM orders
WHERE order_status = 'completed';

--7. MONTHLY REVENUE

SELECT YEAR(o.ordered_at) as Sales_year,MONTH(o.ordered_at) as month_no,DATENAME(month,o.ordered_at) as [Month],sum(oi.line_total) as Revenue 
from orders o inner join order_items oi on o.order_id=oi.order_id where o.order_status='completed' 
group by YEAR(o.ordered_at),MONTH(o.ordered_at),DATENAME(month,o.ordered_at) order by Sales_year,MONTH(o.ordered_at) asc;


-- 8.MONTH OVER MONTH REVENUE

WITH MonthlyRevenue as (
    select
        datefromparts(
            year(o.ordered_at),
            month(o.ordered_at),
            1
        ) as sales_month,
        sum(oi.line_total) as revenue
    from dbo.orders as o
    inner join dbo.order_items as oi
        on o.order_id = oi.order_id
    where LOWER(o.order_status) = 'completed'
    GROUP BY
        DATEFROMPARTS(
            YEAR(o.ordered_at),
            MONTH(o.ordered_at),
            1
        )
),
RevenueWithPreviousMonth AS (
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM MonthlyRevenue
)
SELECT
    sales_month,
    revenue,
    previous_month_revenue,
    CAST(
        (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0)
        AS DECIMAL(10,2)
    ) AS mom_growth_percentage
FROM RevenueWithPreviousMonth
ORDER BY sales_month;


-- 9. ORDER CANCELLATION RATE

SELECT
    COUNT(CASE
        WHEN order_status = 'cancelled' THEN 1
    END) * 100.0 /(COUNT(*))
        AS Cancellation_Rate_Percentage
FROM orders;

-- 10. ORDER COMPLETION RATE

SELECT
    COUNT(CASE
        WHEN order_status = 'completed' THEN 1
    END) * 100.0 /(COUNT(*))
        AS Completion_Rate_Percentage
FROM orders;




--------------------------------------------------------------CUSTOMER ANALYSIS------------------------------------------------------------------------------
-- 11. unique customers

select count(distinct customer_id) as unique_customers from customers;

-- 12 PURCHASING CUSTOMERS
SELECT COUNT(DISTINCT c.customer_id) AS total_purchasing_customers
FROM customers c INNER JOIN orders o ON c.customer_id = o.customer_id;

-- 13 Customers by month
Select YEAR(created_at) as Sales_year,MONTH(created_at) as Month_no,
DATENAME(MONTH,created_at) as [Month],COUNT(customer_id) as Customers_count from customers
group by  YEAR(created_at),MONTH(created_at),DATENAME(MONTH,created_at) 
order by Sales_year,Month_no;

-- 14 REPEAT CUSTOMER RATE %

SELECT COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM orders) AS repeat_rate
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS repeat_customers;

-- 15 Average Orders per Customers

SELECT COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id) AS Avg_orders_per_cust
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- 16 Revenue by Customer segment

select c.customer_segment, sum(oi.line_total) as Revenue from customers c inner join orders o 
on c.customer_id=o.customer_id inner join order_items oi on o.order_id=oi.order_id
where o.order_status='completed' group by c.customer_segment order by Revenue desc;


-- 17 Revenue by Acquistion channel
select c.acquisition_channel, sum(oi.line_total) as Revenue from customers c inner join orders o 
on c.customer_id=o.customer_id inner join order_items oi on o.order_id=oi.order_id
where o.order_status='completed' group by c.acquisition_channel order by Revenue desc;

-- 18 Top 10 customers by revenue
select top 10 c.customer_id as [customer_id], sum(oi.line_total) as Revenue from customers c inner join orders o 
on c.customer_id=o.customer_id inner join order_items oi on o.order_id=oi.order_id
where o.order_status='completed' group by c.customer_id order by Revenue desc;

------------------------------------------------------------- PRODUCT ANALYSIS-------------------------------------------------------------------------------------

-- 19 Total Product solds

select sum(oi.quantity) as total_unit_solds from orders o inner join order_items oi on o.order_id=oi.order_id where
o.order_status='completed';

-- 20  Top 10 Products by Revenue
select top 10 p.product_id as [product_id],p.product_name as [product_name], sum(oi.line_total) as Revenue from products p inner join order_items oi
on p.product_id=oi.product_id inner join orders o on o.order_id=oi.order_id
where o.order_status='completed' group by p.product_id,p.product_name order by Revenue desc;

-- 21 Revenue by Product Category
select p.category as [category], sum(oi.line_total) as Revenue from products p inner join order_items oi
on p.product_id=oi.product_id inner join orders o on o.order_id=oi.order_id
where o.order_status='completed' group by p.category order by Revenue desc;

-- 22 Gross  profit by revenue

select p.product_id,p.product_name,SUM(oi.line_total) AS total_revenue,
SUM(oi.quantity * p.unit_cost) AS total_cost,SUM(oi.line_total) - SUM(oi.quantity * p.unit_cost) AS gross_profit
from products p inner join order_items oi on p.product_id = oi.product_id
inner join orders o on oi.order_id = o.order_id
where o.order_status = 'completed'
group by p.product_id,p.product_name order by gross_profit desc;

-- 23 Gross margin by category
select p.category,sum(oi.line_total) - sum(oi.quantity * p.unit_cost) as gross_profit,
(sum(oi.line_total) - sum(oi.quantity * p.unit_cost))* 100.0 /SUM(oi.line_total)
as gross_margin_percentage from products p
inner join order_items oi on p.product_id = oi.product_id
inner join orders o ON oi.order_id = o.order_id
where o.order_status = 'completed'
group by p.category
order by gross_margin_percentage DESC;

-- 24 Products never ordered

SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (
    SELECT oi.product_id
    FROM order_items oi
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
);

---------------------------------------------------------------------PAYMENTS & REFUNDS--------------------------------------------------------------------------------------------
-- 25 Payment sucess%
SELECT
    COUNT(CASE
        WHEN payment_status = 'succeeded' THEN 1
    END) * 100.0 / COUNT(*) AS payment_success_rate
FROM payments;

--26 Revenue by payment method

SELECT payment_method,SUM(amount) as total_revenue from payments where payment_status = 'succeeded' group by payment_method order by total_revenue desc;

-- 27 Refund amount
select sum(amount) as total_refund_amount from refunds;

-- 28 refund reason

select refund_reason,count(*) AS total_refunds,sum(amount) AS total_refund_amount from refunds group BY refund_reason order BY total_refund_amount DESC;

-- 29 failed payment analysis
select sum(amount) as failed_payment_amount,count(*) as no_of_times_payment_failed from payments where payment_status = 'failed';

-- 30 Orders without matching customer_id

select o.order_id,o.customer_id from orders o left join customers c on o.customer_id=c.customer_id where c.customer_id is null;

--31 Refund Rate
select count(DISTINCT r.order_id) * 100.0 / count(DISTINCT o.order_id) AS refund_rate_pct
from orders o
left join refunds r ON r.order_id = o.order_id;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------