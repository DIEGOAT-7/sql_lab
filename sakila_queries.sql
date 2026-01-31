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