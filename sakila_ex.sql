SELECT c.first_name, c.last_name, COUNT(*)
FROM customer c
  INNER JOIN rental r
   ON C.customer_id = r.customer_id
GROUP BY c.first_name, C.last_name
HAVING COUNT(*) >= 40;


SELECT c.first_name, c.last_name, time(r.rental_date) rental_time
FROM customer c
  INNER JOIN rental r
  ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-06-14';

-- Exercise
--Retrieve the actor ID, first name, and last name for all actors. Sort by 
--last name and then by first name.

SELECT actor_id, first_name, last_name
FROM actor
GROUP BY actor_id
ORDER BY last_name, first_name;


SELECT actor_id, first_name, last_name
FROM actor 
WHERE last_name = 'WILLIAMS' OR 'DAVIS'
GROUP BY actor_id;

--

SELECT DISTINCT c.customer_id, date(r.rental_date)
FROM customer c
  INNER JOIN rental r
  ON c.customer_id = r.customer_id
WHERE date(r.rental_date) = '2005-07-05';


SELECT c.customer_id, date(r.rental_date)
FROM customer c
  INNER JOIN rental r  
  ON c.customer_id = r.customer_id
GROUP BY c.customer_id
WHERE date(r.rental_date) = '2005-07-05';

----

--Top clientes por volumen de alquilereS

SELECT c.customer_id,  c.first_name, c.last_name, COUNT(r.rental_id) AS 
total_rentals
FROM customer c
  INNER JOIN rental r
  ON c.customer_id = r.customer_id
GROUP BY  c.customer_id
ORDER BY COUNT(r.rental_id) DESC;

----

SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS 
total_payment
FROM staff s
  INNER JOIN payment p
  ON s.staff_id = p.staff_id
GROUP BY s.staff_id
ORDER BY total_payment DESC;

---

--- Ejercicio 3 – Clientes valiosos
-- Obtén los clientes que hayan gastado más de $100 en total.

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS 
total_spend
FROM customer c
  INNER JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING total_spend >= 100
ORDER BY total_spend DESC;

--------

-- Categorías más rentadas
-- Calcula cuántas veces se ha rentado cada categoría de película.

SELECT c.name AS category_name, COUNT(r.rental_id) AS total_rentals
FROM rental r
  INNER JOIN inventory i
  ON r.inventory_id = i.inventory_id
  INNER JOIN film f
  ON i.film_id = f.film_id
  INNER JOIN film_category fc
  ON f.film_id = fc.film_id
  INNER JOIN category c
  ON fc.category_id = c.category_id
GROUP BY category_name
ORDER BY total_rentals DESC;