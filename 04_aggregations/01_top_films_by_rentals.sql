-- Top 10 películas más rentadas
USE sakila;

SELECT
    f.title,
    COUNT(r.rental_id) AS total_rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r    ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY total_rentals DESC
LIMIT 10;
