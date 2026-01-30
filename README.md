# SQL Lab

## Relational Modeling Exercise

This section demonstrates basic relational database design concepts
using MySQL.

### Schema Design
- `person`: main entity
- `favorite_food`: child table (one-to-many relationship)

### Key Concepts Applied
- Primary keys and composite keys
- Foreign key constraints
- AUTO_INCREMENT behavior
- Referential integrity
- Constraint-related errors and resolution

### Example Tables
- `person(person_id PK, fname, lname, eye_color, birth_date, ...)`
- `favorite_food(person_id FK, food)`

### Notes
- `ENUM` was used for simplicity in a learning context
- `foreign_key_checks` was temporarily disabled for schema alteration (lab use only)

## Dataset
- MySQL Sakila Database

