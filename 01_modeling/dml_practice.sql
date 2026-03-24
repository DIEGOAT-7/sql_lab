-- ============================================================
-- 01 · DML Practice
-- Conceptos: INSERT, SELECT, UPDATE, DELETE, ORDER BY
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- INSERT
-- ─────────────────────────────────────────────────────────────

-- person_id = NULL porque la columna tiene AUTO_INCREMENT
INSERT INTO person (person_id, fname, lname, eye_color, birth_date)
VALUES (null, 'William', 'Turner', 'BR', '1997-05-27');

INSERT INTO person (person_id, fname, lname, eye_color, birth_date, street, city, state, country, postal_code)
VALUES (null, 'Susan', 'Smith', 'BL', '1975-11-02', '23 Maple St.', 'Arlington', 'VA', 'USA', '20220');

-- INSERT en tabla con FK — person_id debe existir en person
INSERT INTO favorite_food (person_id, food) VALUES (1, 'pizza');
INSERT INTO favorite_food (person_id, food) VALUES (1, 'cookies');
INSERT INTO favorite_food (person_id, food) VALUES (1, 'nachos');

-- ─────────────────────────────────────────────────────────────
-- SELECT
-- ─────────────────────────────────────────────────────────────

-- Todos los registros
SELECT person_id, fname, lname, birth_date FROM person;

-- Filtro por PK
SELECT person_id, fname, lname, birth_date
FROM person
WHERE person_id = 1;

-- Filtro por columna no-PK
SELECT person_id, fname, lname, birth_date
FROM person
WHERE lname = 'Turner';

-- Comidas favoritas de una persona, ordenadas alfabéticamente
SELECT food
FROM favorite_food
WHERE person_id = 1
ORDER BY food;

-- ─────────────────────────────────────────────────────────────
-- UPDATE
-- ─────────────────────────────────────────────────────────────

UPDATE person
SET street      = '1225 Tremont St.',
    city        = 'Boston',
    state       = 'MA',
    country     = 'USA',
    postal_code = '02138'
WHERE person_id = 1;

-- ─────────────────────────────────────────────────────────────
-- DELETE
-- ─────────────────────────────────────────────────────────────

-- Borrar primero las filas hijas (FK constraint)
DELETE FROM favorite_food WHERE person_id = 2;
DELETE FROM person WHERE person_id = 2;
