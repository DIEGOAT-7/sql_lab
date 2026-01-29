-- Crear Tablas

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

CREATE TABLE favorite_food
     (person_id SMALLINT UNSIGNED,
     food VARCHAR(20),
     CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
     CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id)
     REFERENCES person (person_id)
     );
