================
--database exploration
================

--show all tables

select *
from information_schema.tables
where table_type = 'base table'


--show columns for orders table

select *
from information_schema.columns
where table_name = 'orders'


--show columns for order items table

select *
from information_schema.columns
where table_name = 'order_items'


--show columns for customers table

select *
from information_schema.columns
where table_name = 'customers'


--show columns for products table

select *
from information_schema.columns
where table_name = 'products'


--show columns for sellers table

select *
from information_schema.columns
where table_name = 'sellers'


--show columns for payments table

select *
from information_schema.columns
where table_name = 'payments'


--show columns for reviews table

select *
from information_schema.columns
where table_name = 'order_reviews'


--total rows in each table

select 'orders' as table_name,
count(*) as total_rows
from dbo.orders

union all

select 'order_items',
count(*)
from dbo.order_items

union all

select 'customers',
count(*)
from dbo.customers

union all

select 'products',
count(*)
from dbo.products

union all

select 'sellers',
count(*)
from dbo.sellers

union all

select 'payments',
count(*)
from dbo.payments

union all

select 'order_reviews',
count(*)
from dbo.order_reviews


--data date range

select
min(order_purchase_timestamp) as first_order_date,
max(order_purchase_timestamp) as last_order_date,
datediff(
	year,
	min(order_purchase_timestamp),
	max(order_purchase_timestamp)
) as data_year_span
from dbo.orders



================
--data quality
================

--duplicate orders

select
order_id,
count(*) as duplicate
from dbo.orders
group by order_id
having count(*) > 1


--duplicate customers

select
customer_id,
count(*) as duplicate
from dbo.customers
group by customer_id
having count(*) > 1


--duplicate products

select
product_id,
count(*) as duplicate
from dbo.products
group by product_id
having count(*) > 1


--duplicate sellers

select
seller_id,
count(*) as duplicate
from dbo.sellers
group by seller_id
having count(*) > 1


--duplicate order items

select
order_id,
order_item_id,
count(*) as duplicate
from dbo.order_items
group by
order_id,
order_item_id
having count(*) > 1


--check missing values in orders

select
sum(case when order_id is null then 1 else 0 end) as missing_order_id,
sum(case when customer_id is null then 1 else 0 end) as missing_customer_id,
sum(case when order_status is null then 1 else 0 end) as missing_order_status,
sum(case when order_purchase_timestamp is null then 1 else 0 end) as missing_purchase_date,
sum(case when order_approved_at is null then 1 else 0 end) as missing_approved_date,
sum(case when order_delivered_customer_date is null then 1 else 0 end) as missing_delivery_date
from dbo.orders


--check missing values in products

select
sum(case when product_id is null then 1 else 0 end) as missing_product_id,
sum(case when product_category_name is null then 1 else 0 end) as missing_category,
sum(case when product_weight_g is null then 1 else 0 end) as missing_weight
from dbo.products


--check invalid price or freight values

select *
from dbo.order_items
where price < 0
	or freight_value < 0


--check invalid payment values

select *
from dbo.payments
where payment_value < 0


--check delivery date before purchase date

select *
from dbo.orders
where order_delivered_customer_date < order_purchase_timestamp


--check approval before purchase date

select *
from dbo.orders
where order_approved_at < order_purchase_timestamp


--check review scores outside expected range

select *
from dbo.order_reviews
where review_score < 1
	or review_score > 5



================
--dimension exploration
================

--order status

select distinct order_status
from dbo.orders


--customer states

select distinct customer_state
from dbo.customers
order by customer_state


--customer cities

select distinct customer_city
from dbo.customers
order by customer_city


--seller states

select distinct seller_state
from dbo.sellers
order by seller_state


--seller cities

select distinct seller_city
from dbo.sellers
order by seller_city


--product categories

select distinct product_category_name
from dbo.products
order by product_category_name


--english product categories

select distinct product_category_name_english
from dbo.category
order by product_category_name_english


--payment types

select distinct payment_type
from dbo.payments


--review scores

select distinct review_score
from dbo.order_reviews
order by review_score



================
--measures exploration
================

--total orders

select
count(distinct order_id) as total_orders
from dbo.orders


--total customers

