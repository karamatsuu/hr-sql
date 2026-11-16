# HR — Employee Skills & Certification (SQL Server / T-SQL)

A **re-runnable** T-SQL script (`HR_schema.sql`) that builds an `HR` database
for tracking employees and their certified skill levels.

## What it creates

- **Database** `HR` (created only if it doesn't already exist).
- **Tables** `EMPLOYEE`, `SKILL`, `CERTIFIED` with primary keys matching the
  reference schema.
- **Identity** — `SKILL.Skill_ID` is `IDENTITY(100, 10)`: the first skill gets
  `100`, the next `110`, and so on up to `220`.
- **Constraints**
  - Foreign keys: `CERTIFIED` → `EMPLOYEE` and `CERTIFIED` → `SKILL`.
  - Check: `CERTIFIED.Skill_ID` must be **between 100 and 220**.
  - Default: `EMPLOYEE.Employee_Title` defaults to `'Unknown'`.
- **Sample data** matching the reference tables.

## Re-runnability

The script drops the tables in child→parent order with `DROP TABLE IF EXISTS`
before recreating them, and guards `CREATE DATABASE`. Running it twice (or on a
fresh server) completes without errors; dropping `SKILL` reseeds the identity
back to `100`.

## Run it

Open `HR_schema.sql` in **SSMS** or **Azure Data Studio** and execute, or:

```bash
sqlcmd -S localhost -U sa -P <password> -i HR_schema.sql
```

## Design notes

- `Employee_ID` is `CHAR(5)` to preserve leading zeros (e.g. `02345`).
- `CERTIFIED` uses a composite primary key `(Employee_ID, Skill_ID)`.
- A rollback-wrapped block at the end demonstrates the `'Unknown'` default
  without leaving test data behind.
