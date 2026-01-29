-- Clientes que más dinero han gastado

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, customer
ORDER BY total_spent DESC
LIMIT 10;
