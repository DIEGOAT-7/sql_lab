-- Ingreso promedio por alquiler por categoría

SELECT
    c.name AS category,
    ROUND(SUM(p.amount) / COUNT(DISTINCT r.rental_id), 2) AS avg_revenue_per_rental
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY avg_revenue_per_rental DESC;
