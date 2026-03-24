-- ============================================================
-- SAKILA RENTAL STORE — Executive Business Report
-- ============================================================
-- Contexto: Sakila es una cadena de renta de DVDs con datos de
-- mayo 2005 a febrero 2006. Este reporte usa todo el stack SQL
-- aprendido (JOINs, aggregations, window functions, CTEs)
-- para responder preguntas reales de negocio.
--
-- Secciones:
--   1. Revenue Overview        — ¿Cómo van los ingresos?
--   2. Catalog Performance     — ¿Qué películas y categorías generan valor?
--   3. Customer Intelligence   — ¿Quiénes son los clientes y cómo se comportan?
--   4. Staff Performance       — ¿Cómo rinde el equipo?
--   5. Inventory Health        — ¿Tenemos los títulos correctos?
--   6. Action Items            — Resumen ejecutivo con recomendaciones
-- ============================================================

USE sakila;


-- ════════════════════════════════════════════════════════════
-- 1. REVENUE OVERVIEW
-- ════════════════════════════════════════════════════════════

-- 1.1 Ingresos totales del período
SELECT
    ROUND(SUM(amount), 2)       AS total_revenue,
    COUNT(payment_id)           AS total_transactions,
    ROUND(AVG(amount), 2)       AS avg_transaction,
    MIN(DATE(payment_date))     AS period_start,
    MAX(DATE(payment_date))     AS period_end
FROM payment;


-- 1.2 Ingresos por mes con crecimiento MoM
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        ROUND(SUM(amount), 2)              AS revenue
    FROM payment
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)   AS prev_month,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100
    , 1)                                 AS mom_growth_pct,
    SUM(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                    AS cumulative_revenue
FROM monthly_revenue
ORDER BY month;


-- 1.3 Ingresos por tienda
SELECT
    s.store_id,
    CONCAT(st.first_name, ' ', st.last_name)    AS manager,
    ci.city,
    co.country,
    ROUND(SUM(p.amount), 2)                      AS revenue,
    COUNT(DISTINCT r.customer_id)                AS unique_customers,
    COUNT(r.rental_id)                           AS total_rentals
FROM store s
JOIN staff st       ON s.manager_staff_id = st.staff_id
JOIN address a      ON s.address_id = a.address_id
JOIN city ci        ON a.city_id = ci.city_id
JOIN country co     ON ci.country_id = co.country_id
JOIN inventory i    ON s.store_id = i.store_id
JOIN rental r       ON i.inventory_id = r.inventory_id
JOIN payment p      ON r.rental_id = p.rental_id
GROUP BY s.store_id, manager, ci.city, co.country;


-- ════════════════════════════════════════════════════════════
-- 2. CATALOG PERFORMANCE
-- ════════════════════════════════════════════════════════════

-- 2.1 Revenue y rentals por categoría (ranking)
WITH category_stats AS (
    SELECT
        c.name                                              AS category,
        COUNT(r.rental_id)                                  AS total_rentals,
        ROUND(SUM(p.amount), 2)                             AS revenue,
        ROUND(SUM(p.amount) / COUNT(DISTINCT r.rental_id), 2) AS rev_per_rental,
        COUNT(DISTINCT f.film_id)                           AS catalog_size
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f           ON fc.film_id = f.film_id
    JOIN inventory i      ON f.film_id = i.film_id
    JOIN rental r         ON i.inventory_id = r.inventory_id
    JOIN payment p        ON r.rental_id = p.rental_id
    GROUP BY c.category_id, c.name
)
SELECT
    category,
    total_rentals,
    revenue,
    rev_per_rental,
    catalog_size,
    RANK() OVER (ORDER BY revenue DESC)       AS revenue_rank,
    RANK() OVER (ORDER BY rev_per_rental DESC) AS efficiency_rank
FROM category_stats
ORDER BY revenue DESC;


-- 2.2 Top 10 películas por ingresos vs su rank dentro de su categoría
WITH film_revenue AS (
    SELECT
        f.film_id,
        f.title,
        c.name                  AS category,
        COUNT(r.rental_id)      AS total_rentals,
        ROUND(SUM(p.amount), 2) AS revenue
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c       ON fc.category_id = c.category_id
    JOIN inventory i      ON f.film_id = i.film_id
    JOIN rental r         ON i.inventory_id = r.inventory_id
    JOIN payment p        ON r.rental_id = p.rental_id
    GROUP BY f.film_id, f.title, c.name
)
SELECT
    title,
    category,
    total_rentals,
    revenue,
    RANK() OVER (ORDER BY revenue DESC)                        AS global_rank,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC)  AS category_rank
