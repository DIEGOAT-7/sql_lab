-- ============================================================
-- 06 · Subqueries y CTEs
-- Prerrequisito: 05_window_functions completado
--
-- Subquery: query dentro de otra query
-- CTE (WITH): subquery con nombre — más legible, reutilizable
--             en el mismo query, y en MySQL 8+ soporta recursión
-- ============================================================

USE sakila;

-- ─────────────────────────────────────────────────────────────
-- CTE básico — WITH nombre AS (query) SELECT ...
-- Hace el código legible; ejecuta igual que una subquery en FROM
-- ─────────────────────────────────────────────────────────────

-- Refactorización del query de categorías (02_revenue_by_category)
-- usando CTEs para separar la lógica

WITH rental_payments AS (
    SELECT
        r.rental_id,
        i.film_id,
        p.amount
    FROM rental r
    JOIN payment p   ON r.rental_id = p.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
),
film_with_category AS (
    SELECT
        f.film_id,
        f.title,
        c.name AS category
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c       ON fc.category_id = c.category_id
)
SELECT
    fc.category,
    COUNT(rp.rental_id)         AS total_rentals,
    ROUND(SUM(rp.amount), 2)    AS revenue,
    ROUND(SUM(rp.amount) / COUNT(rp.rental_id), 2) AS revenue_per_rental
FROM film_with_category fc
JOIN rental_payments rp ON fc.film_id = rp.film_id
GROUP BY fc.category
ORDER BY revenue DESC;


-- ─────────────────────────────────────────────────────────────
-- CTEs múltiples encadenados
-- Cada CTE puede referenciar los CTEs anteriores
-- ─────────────────────────────────────────────────────────────

-- Segmentación de riesgo de churn con múltiples CTEs
-- Paso 1: métricas base por cliente
-- Paso 2: calcular ratio de actividad
-- Paso 3: clasificar y filtrar

WITH customer_activity AS (
    SELECT
        r.customer_id,
        COUNT(r.rental_id)      AS total_rentals,
        MAX(r.rental_date)      AS last_rental,
        MIN(r.rental_date)      AS first_rental
    FROM rental r
    GROUP BY r.customer_id
),
customer_metrics AS (
    SELECT
        ca.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        ca.total_rentals,
        ca.last_rental,
        DATEDIFF(ca.last_rental, ca.first_rental)          AS days_active,
        ROUND(
            ca.total_rentals
            / NULLIF(DATEDIFF(ca.last_rental, ca.first_rental), 0)
            * 30
        , 2)                                               AS rentals_per_month
    FROM customer_activity ca
    JOIN customer c ON ca.customer_id = c.customer_id
),
churn_classification AS (
    SELECT
        *,
        CASE
            WHEN last_rental < DATE_SUB(NOW(), INTERVAL 4 MONTH)
             AND rentals_per_month > 2  THEN 'High Churn Risk'
            WHEN last_rental < DATE_SUB(NOW(), INTERVAL 2 MONTH) THEN 'Medium Churn Risk'
            ELSE 'Active'
        END AS churn_status
    FROM customer_metrics
)
SELECT customer, total_rentals, last_rental, rentals_per_month, churn_status
FROM churn_classification
WHERE churn_status != 'Active'
ORDER BY rentals_per_month DESC;


-- ─────────────────────────────────────────────────────────────
-- Subquery escalar — devuelve un solo valor
-- Se puede usar en SELECT, WHERE, HAVING
-- ─────────────────────────────────────────────────────────────

-- Cada cliente comparado contra el promedio global de gasto

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer,
    ROUND(SUM(p.amount), 2)                 AS total_spent,
    (SELECT ROUND(AVG(total), 2)
     FROM (SELECT SUM(amount) AS total
           FROM payment GROUP BY customer_id) avg_sub) AS global_avg,
    CASE
        WHEN SUM(p.amount) > (SELECT AVG(total)
                              FROM (SELECT SUM(amount) AS total
                                    FROM payment GROUP BY customer_id) sub2)
        THEN 'Above Average'
        ELSE 'Below Average'
    END                                     AS vs_average
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, customer
ORDER BY total_spent DESC
LIMIT 20;


-- ─────────────────────────────────────────────────────────────
-- EXISTS — más eficiente que IN para subqueries grandes
-- IN evalúa toda la lista; EXISTS para en el primer match
-- ─────────────────────────────────────────────────────────────

-- Clientes que han rentado al menos una película de 'Action'
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM rental r
    JOIN inventory i    ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category cat   ON fc.category_id = cat.category_id
    WHERE r.customer_id = c.customer_id
      AND cat.name = 'Action'
)
ORDER BY customer;

-- Versión equivalente con IN (mismos resultados, diferente plan de ejecución):
-- WHERE customer_id IN (
--     SELECT DISTINCT r.customer_id FROM rental r
--     JOIN inventory i ON r.inventory_id = i.inventory_id
--     JOIN film_category fc ON i.film_id = fc.film_id
--     JOIN category cat ON fc.category_id = cat.category_id
--     WHERE cat.name = 'Action'
-- )


-- ─────────────────────────────────────────────────────────────
-- CTE + Window Function juntos — el combo más potente
-- ─────────────────────────────────────────────────────────────

-- Clasificar películas por tier de rendimiento dentro de su categoría

WITH film_revenue AS (
    SELECT
        f.film_id,
        f.title,
        c.name                  AS category,
        ROUND(SUM(p.amount), 2) AS revenue,
        COUNT(r.rental_id)      AS total_rentals
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c       ON fc.category_id = c.category_id
    JOIN inventory i      ON f.film_id = i.film_id
    JOIN rental r         ON i.inventory_id = r.inventory_id
    JOIN payment p        ON r.rental_id = p.rental_id
    GROUP BY f.film_id, f.title, c.name
),
film_ranked AS (
    SELECT
        *,
        NTILE(3) OVER (PARTITION BY category ORDER BY revenue DESC) AS tier
    FROM film_revenue
)
SELECT
    category,
    title,
    revenue,
    total_rentals,
    CASE tier
        WHEN 1 THEN 'Top Performer'
        WHEN 2 THEN 'Mid Tier'
        WHEN 3 THEN 'Underperformer'
    END AS performance_tier
FROM film_ranked
ORDER BY category, revenue DESC;
