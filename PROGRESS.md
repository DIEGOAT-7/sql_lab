# Progress Tracker

## Conceptos completados

- [x] DDL: `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `ENUM`, `AUTO_INCREMENT`
- [x] DML: `INSERT`, `UPDATE`, `DELETE`
- [x] `SELECT` básico, `WHERE`, `ORDER BY`, `LIMIT`
- [x] `LIKE`, `IN`, `BETWEEN`, `IS NULL`, `DISTINCT`
- [x] `INNER JOIN` multi-tabla (hasta 5 tablas)
- [x] `LEFT JOIN` + anti-join pattern
- [x] `GROUP BY` + `HAVING`
- [x] Funciones de agregación: `COUNT`, `SUM`, `AVG`, `MAX`, `MIN`

## En progreso

- [ ] **Window functions** → `05_window_functions/`
  - [ ] `RANK` / `DENSE_RANK` / `ROW_NUMBER`
  - [ ] `LAG` / `LEAD`
  - [ ] `NTILE`
  - [ ] `SUM OVER` / `AVG OVER` con frames

- [ ] **CTEs y subqueries** → `06_subqueries_ctes/`
  - [ ] `WITH` básico
  - [ ] CTEs múltiples encadenados
  - [ ] Subquery escalar
  - [ ] `EXISTS` vs `IN`
  - [ ] CTE + Window Function combinados

- [ ] **Proyecto analítico** → `07_analysis_project/`

## Próximos niveles

- [ ] `VIEWS` — encapsular queries complejos como objetos reutilizables
- [ ] `STORED PROCEDURES` — lógica con parámetros
- [ ] `INDEXES` + `EXPLAIN` — entender y optimizar planes de ejecución
- [ ] `TRANSACTIONS` + `ROLLBACK` — ACID en la práctica
- [ ] `CASE WHEN` avanzado en `SELECT` y `ORDER BY`
- [ ] `RECURSIVE CTEs` — jerarquías y árboles