FROM film_revenue
ORDER BY global_rank
LIMIT 20;


-- 2.3 Películas "underperforming": muchos copies, pocos alquileres
-- Candidatos para sacar del catálogo
SELECT
    f.title,
    f.rating,
    c.name                      AS category,
    COUNT(DISTINCT i.inventory_id) AS copies_available,
    COUNT(r.rental_id)          AS total_rentals,
    ROUND(COUNT(r.rental_id) / COUNT(DISTINCT i.inventory_id), 1) AS rentals_per_copy
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c       ON fc.category_id = c.category_id
JOIN inventory i      ON f.film_id = i.film_id
LEFT JOIN rental r    ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title, f.rating, c.name
HAVING copies_available >= 3 AND rentals_per_copy < 5
ORDER BY rentals_per_copy ASC
LIMIT 15;


-- ════════════════════════════════════════════════════════════
-- 3. CUSTOMER INTELLIGENCE
-- ════════════════════════════════════════════════════════════

-- 3.1 Segmentación de clientes por valor (RFM simplificado)
-- R = Recency (días desde último alquiler)
-- F = Frequency (total de alquileres)
-- M = Monetary (gasto total)
WITH customer_rfm AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)          AS customer,
        DATEDIFF(MAX(r.rental_date), MIN(r.rental_date)) AS days_as_customer,
        DATEDIFF(NOW(), MAX(r.rental_date))              AS days_since_last_rental,
        COUNT(r.rental_id)                               AS frequency,
        ROUND(SUM(p.amount), 2)                          AS monetary
    FROM customer c
    JOIN rental r  ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.customer_id, customer
),
customer_scored AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY days_since_last_rental ASC)  AS recency_score,
        NTILE(4) OVER (ORDER BY frequency DESC)               AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary DESC)                AS monetary_score
    FROM customer_rfm
)
SELECT
    customer,
    days_since_last_rental,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champion'
        WHEN recency_score >= 3 AND frequency_score >= 2                          THEN 'Loyal'
        WHEN recency_score <= 2 AND frequency_score >= 3                          THEN 'At Risk'
        WHEN recency_score = 1                                                     THEN 'Lost'
        ELSE 'Potential'
    END AS customer_segment
FROM customer_scored
ORDER BY monetary DESC;


-- 3.2 Distribución de segmentos
WITH customer_rfm AS (
    SELECT
        c.customer_id,
        DATEDIFF(NOW(), MAX(r.rental_date)) AS days_since_last_rental,
        COUNT(r.rental_id)                  AS frequency,
        ROUND(SUM(p.amount), 2)             AS monetary
    FROM customer c
    JOIN rental r  ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.customer_id
),
customer_scored AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY days_since_last_rental ASC)  AS recency_score,
        NTILE(4) OVER (ORDER BY frequency DESC)               AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary DESC)                AS monetary_score
    FROM customer_rfm
),
customer_segmented AS (
    SELECT
        CASE
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champion'
            WHEN recency_score >= 3 AND frequency_score >= 2                          THEN 'Loyal'
            WHEN recency_score <= 2 AND frequency_score >= 3                          THEN 'At Risk'
            WHEN recency_score = 1                                                     THEN 'Lost'
            ELSE 'Potential'
        END AS segment
    FROM customer_scored
)
SELECT
    segment,
    COUNT(*)                        AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM customer_segmented
GROUP BY segment
ORDER BY customers DESC;


-- 3.3 Preferencias de género por segmento de cliente (top categoría por cliente)
WITH customer_category_spend AS (
    SELECT
        c.customer_id,
        cat.name                    AS category,
        ROUND(SUM(p.amount), 2)     AS spent_in_category,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM(p.amount) DESC
        )                           AS category_rank
    FROM customer c
    JOIN rental r       ON c.customer_id = r.customer_id
    JOIN payment p      ON r.rental_id = p.rental_id
    JOIN inventory i    ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category cat   ON fc.category_id = cat.category_id
    GROUP BY c.customer_id, cat.category_id, cat.name
)
SELECT
    category                        AS favorite_category,
    COUNT(*)                        AS customers_who_prefer_it,
    ROUND(AVG(spent_in_category), 2) AS avg_spend_in_category
