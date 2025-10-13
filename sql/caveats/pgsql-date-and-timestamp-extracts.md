# PostgreSQL Date/Timestamp Subtraction Differences

---

### DATE subtraction returns INTEGER (days)

```sql
SELECT '2022-10-12'::DATE - '2022-10-01'::DATE;  -- Result: 11 (integer)
```

---

### TIMESTAMP subtraction returns INTERVAL

```sql
SELECT '2022-10-12'::TIMESTAMP - '2022-10-01'::TIMESTAMP;  -- Result: 11 days (interval)
```

---

### EXTRACT with DATE subtraction - ERROR (integer input)

```sql
SELECT EXTRACT(DAYS FROM ('2022-10-12'::DATE - '2022-10-01'::DATE));  -- ERROR
```

---

### EXTRACT with TIMESTAMP subtraction - WORKS (interval input)

```sql
SELECT EXTRACT(DAYS FROM ('2022-10-12'::TIMESTAMP - '2022-10-01'::TIMESTAMP));  -- Result: 11
```

---

**NOTE:** `EXTRACT(DAYS FROM ...)` requires **INTERVAL**, **DATE**, or **DATETIME**, not **INTEGER**.
