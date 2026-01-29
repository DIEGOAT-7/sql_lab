-- Categorías con alta demanda pero bajo ingreso

SELECT
    c.name AS category,
    COUNT(r.rental_id) AS total_rentals,
    ROUND(SUM(p.amount), 2) AS revenue,
    ROUND(SUM(p.amount) / COUNT(r.rental_id), 2) AS revenue_per_rental
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY revenue_per_rental ASC;