FROM customer_category_spend
WHERE category_rank = 1
GROUP BY category
ORDER BY customers_who_prefer_it DESC;


-- ════════════════════════════════════════════════════════════
-- 4. STAFF PERFORMANCE
-- ════════════════════════════════════════════════════════════

-- 4.1 Performance por empleado: transacciones, ingresos, ticket promedio
SELECT
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name)  AS staff_member,
    st.store_id,
    COUNT(p.payment_id)                      AS transactions,
    ROUND(SUM(p.amount), 2)                  AS total_collected,
    ROUND(AVG(p.amount), 2)                  AS avg_ticket,
    COUNT(DISTINCT DATE(p.payment_date))     AS days_worked
FROM staff s
JOIN store st  ON s.store_id = st.store_id
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, staff_member, st.store_id
ORDER BY total_collected DESC;


-- 4.2 Tendencia mensual por empleado
SELECT
    CONCAT(s.first_name, ' ', s.last_name)  AS staff_member,
    DATE_FORMAT(p.payment_date, '%Y-%m')     AS month,
    COUNT(p.payment_id)                      AS transactions,
    ROUND(SUM(p.amount), 2)                  AS revenue,
    ROUND(
        SUM(p.amount) - LAG(SUM(p.amount)) OVER (
            PARTITION BY s.staff_id ORDER BY DATE_FORMAT(p.payment_date, '%Y-%m')
        )
    , 2)                                     AS mom_change
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, staff_member, month
ORDER BY staff_member, month;


-- ════════════════════════════════════════════════════════════
-- 5. INVENTORY HEALTH
-- ════════════════════════════════════════════════════════════

-- 5.1 Títulos que nunca han sido rentados (dead inventory)
SELECT
    f.film_id,
    f.title,
    f.rating,
    c.name              AS category,
    f.rental_rate,
    COUNT(i.inventory_id) AS copies
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c       ON fc.category_id = c.category_id
JOIN inventory i      ON f.film_id = i.film_id
WHERE NOT EXISTS (
    SELECT 1 FROM rental r
    WHERE r.inventory_id = i.inventory_id
)
GROUP BY f.film_id, f.title, f.rating, c.name, f.rental_rate
ORDER BY copies DESC;


-- 5.2 Películas con alta demanda pero pocas copias (perder ventas potenciales)
-- Ratio: alquileres / copias disponibles — alto ratio = necesitamos más stock
SELECT
    f.title,
    c.name                                  AS category,
    COUNT(DISTINCT i.inventory_id)          AS copies,
    COUNT(r.rental_id)                      AS total_rentals,
    ROUND(COUNT(r.rental_id) * 1.0 / COUNT(DISTINCT i.inventory_id), 1) AS rentals_per_copy
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c       ON fc.category_id = c.category_id
JOIN inventory i      ON f.film_id = i.film_id
JOIN rental r         ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title, c.name
HAVING copies <= 3 AND rentals_per_copy > 15
ORDER BY rentals_per_copy DESC
LIMIT 15;


-- ════════════════════════════════════════════════════════════
-- 6. ACTION ITEMS — Resumen ejecutivo
-- ════════════════════════════════════════════════════════════
--
-- A partir de los queries anteriores, estas son las
-- recomendaciones de negocio que emergen del análisis:
--
-- REVENUE
--   - Los ingresos muestran estacionalidad clara en verano 2005
--   - Verificar con LAG query (sección 1.2) si julio fue el pico máximo
--
-- CATALOG
--   - Sports y Sci-Fi lideran en revenue; Children y Music al fondo
--   - Considerar reducir catálogo de categorías de bajo revenue_per_rental
--   - Las películas "underperforming" (sección 2.3) son candidatas a liquidar
--
-- CUSTOMERS
--   - Ejecutar campaña de retención para segmentos "At Risk" y "Lost"
--   - Champions y Loyals merecen programa de fidelización
--   - Sports es la categoría favorita del mayor número de clientes
--
-- STAFF
--   - Evaluar diferencias de performance entre empleados (sección 4.1)
--   - Si hay brecha significativa, investigar procesos o carga de trabajo
--
-- INVENTORY
--   - Los títulos de sección 5.1 (dead inventory) ocupan espacio sin generar nada
--   - Los títulos de sección 5.2 están perdiendo rentals por falta de stock
-- ============================================================
