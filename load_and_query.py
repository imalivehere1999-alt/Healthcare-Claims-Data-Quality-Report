"""
load_and_query.py
─────────────────
Loads all 4 CSV files into a local SQLite database and
runs sample queries so you can see results immediately.

Run: python load_and_query.py
Requires: Python 3.8+  (no extra packages needed)
"""

import sqlite3, csv, os

DB_PATH   = "healthcare_claims.db"
DATA_DIR  = "data"

def load_csv(cursor, table, filepath, transform=None):
    with open(filepath, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        rows   = list(reader)
    if not rows:
        return 0
    cols        = list(rows[0].keys())
    placeholders = ", ".join(["?"] * len(cols))
    col_list     = ", ".join(cols)
    sql          = f"INSERT OR IGNORE INTO {table} ({col_list}) VALUES ({placeholders})"
    data         = [[row[c] or None for c in cols] for row in rows]
    cursor.executemany(sql, data)
    return len(data)

def run_query(cursor, title, sql):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print('='*60)
    cursor.execute(sql)
    cols = [d[0] for d in cursor.description]
    rows = cursor.fetchall()
    # Print header
    widths = [max(len(str(c)), max((len(str(r[i])) for r in rows), default=0)) for i, c in enumerate(cols)]
    header = " | ".join(str(c).ljust(widths[i]) for i, c in enumerate(cols))
    print(header)
    print("-" * len(header))
    for row in rows[:20]:  # Show max 20 rows
        print(" | ".join(str(v).ljust(widths[i]) if v is not None else "NULL".ljust(widths[i]) for i, v in enumerate(row)))
    if len(rows) > 20:
        print(f"  ... ({len(rows) - 20} more rows)")

# ── Setup DB ──────────────────────────────────────────────────────
print("Setting up SQLite database...")
conn   = sqlite3.connect(DB_PATH)
cursor = conn.cursor()
cursor.executescript(open("schema.sql").read())
conn.commit()

# ── Load Data ─────────────────────────────────────────────────────
tables = ["patients", "providers", "claims", "payments"]
for tbl in tables:
    path = os.path.join(DATA_DIR, f"{tbl}.csv")
    n    = load_csv(cursor, tbl, path)
    conn.commit()
    print(f"  ✓ Loaded {n:,} rows into '{tbl}'")

# ── Run Sample Queries ────────────────────────────────────────────
run_query(cursor, "Q1 — Overall Dataset Summary",
"""
SELECT
    (SELECT COUNT(*) FROM claims)    AS total_claims,
    (SELECT COUNT(*) FROM patients)  AS total_patients,
    (SELECT COUNT(*) FROM providers) AS total_providers,
    (SELECT COUNT(*) FROM payments)  AS total_payments
""")

run_query(cursor, "Q2 — Claims by Status",
"""
SELECT
    claim_status,
    COUNT(*) AS total_claims,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM claims), 2) AS pct_share
FROM claims
GROUP BY claim_status
ORDER BY total_claims DESC
""")

run_query(cursor, "Q3 — Financial Summary",
"""
SELECT
    ROUND(SUM(billed_amount),  2) AS total_billed,
    ROUND(SUM(allowed_amount), 2) AS total_allowed,
    ROUND(SUM(paid_amount),    2) AS total_paid,
    ROUND(SUM(billed_amount) - SUM(paid_amount), 2) AS revenue_leakage
FROM claims
""")

run_query(cursor, "Q4 — Top 5 Diagnosis Codes",
"""
SELECT diagnosis_code, diagnosis_desc, COUNT(*) AS claim_count,
       ROUND(AVG(billed_amount),2) AS avg_billed
FROM claims
GROUP BY diagnosis_code, diagnosis_desc
ORDER BY claim_count DESC LIMIT 5
""")

run_query(cursor, "Q5 — Insurance Approval Rates",
"""
SELECT
    p.insurance_type,
    COUNT(c.claim_id) AS total_claims,
    SUM(CASE WHEN c.claim_status='Approved' THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN c.claim_status='Denied'   THEN 1 ELSE 0 END) AS denied,
    ROUND(SUM(CASE WHEN c.claim_status='Approved' THEN 1.0 ELSE 0 END) /
          COUNT(c.claim_id) * 100, 2) AS approval_rate_pct
FROM claims c
JOIN patients p ON c.patient_id = p.patient_id
GROUP BY p.insurance_type
ORDER BY approval_rate_pct DESC
""")

run_query(cursor, "Q6 — YoY Claims Growth (Window Function)",
"""
WITH yearly AS (
    SELECT STRFTIME('%Y', claim_date) AS yr,
           COUNT(*) AS total_claims,
           ROUND(SUM(billed_amount),2) AS total_billed
    FROM claims GROUP BY yr
)
SELECT yr, total_claims, total_billed,
    LAG(total_claims) OVER (ORDER BY yr) AS prev_year_claims,
    ROUND((total_claims - LAG(total_claims) OVER (ORDER BY yr)) * 100.0
          / NULLIF(LAG(total_claims) OVER (ORDER BY yr),0), 2) AS yoy_pct_change
FROM yearly ORDER BY yr
""")

run_query(cursor, "Q7 — Patient Risk Segments (CTE)",
"""
WITH stats AS (
    SELECT p.patient_id,
           COUNT(c.claim_id) AS claim_count,
           ROUND(SUM(c.billed_amount),2) AS total_billed
    FROM patients p LEFT JOIN claims c ON p.patient_id=c.patient_id
    GROUP BY p.patient_id
),
segmented AS (
    SELECT *,
        CASE WHEN claim_count>=10 AND total_billed>=50000 THEN 'High Risk - High Spend'
             WHEN claim_count>=10                          THEN 'High Risk - Low Spend'
             WHEN total_billed>=50000                      THEN 'Low Risk - High Spend'
             ELSE 'Standard' END AS segment
    FROM stats
)
SELECT segment, COUNT(*) AS patients,
       ROUND(AVG(claim_count),1) AS avg_claims,
       ROUND(AVG(total_billed),2) AS avg_spend
FROM segmented GROUP BY segment ORDER BY patients DESC
""")

print("\n\n✅ All queries complete. Database saved to:", DB_PATH)
conn.close()
