-- Clientes que no han rentado en los últimos 6 meses
-- LEFT JOIN para incluir clientes sin ningún alquiler (rental_id = NULL)
USE sakila;

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    MAX(r.rental_date)                      AS last_rental_date
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, customer
HAVING last_rental_date < DATE_SUB(NOW(), INTERVAL 6 MONTH)
    OR last_rental_date IS NULL
ORDER BY last_rental_date ASC;
