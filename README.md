# SQL Lab

<p align="center">
  <img src="assets/book-cover.png" alt="Learning SQL - O'Reilly" height="220"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/mysql-logo.png" alt="MySQL" height="100"/>
</p>

<p align="center">
  Práctica personal de SQL basada en <em>Learning SQL</em> (O'Reilly) usando MySQL y la base de datos <a href="https://dev.mysql.com/doc/sakila/en/">Sakila</a>.
</p>

---

## Quick Start

```bash
docker compose up -d
```

MySQL queda disponible en `localhost:3306` con Sakila ya cargada.

| Parámetro | Valor     |
|-----------|-----------|
| Host      | 127.0.0.1 |
| Port      | 3306      |
| User      | root      |
| Password  | sakila    |
| Database  | sakila    |

Conectar desde terminal:
```bash
mysql -h 127.0.0.1 -P 3306 -u root -psakila sakila
```

Clientes GUI recomendados: **TablePlus**, **DBeaver**, **MySQL Workbench**.

Apagar el contenedor:
```bash
docker compose down          # conserva los datos
docker compose down -v       # borra datos (reset limpio)
```

---

## Estructura del proyecto

```
sql_lab/
├── 01_modeling/          # DDL/DML: CREATE TABLE, FK, INSERT, UPDATE
├── 02_fundamentals/      # SELECT, WHERE, LIKE, IN, BETWEEN, DISTINCT
├── 03_joins/             # INNER JOIN, LEFT JOIN, errores comunes
├── 04_aggregations/      # GROUP BY, HAVING, COUNT/SUM/AVG
├── 05_window_functions/  # RANK, LAG/LEAD, NTILE, ROW_NUMBER, running totals
├── 06_subqueries_ctes/   # WITH, CTEs múltiples, EXISTS, subqueries escalares
├── 07_analysis_project/  # Reporte ejecutivo completo de Sakila
└── sakila-db/            # Schema y datos originales (fuente para Docker)
```

## Learning Path

Seguir las carpetas en orden numérico. Cada archivo tiene comentarios
que explican el concepto antes del código.

```
01 → 02 → 03 → 04 → 05 → 06 → 07
```

El salto más importante es `04 → 05` (window functions). Todo cambia ahí.

---

## Schema de Sakila (ruta principal de JOINs)

```
rental ──┬── customer
         ├── inventory ── film ── film_category ── category
         │                    └── film_actor    ── actor
         └── payment

store ── staff
      └── inventory
```

---

## Dataset

Sakila simula una cadena de renta de DVDs con datos reales de **mayo 2005 a febrero 2006**.
Contiene ~16,000 alquileres, 599 clientes, 1000 películas, 16 categorías.