select
count(distinct customer_unique_id) as total_customers
from dbo.customers


--total products

select
count(distinct product_id) as total_products
from dbo.products


--total sellers

select
count(distinct seller_id) as total_sellers
from dbo.sellers


--total items

select
count(*) as total_items
from dbo.order_items


--total sales and freight

select
format(sum(price),'n2') as total_sales,
format(sum(freight_value),'n2') as total_freight,
format(avg(price),'n2') as avg_item_price
from dbo.order_items


--total payments

select
format(sum(payment_value),'n2') as total_payment_value,
format(avg(payment_value),'n2') as avg_payment_value
from dbo.payments


--average review score

select
round(avg(review_score * 1.0),2) as avg_review_score
from dbo.order_reviews


--average delivery days

select
round(
	avg(
		datediff(
			day,
			order_purchase_timestamp,
			order_delivered_customer_date
		) * 1.0
	),
	2
) as avg_delivery_days
from dbo.orders
where order_delivered_customer_date is not null



================
--sales analysis
================

--sales by category

select
p.product_category_name,
format(sum(oi.price),'n2') as total_sales,
count(*) as total_items,
format(sum(oi.freight_value),'n2') as total_freight
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
group by p.product_category_name
order by sum(oi.price) desc


--sales by english category

select
c.product_category_name_english,
format(sum(oi.price),'n2') as total_sales,
count(*) as total_items
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
left join dbo.category c
	on c.product_category_name = p.product_category_name
group by c.product_category_name_english
order by sum(oi.price) desc


--sales by customer state

select
c.customer_state,
format(sum(oi.price),'n2') as total_sales,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.customers c
	on c.customer_id = o.customer_id
left join dbo.order_items oi
	on oi.order_id = o.order_id
group by c.customer_state
order by sum(oi.price) desc


--sales by seller state

select
s.seller_state,
format(sum(oi.price),'n2') as total_sales,
count(distinct oi.order_id) as total_orders
from dbo.order_items oi
left join dbo.sellers s
	on s.seller_id = oi.seller_id
group by s.seller_state
order by sum(oi.price) desc


--sales by payment type

select
payment_type,
format(sum(payment_value),'n2') as total_payment_value,
count(distinct order_id) as total_orders
from dbo.payments
group by payment_type
order by sum(payment_value) desc


--average installments by payment type

select
payment_type,
round(avg(payment_installments * 1.0),2) as avg_installments
from dbo.payments
group by payment_type
order by avg_installments desc


--monthly sales

select
datetrunc(month,o.order_purchase_timestamp) as sales_month,
format(sum(oi.price),'n2') as total_sales,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.order_items oi
	on oi.order_id = o.order_id
group by datetrunc(month,o.order_purchase_timestamp)
order by sales_month


--yearly sales

select
year(o.order_purchase_timestamp) as sales_year,
format(sum(oi.price),'n2') as total_sales,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.order_items oi
	on oi.order_id = o.order_id
group by year(o.order_purchase_timestamp)
order by sales_year



================
--ranking analysis
================

--top 10 products by sales

select
top 10
oi.product_id,
p.product_category_name,
format(sum(oi.price),'n2') as total_sales,
count(*) as total_items
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
group by
oi.product_id,
p.product_category_name
order by sum(oi.price) desc


--top 10 categories by sales

select
top 10
p.product_category_name,
format(sum(oi.price),'n2') as total_sales
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
group by p.product_category_name
order by sum(oi.price) desc


--top 10 sellers by sales

select
top 10
oi.seller_id,
s.seller_city,
s.seller_state,
format(sum(oi.price),'n2') as total_sales,
count(distinct oi.order_id) as total_orders
from dbo.order_items oi
left join dbo.sellers s
	on s.seller_id = oi.seller_id
group by
oi.seller_id,
s.seller_city,
s.seller_state
order by sum(oi.price) desc


--top 10 customers by spending

select
top 10
c.customer_unique_id,
c.customer_city,
c.customer_state,
format(sum(oi.price),'n2') as total_spending,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.customers c
	on c.customer_id = o.customer_id
left join dbo.order_items oi
	on oi.order_id = o.order_id
group by
c.customer_unique_id,
c.customer_city,
c.customer_state
order by sum(oi.price) desc


