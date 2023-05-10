-- Case Study #1 - Danny's Diner
-- https://8weeksqlchallenge.com/case-study-1/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id
	,sum(m.price) AS amount_spent
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY s.customer_id

--2. How many days has each customer visited the restaurant?
SELECT s.customer_id
	,count(DISTINCT s.order_date) AS days_visited
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY s.customer_id;

--3. What was the first item from the menu purchased by each customer?
WITH ordered_sale
AS (
	SELECT s.customer_id
		,s.order_date
		,m.product_name
		,DENSE_RANK() OVER (
			PARTITION BY s.customer_id ORDER BY s.order_date
			) AS rnk
	FROM menu m
	JOIN sales s ON m.product_id = s.product_id
	)
SELECT customer_id
	,string_agg(product_name, ' ,')
FROM ordered_sale
WHERE rnk = 1
GROUP BY customer_id

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 m.product_name
	,count(s.order_date) AS Frequency
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY Frequency DESC

--5 Which item was the most popular for each customer?
WITH cte AS (
		SELECT s.customer_id
			,m.product_name
			,count(m.product_id) No_of_order
			,dense_rank() OVER (
				PARTITION BY s.customer_id ORDER BY count(s.customer_id) DESC
				) AS rnk
		FROM menu m
		JOIN sales s ON m.product_id = s.product_id
		GROUP BY s.customer_id
			,m.product_name
		)

SELECT customer_id
	,product_name
	,no_of_order
FROM cte
WHERE rnk = 1

--6 Which item was purchased first by the customer after they became a member?
WITH cte AS (
		SELECT m.customer_id
			,menu.product_name
			,s.order_date
			,DENSE_RANK() OVER (
				PARTITION BY m.customer_id ORDER BY s.order_date
				) AS rnk
		FROM members m
		JOIN sales s ON m.customer_id = s.customer_id
		JOIN menu ON menu.product_id = s.product_id
		GROUP BY m.customer_id
			,menu.product_name
			,s.order_date
		)

SELECT customer_id
	,STRING_AGG(product_name, ' ,') AS first_product
FROM cte
WHERE rnk = 1
GROUP BY customer_id


--7 Which item was purchased just before the customer became a member?
WITH cte AS (
		SELECT s.customer_id
			,m.join_date
			,s.order_date
			,s.product_id
			,DENSE_RANK() OVER (
				PARTITION BY s.customer_id ORDER BY s.order_date DESC
				) AS rnk
		FROM sales s
		JOIN members m ON m.customer_id = s.customer_id
		WHERE m.join_date > s.order_date
		)

SELECT c.customer_id
	,STRING_AGG(m.product_name, ' ,') Item_before_join
FROM cte c
JOIN menu m ON c.product_id = m.product_id
WHERE c.rnk = 1
GROUP BY c.customer_id

--8 What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id
	,count(DISTINCT menu.product_id) AS total_items
	,CONCAT (
		sum(menu.price)
		,' $'
		) AS Total_amount
FROM members m
JOIN sales s ON m.customer_id = s.customer_id
JOIN menu ON menu.product_id = s.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id


--9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH cte AS (
		SELECT *
			,CASE 
				WHEN product_name = 'sushi'
					THEN price * 20
				ELSE price * 10
				END AS points
		FROM menu
		)

SELECT customer_id
	,sum(points) AS Total_points
FROM cte c
JOIN sales s ON c.product_id = s.product_id
GROUP BY customer_id


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?
WITH cte AS (
		SELECT s.customer_id
			,menu.price
			,s.order_date
			,m.join_date
			,menu.product_name
			,CASE 
				WHEN menu.product_name <> 'shushi'
					AND s.order_date BETWEEN m.join_date
						AND DATEADD(day, 6, m.join_date)
					THEN menu.price * 2
						--when s.order_date > DATEADD(day,6,m.join_date) 
						--then menu.price
				ELSE menu.price
				END AS points
		FROM members m
		JOIN sales s ON m.customer_id = s.customer_id
		JOIN menu ON menu.product_id = s.product_id
		WHERE s.order_date BETWEEN '2021-1-1'
				AND '2021-1-31'
			AND s.customer_id IN (
				'A'
				,'B'
				)
		)

SELECT customer_id
	,sum(points) AS total_points
FROM cte
GROUP BY customer_id

-- # Bonus Questions

--Recreate the following table output using the available data:
-- customer_id	order_date	product_name	price	member
--	A			2021-01-01		curry			15		N
--	A			2021-01-01		sushi			10		N
SELECT s.customer_id
	,s.order_date
	,menu.product_name
	,menu.price
	,CASE 
		WHEN m.join_date <= s.order_date
			THEN 'Y'
		ELSE 'N'
		END AS Member
FROM members m
RIGHT JOIN sales s ON m.customer_id = s.customer_id
RIGHT JOIN menu ON menu.product_id = s.product_id
ORDER BY s.customer_id
	,s.order_date

-- Rank All The Things, for non-members set rank - null
WITH cte AS (
		SELECT s.customer_id
			,s.order_date
			,menu.product_name
			,menu.price
			,CASE 
				WHEN m.join_date <= s.order_date
					THEN 'Y'
				ELSE 'N'
				END AS Member
		FROM members m
		RIGHT JOIN sales s ON m.customer_id = s.customer_id
		RIGHT JOIN menu ON menu.product_id = s.product_id
		)

--order by s.customer_id, s.order_date
SELECT *
	,CASE 
		WHEN member = 'N'
			THEN NULL
		ELSE RANK() OVER (
				PARTITION BY customer_id
				,member ORDER BY order_date
				)
		END AS ranking
FROM cte
