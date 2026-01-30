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