--rank categories by sales

select
p.product_category_name,
format(sum(oi.price),'n2') as total_sales,
rank() over(
	order by sum(oi.price) desc
) as sales_rank
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
group by p.product_category_name
order by sales_rank


--rank sellers by sales

select
oi.seller_id,
format(sum(oi.price),'n2') as total_sales,
rank() over(
	order by sum(oi.price) desc
) as seller_rank
from dbo.order_items oi
group by oi.seller_id
order by seller_rank

================
--change over time
================

--monthly sales

select
datetrunc(month,o.order_purchase_timestamp) as sales_month,
format(sum(oi.price),'n2') as total_sales,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.order_items oi
	on oi.order_id = o.order_id
group by datetrunc(month,o.order_purchase_timestamp)
order by sales_month


--monthly customers

select
datetrunc(month,o.order_purchase_timestamp) as sales_month,
count(distinct c.customer_unique_id) as total_customers
from dbo.orders o
left join dbo.customers c
	on c.customer_id = o.customer_id
group by datetrunc(month,o.order_purchase_timestamp)
order by sales_month


--monthly average order value

with order_sales as
(
	select
	order_id,
	sum(price) as order_value
	from dbo.order_items
	group by order_id
)

select
datetrunc(month,o.order_purchase_timestamp) as sales_month,
format(avg(os.order_value),'n2') as avg_order_value
from dbo.orders o
left join order_sales os
	on os.order_id = o.order_id
group by datetrunc(month,o.order_purchase_timestamp)
order by sales_month



================
--yoy growth
================

with yearly_sales as
(
	select
	year(o.order_purchase_timestamp) as sales_year,
	sum(oi.price) as total_sales
	from dbo.orders o
	left join dbo.order_items oi
		on oi.order_id = o.order_id
	group by year(o.order_purchase_timestamp)
),
yearly_comparison as
(
	select
	sales_year,
	total_sales,
	lag(total_sales) over(
		order by sales_year
	) as prv_year_sales
	from yearly_sales
)

select
sales_year,
format(total_sales,'n2') as total_sales,
format(prv_year_sales,'n2') as prv_year_sales,
round(
	(total_sales - prv_year_sales) * 100.0 /
	nullif(prv_year_sales,0),
	2
) as yoy_growth
from yearly_comparison
order by sales_year



================
--mom growth
================

with monthly_sales as
(
	select
	datetrunc(month,o.order_purchase_timestamp) as sales_month,
	sum(oi.price) as total_sales
	from dbo.orders o
	left join dbo.order_items oi
		on oi.order_id = o.order_id
	group by datetrunc(month,o.order_purchase_timestamp)
),
monthly_comparison as
(
	select
	sales_month,
	total_sales,
	lag(total_sales) over(
		order by sales_month
	) as prv_month_sales
	from monthly_sales
)

select
sales_month,
format(total_sales,'n2') as total_sales,
format(prv_month_sales,'n2') as prv_month_sales,
format(total_sales - prv_month_sales,'n2') as sales_difference,
round(
	(total_sales - prv_month_sales) * 100.0 /
	nullif(prv_month_sales,0),
	2
) as mom_growth
from monthly_comparison
order by sales_month



================
--cumulative analysis
================

with monthly_sales as
(
	select
	datetrunc(month,o.order_purchase_timestamp) as sales_month,
	sum(oi.price) as total_sales
	from dbo.orders o
	left join dbo.order_items oi
		on oi.order_id = o.order_id
	group by datetrunc(month,o.order_purchase_timestamp)
)

select
sales_month,
format(total_sales,'n2') as total_sales,
format(
	sum(total_sales) over(
		order by sales_month
	),
	'n2'
) as cumulative_sales
from monthly_sales
order by sales_month



================
--customer analysis
================

with customer_sales as
(
	select
	c.customer_unique_id,
	count(distinct o.order_id) as total_orders,
	sum(oi.price) as total_sales,
	min(o.order_purchase_timestamp) as first_order_date,
	max(o.order_purchase_timestamp) as last_order_date
	from dbo.orders o
	left join dbo.customers c
		on c.customer_id = o.customer_id
	left join dbo.order_items oi
		on oi.order_id = o.order_id
	group by c.customer_unique_id
)

