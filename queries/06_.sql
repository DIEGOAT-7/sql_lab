-- Clientes inactivos (no alquilan hace 6 meses)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    MAX(r.rental_date) AS last_rental_date
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, customer
HAVING last_rental_date < DATE_SUB(MAX(last_rental_date), INTERVAL 6 MONTH)
   OR last_rental_date IS NULL;
