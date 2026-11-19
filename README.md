<div align="center">

# 🩺 Healthcare Claims Intelligence | SQL Portfolio

**From synthetic claims data to reliable analysis of approval, denial, payment and operational patterns**

![SQL](https://img.shields.io/badge/SQL-Analytics-4479A1?style=for-the-badge&logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-Data_Generation-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Domain](https://img.shields.io/badge/Healthcare-Claims-AD78F5?style=for-the-badge)
![Data](https://img.shields.io/badge/Dataset-Synthetic-23BFBF?style=for-the-badge)

</div>

## 🎯 Project objective
Explore how structured claims data can help an operations or revenue-cycle team monitor **claim status, denial categories, payment timelines, provider patterns and data quality**.

## 🧱 Dataset model

| Entity | Approximate rows | Purpose |
|---|---:|---|
| `patients` | 1,000 | Patient and insurance attributes |
| `providers` | 50 | Provider and specialty details |
| `claims` | 10,000 | Claim-level facts and statuses |
| `payments` | 9,500 | Payment and timing details |

> This is a **synthetic portfolio dataset**, not real patient records or operational data from an employer. Numerical patterns should be interpreted as demo outputs only.

## 🧠 Skills demonstrated

| Stage | Techniques |
|---|---|
| Data generation & setup | Python utilities, relational schema, SQLite database |
| SQL foundations | `SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `CASE` |
| Joins & transformations | Multi-table joins, subqueries, NULL handling |
| Advanced analysis | CTEs, `RANK()`, `LAG()`, `SUM() OVER()`, partitions |
| Business investigation | Denials, claim outcomes, revenue leakage and payment lag |

## 🔍 Business questions
1. What share of claims are approved, denied or pending?
2. Which insurance providers have higher denial shares?
3. Which denial categories have the largest billed amounts?
4. How do payment delays vary by specialty?
5. How do claim volumes and billed amounts change over time?
6. What anomalous billing patterns should a reviewer investigate?

## 🗂 Repository guide

| File | Why it matters |
|---|---|
| [`schema.sql`](./schema.sql) | Relational structure |
| [`generate_data.py`](./generate_data.py) | Sample data generation |
| [`load_and_query.py`](./load_and_query.py) | Data loading / querying utility |
| [`analysis_queries.sql`](./analysis_queries.sql) | SQL analyses and business questions |
| [`healthcare_claims.db`](./healthcare_claims.db) | Synthetic SQLite database |

## ✅ Demonstration outputs
The original project notes report example synthetic-data patterns including approximately **55% approved claims** and **20% denied claims**, with variation by denial reason and specialty. These are **simulated observations**, not industry benchmarks, and can vary if the data is regenerated.

## 🚀 Next enhancements
- Add data-quality tests and reproducible run instructions
- Create Power BI reporting pages for denial and payment trends
- Document validation and assumptions for each KPI

---

**Created by [Prakash G](https://github.com/imalivehere1999-alt)** · [Connect on LinkedIn](https://www.linkedin.com/in/prakash-g-contactprakash/)