select
customer_unique_id,
total_orders,
format(total_sales,'n2') as total_sales,
format(
	total_sales / nullif(total_orders,0),
	'n2'
) as avg_order_value,
first_order_date,
last_order_date,
datediff(
	day,
	first_order_date,
	last_order_date
) as customer_lifetime_days,
rank() over(
	order by total_sales desc
) as customer_rank
from customer_sales
order by total_sales desc



================
--rfm customer segmentation
================

with customer_rfm as
(
	select
	c.customer_unique_id,
	max(o.order_purchase_timestamp) as last_order_date,
	count(distinct o.order_id) as frequency,
	sum(oi.price) as monetary
	from dbo.orders o
	left join dbo.customers c
		on c.customer_id = o.customer_id
	left join dbo.order_items oi
		on oi.order_id = o.order_id
	group by c.customer_unique_id
),
rfm_values as
(
	select
	customer_unique_id,
	datediff(
		day,
		last_order_date,
		(select max(order_purchase_timestamp) from dbo.orders)
	) as recency,
	frequency,
	monetary
	from customer_rfm
),
rfm_scores as
(
	select
	customer_unique_id,
	recency,
	frequency,
	monetary,
	ntile(5) over(
		order by recency desc
	) as recency_score,
	ntile(5) over(
		order by frequency
	) as frequency_score,
	ntile(5) over(
		order by monetary
	) as monetary_score
	from rfm_values
)

select
customer_unique_id,
recency,
frequency,
format(monetary,'n2') as monetary,
recency_score,
frequency_score,
monetary_score,
concat(
	recency_score,
	frequency_score,
	monetary_score
) as rfm_score
from rfm_scores
order by monetary desc



================
--product analysis
================

select
oi.product_id,
p.product_category_name,
count(distinct oi.order_id) as total_orders,
count(*) as total_items,
format(sum(oi.price),'n2') as total_sales,
format(avg(oi.price),'n2') as avg_price,
format(sum(oi.freight_value),'n2') as total_freight,
rank() over(
	order by sum(oi.price) desc
) as sales_rank
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
group by
oi.product_id,
p.product_category_name
order by sum(oi.price) desc



================
--seller analysis
================

select
oi.seller_id,
s.seller_city,
s.seller_state,
count(distinct oi.order_id) as total_orders,
format(sum(oi.price),'n2') as total_sales,
format(avg(oi.price),'n2') as avg_item_price,
format(sum(oi.freight_value),'n2') as total_freight,
rank() over(
	order by sum(oi.price) desc
) as seller_rank
from dbo.order_items oi
left join dbo.sellers s
	on s.seller_id = oi.seller_id
group by
oi.seller_id,
s.seller_city,
s.seller_state
order by sum(oi.price) desc



================
--payment analysis
================

select
payment_type,
count(distinct order_id) as total_orders,
format(sum(payment_value),'n2') as total_payment_value,
format(avg(payment_value),'n2') as avg_payment_value,
round(
	avg(payment_installments * 1.0),
	2
) as avg_installments
from dbo.payments
group by payment_type
order by sum(payment_value) desc



================
--review analysis
================

--review score distribution

select
review_score,
count(*) as total_reviews
from dbo.order_reviews
group by review_score
order by review_score


--average review score by category

select
p.product_category_name,
round(
	avg(r.review_score * 1.0),
	2
) as avg_review_score,
count(*) as total_reviews
from dbo.order_reviews r
left join dbo.order_items oi
	on oi.order_id = r.order_id
left join dbo.products p
	on p.product_id = oi.product_id
group by p.product_category_name
order by avg_review_score desc



================
--logistics analysis
================

--average delivery days

select
round(
	avg(
		datediff(
			day,
			order_purchase_timestamp,
			order_delivered_customer_date
		) * 1.0
	),
	2
) as avg_delivery_days
from dbo.orders
where order_delivered_customer_date is not null


--on time vs late delivery

select
case
	when order_delivered_customer_date <= order_estimated_delivery_date
		then 'on time'
	else 'late'
