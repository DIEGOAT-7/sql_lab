-- Ingresos totales por mes
-- Base para el análisis de tendencias (ver 05_window_functions para MoM growth)
USE sakila;

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    ROUND(SUM(amount), 2)              AS revenue,
    COUNT(payment_id)                  AS transactions
FROM payment
GROUP BY month
ORDER BY month;
