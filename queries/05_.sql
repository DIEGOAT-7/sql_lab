-- Películas que generan ingresos altos pero se rentan poco

SELECT
    f.title,
    COUNT(r.rental_id) AS total_rentals,
    SUM(p.amount) AS revenue
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.title
HAVING total_rentals < 20
ORDER BY revenue DESC
LIMIT 10;