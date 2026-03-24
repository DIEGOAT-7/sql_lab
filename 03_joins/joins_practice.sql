-- ============================================================
-- 03 · JOINs
-- Conceptos: INNER JOIN, LEFT JOIN, multi-table JOIN,
--            diferencia entre WHERE y HAVING con JOINs
-- Dataset: Sakila
-- ============================================================

USE sakila;

-- ─────────────────────────────────────────────────────────────
-- INNER JOIN — solo filas con coincidencia en ambas tablas
-- ─────────────────────────────────────────────────────────────

-- Clientes y sus fechas de alquiler del 14 de junio 2005
SELECT c.first_name, c.last_name, TIME(r.rental_date) AS rental_time
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
WHERE DATE(r.rental_date) = '2005-06-14'
ORDER BY rental_time;

-- Clientes con al menos 40 alquileres
-- HAVING filtra sobre el resultado del GROUP BY (no WHERE, que filtra filas)
SELECT c.first_name, c.last_name, COUNT(*) AS total_rentals
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(*) >= 40
ORDER BY total_rentals DESC;

-- ─────────────────────────────────────────────────────────────
-- LEFT JOIN — todas las filas del lado izquierdo,
--             NULL donde no hay coincidencia en el derecho
-- ─────────────────────────────────────────────────────────────

-- Clientes que NUNCA han alquilado (si existieran)
-- LEFT JOIN + WHERE IS NULL = anti-join pattern
SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL;

-- ─────────────────────────────────────────────────────────────
-- Multi-table JOIN — la ruta estándar del schema Sakila
-- rental → inventory → film → film_category → category
-- ─────────────────────────────────────────────────────────────

-- ¿Qué categorías han alquilado los clientes que rentaron el 5 de julio 2005?
SELECT DISTINCT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    cat.name AS category
FROM customer c
INNER JOIN rental r     ON c.customer_id = r.customer_id
INNER JOIN inventory i  ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category cat ON fc.category_id = cat.category_id
WHERE DATE(r.rental_date) = '2005-07-05'
ORDER BY customer;

-- ─────────────────────────────────────────────────────────────
-- ERRORES COMUNES — para tener en mente
-- ─────────────────────────────────────────────────────────────

-- ❌ INCORRECTO: WHERE con OR de esta forma no funciona
-- WHERE last_name = 'WILLIAMS' OR 'DAVIS'
-- La segunda condición evalúa la cadena 'DAVIS' como booleano (siempre TRUE en MySQL)

-- ✅ CORRECTO:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name = 'WILLIAMS' OR last_name = 'DAVIS';

-- O con IN (más limpio cuando son muchos valores):
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name IN ('WILLIAMS', 'DAVIS');

-- ❌ INCORRECTO: WHERE no puede ir después de GROUP BY
-- SELECT ... FROM ... GROUP BY x WHERE condicion  ← syntax error

-- ✅ CORRECTO: HAVING filtra resultados agregados
SELECT c.customer_id, DATE(r.rental_date) AS rental_date, COUNT(*) AS rentals
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, DATE(r.rental_date)
HAVING DATE(r.rental_date) = '2005-07-05';
