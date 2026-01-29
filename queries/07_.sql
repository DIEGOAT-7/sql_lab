-- Ingresos mensuales con crecimiento vs mes anterior

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(amount) AS revenue
FROM payment
GROUP BY month
ORDER BY month;
