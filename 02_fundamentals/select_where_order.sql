-- ============================================================
-- 02 · SELECT Fundamentals
-- Conceptos: SELECT, WHERE, ORDER BY, LIMIT, LIKE,
--            IN, BETWEEN, IS NULL, DISTINCT
-- Dataset: Sakila
-- ============================================================

USE sakila;

-- ─────────────────────────────────────────────────────────────
-- SELECT básico + ORDER BY
-- ─────────────────────────────────────────────────────────────

-- Todos los actores ordenados por apellido y luego por nombre
SELECT actor_id, first_name, last_name
FROM actor
ORDER BY last_name, first_name;

-- Top 10 películas más largas
SELECT title, length, rating
FROM film
ORDER BY length DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────
-- WHERE — filtros simples
-- ─────────────────────────────────────────────────────────────

-- Películas para todo público con duración de alquiler mayor a 5 días
SELECT title, rating, rental_duration, rental_rate
FROM film
WHERE rating = 'G'
  AND rental_duration > 5;

-- Películas PG o G (forma correcta con IN)
SELECT title, rating
FROM film
WHERE rating IN ('G', 'PG')
ORDER BY title;

-- ─────────────────────────────────────────────────────────────
-- LIKE — búsqueda por patrón
-- ─────────────────────────────────────────────────────────────

-- Actores cuyo nombre empieza con 'J'
SELECT first_name, last_name
FROM actor
WHERE first_name LIKE 'J%';

-- Películas que contienen 'LOVE' en el título
SELECT title
FROM film
WHERE title LIKE '%LOVE%';

-- ─────────────────────────────────────────────────────────────
-- BETWEEN — rangos
-- ─────────────────────────────────────────────────────────────

-- Películas de entre 90 y 120 minutos
SELECT title, length
FROM film
WHERE length BETWEEN 90 AND 120
ORDER BY length;

-- Pagos entre $4 y $6
SELECT payment_id, customer_id, amount, payment_date
FROM payment
WHERE amount BETWEEN 4.00 AND 6.00
ORDER BY amount;

-- ─────────────────────────────────────────────────────────────
-- IS NULL / IS NOT NULL
-- ─────────────────────────────────────────────────────────────

-- Clientes sin email registrado
SELECT customer_id, first_name, last_name
FROM customer
WHERE email IS NULL;

-- Películas sin descripción
SELECT title
FROM film
WHERE description IS NULL;

-- ─────────────────────────────────────────────────────────────
-- DISTINCT — valores únicos
-- ─────────────────────────────────────────────────────────────

-- ¿Qué ratings existen en el catálogo?
SELECT DISTINCT rating
FROM film
ORDER BY rating;

-- ¿En qué países hay clientes?
SELECT DISTINCT co.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
ORDER BY co.country;
