------------------------ CREAR TABLAS

CREATE TABLE person
     (person_id SMALLINT UNSIGNED,
      fname VARCHAR(20),
      lname VARCHAR(20),
      eye_color ENUM('BR','BL','GR'),
      birth_date DATE,
      street VARCHAR(30),
      city VARCHAR(20),
      state VARCHAR(20),
      country VARCHAR(20),
      postal_code VARCHAR(20),
      CONSTRAINT pk_person PRIMARY KEY (person_id)
);

--------

CREATE TABLE favorite_food
     (person_id SMALLINT UNSIGNED,
     food VARCHAR(20),
     CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
     CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id)
     REFERENCES person (person_id)
     );

------- If you are running these statements in your database, you will first need to disable the foreign key constraint on the favorite_food table, and then re-enable the constraints when finished. The pro‐ gression of statements would be:

set foreign_key_checks=0;
ALTER TABLE person
MODIFY person_id SMALLINT UNSIGNED AUTO_INCREMENT;
set foreign_key_checks=1;

--------------------------- INSERT DATA

INSERT INTO person
   (person_id, fname, lname, eye_color, birth_date)
VALUES (null, 'William', 'Turner', 'BR', '1997-05-27');

---------------------------


-------------------------- CHECK CHANGES

SELECT person_id, fname, lname, birth_date
FROM person;

------

SELECT person_id, fname, lname, birth_date
FROM person
WHERE person_id = 1;

------

SELECT person_id, fname, lname, birth_date
FROM person
WHERE lname = 'Turner';


---------------- INSERT FAVORITE_FOOD

INSERT INTO favorite_food (person_id, food)
VALUES (1, 'pizza');
 
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'cookies');
    
INSERT INTO favorite_food (person_id, food)
VALUES (1, 'nachos');


SELECT food
FROM favorite_food
WHERE person_id = 1
ORDER BY food;

------------------

INSERT INTO person 
(person_id, fname, lname, eye_color, birth_date, street, city, state, country, postal_code)
VALUES (null, 'Susan','Smith', 'BL', '1975-11-02','23 Maple St.', 'Arlington', 'VA', 'USA', '20220');

--------------------- UPDATE

 UPDATE person
 SET street = '1225 Tremont St.',
     city = 'Boston',
     state = 'MA',
     country = 'USA',
     postal_code = '02138'
WHERE person_id = 1;