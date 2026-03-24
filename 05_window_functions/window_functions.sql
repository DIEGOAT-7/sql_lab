-- ============================================================
-- 05 · Window Functions
-- Prerrequisito: 04_aggregations completado
--
-- La diferencia clave con GROUP BY:
--   GROUP BY colapsa filas → pierdes el detalle
--   OVER()   calcula sobre un conjunto → mantienes todas las filas
-- ============================================================

USE sakila;

-- ─────────────────────────────────────────────────────────────
-- RANK() OVER (PARTITION BY ... ORDER BY ...)
-- Rankea filas dentro de un grupo sin colapsarlas
--
-- RANK()       → deja huecos en empates (1, 1, 3, 4)
-- DENSE_RANK() → no deja huecos           (1, 1, 2, 3)
-- ROW_NUMBER() → número único siempre     (1, 2, 3, 4)
-- ─────────────────────────────────────────────────────────────

-- Top 3 películas por ingresos DENTRO de cada categoría
-- Con GROUP BY solo podríamos ver el top global

SELECT
    category,
    title,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM (
    SELECT
        c.name                  AS category,
        f.title,
        ROUND(SUM(p.amount), 2) AS revenue
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c       ON fc.category_id = c.category_id
    JOIN inventory i      ON f.film_id = i.film_id
    JOIN rental r         ON i.inventory_id = r.inventory_id
    JOIN payment p        ON r.rental_id = p.rental_id
    GROUP BY c.name, f.film_id, f.title
) base
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;


-- ─────────────────────────────────────────────────────────────
-- LAG() / LEAD() — acceder a la fila anterior / siguiente
-- Ideal para comparaciones periodo-a-periodo
-- ─────────────────────────────────────────────────────────────

-- Crecimiento de ingresos mes a mes (MoM growth %)
-- Sin window functions esto requeriría un self-join

SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)             AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100
    , 2)                                            AS mom_growth_pct
FROM (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        ROUND(SUM(amount), 2)              AS revenue
    FROM payment
    GROUP BY month
) monthly
ORDER BY month;


-- ─────────────────────────────────────────────────────────────
-- NTILE(n) — dividir en n grupos de igual tamaño
-- Útil para segmentación de clientes
-- ─────────────────────────────────────────────────────────────

-- Segmentar clientes en cuartiles por gasto total
-- Cuartil 1 = top 25% (VIP), Cuartil 4 = bottom 25% (riesgo de churn)

SELECT
    customer_id,
    customer,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC)       AS quartile,
    CASE NTILE(4) OVER (ORDER BY total_spent DESC)
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Regular'
        WHEN 3 THEN 'Occasional'
        WHEN 4 THEN 'At Risk'
    END                                             AS segment
FROM (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        ROUND(SUM(p.amount), 2)                AS total_spent
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, customer
) customer_revenue
ORDER BY total_spent DESC;


-- ─────────────────────────────────────────────────────────────
-- ROW_NUMBER() — número de fila único dentro de una partición
-- Patrón clásico: obtener el último (o primero) registro por grupo
-- ─────────────────────────────────────────────────────────────

-- Última película rentada por cada cliente
-- Con MAX(rental_date) + JOIN pierdes el título; con ROW_NUMBER no

SELECT customer_id, title, rental_date
FROM (
    SELECT
        r.customer_id,
        f.title,
        r.rental_date,
        ROW_NUMBER() OVER (
            PARTITION BY r.customer_id
            ORDER BY r.rental_date DESC
        )                   AS rn
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f      ON i.film_id = f.film_id
) last_rentals
WHERE rn = 1
ORDER BY customer_id;


-- ─────────────────────────────────────────────────────────────
-- SUM() OVER — acumulados (running totals)
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- = desde el inicio hasta la fila actual
-- ─────────────────────────────────────────────────────────────

-- Ingresos acumulados mes a mes

SELECT
    month,
    revenue,
    SUM(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                       AS cumulative_revenue
FROM (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        ROUND(SUM(amount), 2)              AS revenue
    FROM payment
    GROUP BY month
) monthly
ORDER BY month;


-- ─────────────────────────────────────────────────────────────
-- AVG() OVER con frame — promedio móvil
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
-- = promedio de los últimos 3 meses (incluye el actual)
-- Suaviza variaciones y revela tendencias reales
-- ─────────────────────────────────────────────────────────────

-- Promedio móvil de 3 meses para ingresos

SELECT
    month,
    revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )
    , 2)                    AS moving_avg_3m
FROM (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        ROUND(SUM(amount), 2)              AS revenue
    FROM payment
    GROUP BY month
) monthly
ORDER BY month;


-- ─────────────────────────────────────────────────────────────
-- PERCENT_RANK() — percentil de cada fila (0.0 a 1.0)
-- ¿En qué percentil está cada película por ingresos?
-- ─────────────────────────────────────────────────────────────

SELECT
    title,
    revenue,
    ROUND(PERCENT_RANK() OVER (ORDER BY revenue) * 100, 1) AS percentile
FROM (
    SELECT
        f.title,
        ROUND(SUM(p.amount), 2) AS revenue
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r    ON i.inventory_id = r.inventory_id
    JOIN payment p   ON r.rental_id = p.rental_id
    GROUP BY f.film_id, f.title
) film_revenue
ORDER BY percentile DESC
LIMIT 20;
