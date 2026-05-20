# Healthcare Claims Analytics — SQL Portfolio Project
**Prakash G | Data Analyst | github.com/imalivehere1999-alt**

---

## Project Overview

A complete end-to-end SQL analytics project on a synthetic healthcare claims dataset (10,000+ records).  
Demonstrates skills in **data modelling, SQL querying (basic to advanced), and business insight generation** — directly relevant to data analyst roles in healthcare, insurance, and BFSI domains.

---

## Tech Stack

| Tool        | Purpose                          |
|-------------|----------------------------------|
| Python 3.x  | Dataset generation (Faker)       |
| SQLite 3    | Database (no install needed)     |
| SQL         | Schema design + all analysis     |
| MySQL/PostgreSQL | Production-ready (compatible) |

---

## Dataset

| Table      | Rows    | Description                              |
|------------|---------|------------------------------------------|
| `patients`  | 1,000   | Patient demographics and insurance info  |
| `providers` | 50      | Doctor/hospital details and specialties  |
| `claims`    | 10,000  | Medical insurance claims (fact table)    |
| `payments`  | ~9,500  | Payment transactions per claim           |

---

## Files

```
sql_project/
├── generate_data.py      ← Generates all 4 CSV files in /data/
├── schema.sql            ← CREATE TABLE + INDEX statements
├── analysis_queries.sql  ← 22 SQL queries (Basic → Advanced)
├── load_and_query.py     ← Loads CSVs into SQLite, runs queries
├── data/
│   ├── patients.csv
│   ├── providers.csv
│   ├── claims.csv
│   └── payments.csv
└── README.md
```

---



---

## SQL Skills Demonstrated

### Basic
- SELECT, WHERE, ORDER BY, LIMIT
- GROUP BY, HAVING, aggregate functions (COUNT, SUM, AVG, MAX)
- CASE WHEN for conditional logic

### Intermediate
- INNER JOIN, LEFT JOIN across 3+ tables
- Multi-level GROUP BY
- Subqueries in WHERE and FROM clauses
- NULLIF for safe division

### Advanced
- **CTEs** (WITH clause) for multi-step logic
- **Window Functions**: RANK(), LAG(), SUM() OVER()
- **PARTITION BY** for group-level rankings
- Running totals and year-over-year calculations
- Fraud detection logic (statistical outliers)
- Revenue leakage analysis

---

## Key Business Questions Answered

1. What is the overall claim approval rate?
2. Which insurance providers have the highest denial rates?
3. Which specialties generate the most revenue?
4. Which patients are high-risk high-spend?
5. How has claim volume grown year over year?
6. Which denial reasons cost the most money?
7. Which providers have suspicious billing patterns?
8. What is the average payment lag by specialty?

---

## Sample Insight (from the data)

- ~55% of claims are approved; ~20% are denied
- "Not Medically Necessary" is the top denial reason
- Cardiology and Oncology have the highest average billed amounts
- Medicare patients have higher approval rates than Self-Pay patients
---




