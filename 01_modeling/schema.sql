-- ============================================================
-- 01 · Relational Modeling
-- Conceptos: CREATE TABLE, PRIMARY KEY, FOREIGN KEY,
--            ENUM, AUTO_INCREMENT, referential integrity
-- ============================================================

-- Tabla principal: entidad person
CREATE TABLE person (
    person_id  SMALLINT UNSIGNED,
    fname      VARCHAR(20),
    lname      VARCHAR(20),
    eye_color  ENUM('BR', 'BL', 'GR'),
    birth_date DATE,
    street     VARCHAR(30),
    city       VARCHAR(20),
    state      VARCHAR(20),
    country    VARCHAR(20),
    postal_code VARCHAR(20),
    CONSTRAINT pk_person PRIMARY KEY (person_id)
);

-- Tabla hija: relación 1-a-muchos con person
-- La PK es compuesta: una persona puede tener múltiples comidas favoritas
-- pero no puede repetir la misma comida
CREATE TABLE favorite_food (
    person_id SMALLINT UNSIGNED,
    food      VARCHAR(20),
    CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
    CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id)
        REFERENCES person (person_id)
);

-- ─────────────────────────────────────────────────────────────
-- Para agregar AUTO_INCREMENT hay que deshabilitar temporalmente
-- el chequeo de FK porque MySQL valida la columna referenciada
-- ─────────────────────────────────────────────────────────────
SET foreign_key_checks = 0;
ALTER TABLE person
    MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;
SET foreign_key_checks = 1;
