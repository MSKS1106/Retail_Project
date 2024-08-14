-- find top 10 highest revenue generating products
SELECT top 10 product_id, sum(sale_price) as sales
from df_order
group by product_id
order by sales DESC


-- find top 5 highest selling products in each region
with cte as(
Select region,product_id, sum(sale_price) as sales 
from df_order
GROUP by region,product_id)
SELECT * from (
select*
,ROW_NUMBER() over (PARTITION by region order by sales DESC) as rn
from cte) A
where rn<=5


--Find month over month growth comparison for 2022 and 2023 sales ef: jan 202 vs jan 2023
With CTE as(
SELECT year(order_date) as order_year,MONTH(order_date) as order_month,
sum(sale_price) as sales 
from df_order
group by year(order_date),MONTH(order_date)
)
SELECT order_month
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from CTE
group by order_month
order by order_month


-- For each category which month had highest sales
With cte AS
(Select category,format(order_date,'yyyy-MM') as order_year_month,sum(sale_price) as sales 
from df_order
Group by category,format(order_date,'yyyy-MM')
)
SELECT * from(
Select *,
ROW_NUMBER() over (partition by category order by sales DESC) as rn
From cte) A
where rn =1


-- Which sub category had highest growth by profit in 2023 compare to 2022
With CTE as(
SELECT sub_category,year(order_date) as order_year,
sum(sale_price) as sales 
from df_order
group by sub_category,year(order_date)
),
CTE2 as(
SELECT sub_category
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from CTE
group by sub_category
)
SELECT top 1 *
, (sales_2023 - sales_2022)*100/sales_2022 as Growth_percent
from CTE2 
order by (sales_2023 - sales_2022)*100/sales_2022 DESC