SELECT first_name, last_name
FROM customer
WHERE last_name = 'ZIEGLER';

--- The next query demonstrates the use of a table column, a literal, 
--- an expression, and a built-in function call in a single query against the employee table:

SELECT language_id,
 'COMMON' language_usage,
 language_id * 3.1415927 lang_pi_value,
 upper(name) language_name
FROM language;

--- execute a built-in function or evaluate a simple expression, 
--- you can skip the from clause entirely

SELECT version(),
  user(),
  database();
--

SELECT concat(cust.last_name, ', ', cust.first_name) full_name
FROM
    (SELECT first_name, last_name, email
    FROM customer
    WHERE first_name = 'JESSIE'
    ) cust;

---

SELECT DISTINCT
    a.actor_id,
    a.first_name,
    a.last_name,
    c.category_id,
    c.name AS category_name
FROM actor a
JOIN film_actor fa
    ON a.actor_id = fa.actor_id
JOIN film f
    ON fa.film_id = f.film_id
JOIN film_category fc
    ON f.film_id = fc.film_id
JOIN category c
    ON fc.category_id = c.category_id;

----

-- ver todo el mapa relacional de la base de datos 

SELECT
    table_name,
    column_name,
    referenced_table_name,
    referenced_column_name
FROM information_schema.KEY_COLUMN_USAGE
WHERE table_schema = DATABASE()
  AND referenced_table_name IS NOT NULL
ORDER BY table_name;
