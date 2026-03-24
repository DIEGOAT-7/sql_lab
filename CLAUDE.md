# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A personal SQL practice lab using MySQL 8.0 and the Sakila sample database (DVD rental store, May 2005 – Feb 2006). Organized as a progressive learning path from fundamentals to analytical project.

## Running the Environment

```bash
docker compose up -d    # start MySQL with Sakila preloaded
docker compose down     # stop (data preserved)
docker compose down -v  # stop + wipe data (clean reset)
```

Connect: `mysql -h 127.0.0.1 -P 3306 -u root -psakila sakila`

Run a single file:
```bash
mysql -h 127.0.0.1 -P 3306 -u root -psakila sakila < 05_window_functions/window_functions.sql
```

## Folder Structure & Learning Path

```
01_modeling/          → DDL/DML with custom person/favorite_food tables
02_fundamentals/      → SELECT, WHERE, LIKE, IN, BETWEEN, DISTINCT on Sakila
03_joins/             → INNER/LEFT JOIN, anti-join pattern, common mistakes
04_aggregations/      → GROUP BY, HAVING, aggregate functions (9 queries)
05_window_functions/  → RANK, LAG/LEAD, NTILE, ROW_NUMBER, running totals, moving avg
06_subqueries_ctes/   → WITH, chained CTEs, EXISTS, scalar subquery, CTE+window combo
07_analysis_project/  → Full executive report: revenue, catalog, customers, staff, inventory
```

Track progress in `PROGRESS.md`.

## Sakila Join Path

Most queries follow this chain:
```
rental → inventory → film → film_category → category
rental → payment
rental → customer
film   → film_actor → actor
store  → inventory
```

## Key Notes

- MySQL 8.0 required (window functions not available in 5.x)
- All query files start with `USE sakila;` — they can be run independently
- `01_modeling/` uses a separate custom schema (`person`, `favorite_food`), not Sakila
- `07_analysis_project/sakila_executive_report.sql` uses all techniques from previous folders; run it last
- `foreign_key_checks=0` in `01_modeling/schema.sql` is intentional (required to add AUTO_INCREMENT when FK references exist)
