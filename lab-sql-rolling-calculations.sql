#First get the number of active users

WITH cte_rental as (
	SELECT customer_id, DATE_FORMAT(convert(rental_date,date), '%Y-%m-%d') as rental_date,
		DATE_FORMAT(convert(rental_date,date), '%Y') as rental_year,
		DATE_FORMAT(convert(rental_date,date), '%m') as rental_month
	FROM rental
)
	SELECT 
		count(distinct customer_id) AS active_user,
		rental_year,
		rental_month
	FROM cte_rental
	GROUP BY rental_year, rental_month;

#Then, I count the active users in the previous month.

WITH cte_rental as (
	SELECT customer_id, DATE_FORMAT(convert(rental_date,date), '%Y-%m-%d') as rental_date,
		DATE_FORMAT(convert(rental_date,date), '%Y') as rental_year,
		DATE_FORMAT(convert(rental_date,date), '%m') as rental_month
	FROM rental
), cte_active_users as (
	SELECT 
		count(distinct customer_id) AS active_user,
		rental_year,
		rental_month
	FROM cte_rental
	GROUP BY rental_year, rental_month
)
SELECT rental_year, rental_month, active_user, 
   LAG(active_user) OVER (ORDER BY rental_year, rental_month) as Last_month
FROM cte_active_users;

#Percentage change in the number of active customers.

WITH cte_rental as (
	SELECT customer_id, DATE_FORMAT(convert(rental_date,date), '%Y-%m-%d') as rental_date,
		DATE_FORMAT(convert(rental_date,date), '%Y') as rental_year,
		DATE_FORMAT(convert(rental_date,date), '%m') as rental_month
	FROM rental
), cte_active_users as (
	SELECT 
		count(distinct customer_id) AS active_user,
		rental_year,
		rental_month
	FROM cte_rental
	GROUP BY rental_year, rental_month
), cte_active_users_prev_month as (
SELECT rental_year, rental_month, active_user, 
   LAG(active_user) OVER (ORDER BY rental_year, rental_month) as Last_month
FROM cte_active_users
)
SELECT *, concat(round((active_user - last_month)/active_user*100), "%") as Percentage_diff
FROM cte_active_users_prev_month;

#Retained customers every month.

WITH cte_rental as (
	SELECT customer_id, DATE_FORMAT(convert(rental_date,date), '%Y-%m-%d') as rental_date,
		DATE_FORMAT(convert(rental_date,date), '%Y') as rental_year,
		DATE_FORMAT(convert(rental_date,date), '%m') as rental_month
	FROM rental
), cte_distinct_user as (
	SELECT distinct
		customer_id AS unique_active_user,
		rental_year,
		rental_month
	FROM cte_rental
	ORDER BY rental_year, rental_month
)
SELECT du1.unique_active_user, du1.rental_year, du1.rental_month, du2.rental_month as previous_month
from cte_distinct_user du1
join cte_distinct_user du2
on du1.rental_year = du2.rental_year 
and du1.rental_month = du2.rental_month+1 
and du1.unique_active_user = du2.unique_active_user 
order by du1.unique_active_user, du1.rental_year, du1.rental