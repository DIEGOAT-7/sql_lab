-- Actores más rentables (no más populares)

SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS actor,
    ROUND(SUM(p.amount), 2) AS revenue
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN inventory i ON fa.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY actor
ORDER BY revenue DESC
LIMIT 10;
