/* TASK:  Use Common Table Expressions (CTEs) to figure out how many of the top 5 customers are based within each country. */

WITH top_ten_countries_cte (
	country_id,
	country
) AS
(
	SELECT
		D.country_id,
		D.country
	FROM
		customer A
	INNER JOIN address B ON
		A.address_id = B.address_id
	INNER JOIN city C ON
		B.city_id = C.city_id
	INNER JOIN country D ON
		C.country_id = D.country_id
	GROUP BY
		D.country_id,
		D.country
	ORDER BY
		COUNT(A.customer_id) DESC
	LIMIT 10
),
top_ten_cities_cte (
	city_id,
	city,
	country
) AS
(
	SELECT
		C.city_id,
		C.city,
		T.country
	FROM
		customer A
	INNER JOIN address B ON
		A.address_id = B.address_id
	INNER JOIN city C ON
		B.city_id = C.city_id
	INNER JOIN top_ten_countries_cte T ON
		C.country_id = T.country_id
	GROUP BY
		C.city_id,
		C.city,
		T.country
	ORDER BY
		COUNT(A.customer_id) DESC
	LIMIT 10
),
total_amount_paid (
	customer_id,
	first_name,
	last_name,
	city,
	country,
	total_amt_paid
) AS
(
	SELECT
		A.customer_id,
		A.first_name,
		A.last_name,
		U.city,
		U.country,
		SUM(P.amount) AS total_amt_paid
	FROM
		customer A
	INNER JOIN payment P ON
		A.customer_id = P.customer_id
	INNER JOIN address B ON
		A.address_id = B.address_id
	INNER JOIN top_ten_cities U ON
		B.city_id = U.city_id
	GROUP BY
		A.customer_id,
		A.first_name,
		A.last_name,
		U.city,
		U.country
	ORDER BY
		total_amt_paid DESC
	LIMIT 5
)
SELECT
	D.country,
	COUNT(DISTINCT A.customer_id) AS all_customer_count,
	COUNT(DISTINCT T.customer_id) AS top_customer_count
FROM
	customer A
INNER JOIN address B ON
	A.address_id = B.address_id
INNER JOIN city C ON
	B.city_id = C.city_id
INNER JOIN country D ON
	C.country_id = D.country_id
INNER JOIN total_amount_paid T ON
	D.country = T.country
GROUP BY
	D.country;