end as delivery_status,
count(*) as total_orders
from dbo.orders
where order_delivered_customer_date is not null
group by
case
	when order_delivered_customer_date <= order_estimated_delivery_date
		then 'on time'
	else 'late'
end


--delivery performance by customer state

select
c.customer_state,
round(
	avg(
		datediff(
			day,
			o.order_purchase_timestamp,
			o.order_delivered_customer_date
		) * 1.0
	),
	2
) as avg_delivery_days,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.customers c
	on c.customer_id = o.customer_id
where o.order_delivered_customer_date is not null
group by c.customer_state
order by avg_delivery_days



================
--delivery vs review score
================

select
case
	when o.order_delivered_customer_date <= o.order_estimated_delivery_date
		then 'on time'
	else 'late'
end as delivery_status,
round(
	avg(r.review_score * 1.0),
	2
) as avg_review_score,
count(distinct o.order_id) as total_orders
from dbo.orders o
left join dbo.order_reviews r
	on r.order_id = o.order_id
where o.order_delivered_customer_date is not null
group by
case
	when o.order_delivered_customer_date <= o.order_estimated_delivery_date
		then 'on time'
	else 'late'
end



================
--part to whole analysis
================

with category_sales as
(
	select
	p.product_category_name,
	sum(oi.price) as total_sales
	from dbo.order_items oi
	left join dbo.products p
		on p.product_id = oi.product_id
	group by p.product_category_name
)

select
product_category_name,
format(total_sales,'n2') as total_sales,
round(
	total_sales * 100.0 /
	sum(total_sales) over(),
	2
) as percentage_of_total_sales
from category_sales
order by total_sales desc



================
--performance analysis
================

with seller_sales as
(
	select
	seller_id,
	sum(price) as total_sales
	from dbo.order_items
	group by seller_id
),
seller_comparison as
(
	select
seller_id,
total_sales,
avg(total_sales) over() as avg_seller_sales
from seller_sales
)

select
seller_id,
format(total_sales,'n2') as total_sales,
format(avg_seller_sales,'n2') as avg_seller_sales,
case
	when total_sales > avg_seller_sales then 'above average'
	when total_sales < avg_seller_sales then 'below average'
	else 'average'
end as seller_performance
from seller_comparison
order by total_sales desc



================
--final customer report
================

with customer_report as
(
	select
	c.customer_unique_id,
	count(distinct o.order_id) as total_orders,
	sum(oi.price) as total_sales,
	min(o.order_purchase_timestamp) as first_order_date,
	max(o.order_purchase_timestamp) as last_order_date
	from dbo.orders o
	left join dbo.customers c
		on c.customer_id = o.customer_id
	left join dbo.order_items oi
		on oi.order_id = o.order_id
	group by c.customer_unique_id
)

select
customer_unique_id,
total_orders,
format(total_sales,'n2') as total_sales,
format(
	total_sales / nullif(total_orders,0),
	'n2'
) as avg_order_value,
first_order_date,
last_order_date,
datediff(
	day,
	first_order_date,
	last_order_date
) as customer_lifetime_days,
rank() over(
	order by total_sales desc
) as customer_rank
from customer_report
order by total_sales desc



================
--final product report
================

select
oi.product_id,
p.product_category_name,
count(distinct oi.order_id) as total_orders,
count(*) as total_items,
format(sum(oi.price),'n2') as total_sales,
format(avg(oi.price),'n2') as avg_price,
format(sum(oi.freight_value),'n2') as total_freight,
rank() over(
	order by sum(oi.price) desc
) as product_rank
from dbo.order_items oi
left join dbo.products p
	on p.product_id = oi.product_id
group by
oi.product_id,
p.product_category_name
order by sum(oi.price) desc



================
--final seller report
================

select
oi.seller_id,
s.seller_city,
s.seller_state,
count(distinct oi.order_id) as total_orders,
format(sum(oi.price),'n2') as total_sales,
format(avg(oi.price),'n2') as avg_price,
format(sum(oi.freight_value),'n2') as total_freight,
rank() over(
	order by sum(oi.price) desc
) as seller_rank
from dbo.order_items oi
left join dbo.sellers s
	on s.seller_id = oi.seller_id
group by
oi.seller_id,
s.seller_city,
s.seller_state
order by sum(oi.price) desc