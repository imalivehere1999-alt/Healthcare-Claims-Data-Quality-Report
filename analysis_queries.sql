-- ================================================================
--   Healthcare Claims Analytics — SQL Queries
--   Prakash G | Data Analyst Portfolio Project
--   Levels: Basic → Intermediate → Advanced
-- ================================================================

-- ================================================================
-- SECTION 1: BASIC QUERIES (SELECT, WHERE, ORDER BY, AGGREGATE)
-- ================================================================

-- Q1. Total number of claims, patients, providers
SELECT
    (SELECT COUNT(*) FROM claims)    AS total_claims,
    (SELECT COUNT(*) FROM patients)  AS total_patients,
    (SELECT COUNT(*) FROM providers) AS total_providers,
    (SELECT COUNT(*) FROM payments)  AS total_payments;


-- Q2. Claims count by status
SELECT
    claim_status,
    COUNT(*)                                          AS total_claims,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM claims), 2) AS pct_share
FROM claims
GROUP BY claim_status
ORDER BY total_claims DESC;


-- Q3. Total billed vs allowed vs paid amounts
SELECT
    ROUND(SUM(billed_amount),  2) AS total_billed,
    ROUND(SUM(allowed_amount), 2) AS total_allowed,
    ROUND(SUM(paid_amount),    2) AS total_paid,
    ROUND(SUM(billed_amount) - SUM(paid_amount), 2) AS unpaid_amount
FROM claims;


-- Q4. Top 10 most common diagnosis codes
SELECT
    diagnosis_code,
    diagnosis_desc,
    COUNT(*) AS claim_count,
    ROUND(AVG(billed_amount), 2) AS avg_billed
FROM claims
GROUP BY diagnosis_code, diagnosis_desc
ORDER BY claim_count DESC
LIMIT 10;


-- Q5. Monthly claim volume (2021-2024)
SELECT
    STRFTIME('%Y-%m', claim_date) AS year_month,      -- SQLite
    -- DATE_FORMAT(claim_date, '%Y-%m') AS year_month  -- MySQL
    -- TO_CHAR(claim_date, 'YYYY-MM')  AS year_month  -- PostgreSQL
    COUNT(*)                      AS claims_submitted,
    ROUND(SUM(billed_amount), 2)  AS total_billed
FROM claims
GROUP BY year_month
ORDER BY year_month;


-- Q6. Gender-wise claim breakdown
SELECT
    p.gender,
    COUNT(c.claim_id)             AS total_claims,
    ROUND(AVG(c.billed_amount),2) AS avg_billed,
    ROUND(SUM(c.paid_amount),2)   AS total_paid
FROM claims c
JOIN patients p ON c.patient_id = p.patient_id
GROUP BY p.gender;


-- ================================================================
-- SECTION 2: INTERMEDIATE QUERIES (JOIN, GROUP BY, HAVING, CASE)
-- ================================================================

-- Q7. Top 10 providers by revenue (paid amount)
SELECT
    pr.provider_id,
    pr.provider_name,
    pr.specialty,
    pr.hospital_name,
    COUNT(c.claim_id)            AS total_claims,
    ROUND(SUM(c.paid_amount),2)  AS total_paid,
    ROUND(AVG(c.paid_amount),2)  AS avg_paid_per_claim
FROM claims c
JOIN providers pr ON c.provider_id = pr.provider_id
WHERE c.claim_status = 'Approved'
GROUP BY pr.provider_id, pr.provider_name, pr.specialty, pr.hospital_name
ORDER BY total_paid DESC
LIMIT 10;


-- Q8. Insurance type performance — approval rate and avg payment
SELECT
    p.insurance_type,
    COUNT(c.claim_id)                                          AS total_claims,
    SUM(CASE WHEN c.claim_status = 'Approved'  THEN 1 ELSE 0 END) AS approved,
    SUM(CASE WHEN c.claim_status = 'Denied'    THEN 1 ELSE 0 END) AS denied,
    ROUND(
        SUM(CASE WHEN c.claim_status = 'Approved' THEN 1.0 ELSE 0 END)
        / COUNT(c.claim_id) * 100, 2
    )                                                          AS approval_rate_pct,
    ROUND(AVG(c.paid_amount), 2)                               AS avg_paid
FROM claims c
JOIN patients p ON c.patient_id = p.patient_id
GROUP BY p.insurance_type
ORDER BY approval_rate_pct DESC;


-- Q9. Denial reason breakdown
SELECT
    denial_reason,
    COUNT(*)                                          AS denial_count,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM claims WHERE claim_status = 'Denied'
    ), 2)                                             AS pct_of_denials,
    ROUND(SUM(billed_amount), 2)                      AS total_billed_denied
FROM claims
WHERE claim_status = 'Denied'
  AND denial_reason IS NOT NULL
  AND denial_reason != ''
GROUP BY denial_reason
ORDER BY denial_count DESC;


-- Q10. High-value claims (> 50,000 billed) by specialty
SELECT
    pr.specialty,
    COUNT(c.claim_id)            AS high_value_claims,
    ROUND(AVG(c.billed_amount),2) AS avg_billed,
    ROUND(MAX(c.billed_amount),2) AS max_billed,
    ROUND(SUM(c.paid_amount),2)   AS total_paid
FROM claims c
JOIN providers pr ON c.provider_id = pr.provider_id
WHERE c.billed_amount > 50000
GROUP BY pr.specialty
ORDER BY high_value_claims DESC;


-- Q11. City-wise patient and claim distribution
SELECT
    p.city,
    p.state,
    COUNT(DISTINCT p.patient_id)  AS patient_count,
    COUNT(c.claim_id)             AS total_claims,
    ROUND(AVG(c.billed_amount),2) AS avg_billed,
    ROUND(SUM(c.paid_amount),2)   AS total_paid
FROM patients p
LEFT JOIN claims c ON p.patient_id = c.patient_id
GROUP BY p.city, p.state
ORDER BY total_claims DESC;


-- Q12. Patients with more than 5 claims (frequent claimants)
SELECT
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.insurance_type,
    p.city,
    COUNT(c.claim_id)             AS total_claims,
    ROUND(SUM(c.billed_amount),2) AS total_billed,
    ROUND(SUM(c.paid_amount),2)   AS total_paid
FROM patients p
JOIN claims c ON p.patient_id = c.patient_id
GROUP BY p.patient_id, patient_name, p.insurance_type, p.city
HAVING COUNT(c.claim_id) > 5
ORDER BY total_claims DESC;


-- Q13. Average processing days by claim status and specialty
SELECT
    c.claim_status,
    pr.specialty,
    ROUND(AVG(c.processing_days),1)  AS avg_processing_days,
    MIN(c.processing_days)           AS min_days,
    MAX(c.processing_days)           AS max_days
FROM claims c
JOIN providers pr ON c.provider_id = pr.provider_id
GROUP BY c.claim_status, pr.specialty
ORDER BY avg_processing_days DESC;


-- ================================================================
-- SECTION 3: ADVANCED QUERIES (CTEs, WINDOW FUNCTIONS, SUBQUERIES)
-- ================================================================

-- Q14. Running total of paid amounts by month (Window Function)
SELECT
    year_month,
    monthly_paid,
    SUM(monthly_paid) OVER (
        ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_paid
FROM (
    SELECT
        STRFTIME('%Y-%m', claim_date) AS year_month,
        ROUND(SUM(paid_amount), 2)    AS monthly_paid
    FROM claims
    WHERE claim_status IN ('Approved','Partially Approved')
    GROUP BY year_month
) monthly_data
ORDER BY year_month;


-- Q15. Rank providers within each specialty by total paid (Window Function)
SELECT
    specialty,
    provider_name,
    hospital_name,
    total_paid,
    RANK() OVER (PARTITION BY specialty ORDER BY total_paid DESC) AS rank_in_specialty
FROM (
    SELECT
        pr.specialty,
        pr.provider_name,
        pr.hospital_name,
        ROUND(SUM(c.paid_amount), 2) AS total_paid
    FROM claims c
    JOIN providers pr ON c.provider_id = pr.provider_id
    GROUP BY pr.provider_id, pr.specialty, pr.provider_name, pr.hospital_name
) provider_totals
ORDER BY specialty, rank_in_specialty;


-- Q16. CTE: Claims approval funnel with drop-off analysis
WITH claim_funnel AS (
    SELECT
        claim_status,
        COUNT(*)                      AS claim_count,
        ROUND(SUM(billed_amount),2)   AS total_billed,
        ROUND(SUM(allowed_amount),2)  AS total_allowed,
        ROUND(SUM(paid_amount),2)     AS total_paid
    FROM claims
    GROUP BY claim_status
),
total AS (
    SELECT SUM(claim_count) AS grand_total FROM claim_funnel
)
SELECT
    f.claim_status,
    f.claim_count,
    ROUND(f.claim_count * 100.0 / t.grand_total, 2) AS pct_of_total,
    f.total_billed,
    f.total_allowed,
    f.total_paid,
    ROUND((f.total_billed - f.total_paid), 2) AS revenue_leakage
FROM claim_funnel f, total t
ORDER BY f.claim_count DESC;


-- Q17. CTE: Patient risk segmentation by claim frequency and spend
WITH patient_stats AS (
    SELECT
        p.patient_id,
        p.first_name || ' ' || p.last_name AS patient_name,
        p.insurance_type,
        p.age,
        COUNT(c.claim_id)             AS claim_count,
        ROUND(SUM(c.billed_amount),2) AS total_billed
    FROM patients p
    LEFT JOIN claims c ON p.patient_id = c.patient_id
    GROUP BY p.patient_id, patient_name, p.insurance_type, p.age
),
segmented AS (
    SELECT *,
        CASE
            WHEN claim_count >= 10 AND total_billed >= 50000 THEN 'High Risk — High Spend'
            WHEN claim_count >= 10                           THEN 'High Risk — Low Spend'
            WHEN total_billed >= 50000                       THEN 'Low Risk — High Spend'
            ELSE                                                  'Standard'
        END AS patient_segment
    FROM patient_stats
)
SELECT
    patient_segment,
    COUNT(*)                       AS patient_count,
    ROUND(AVG(claim_count),1)      AS avg_claims,
    ROUND(AVG(total_billed),2)     AS avg_total_billed
FROM segmented
GROUP BY patient_segment
ORDER BY patient_count DESC;


-- Q18. Year-over-year claim volume change
WITH yearly AS (
    SELECT
        STRFTIME('%Y', claim_date) AS yr,
        COUNT(*)                   AS total_claims,
        ROUND(SUM(billed_amount),2) AS total_billed
    FROM claims
    GROUP BY yr
)
SELECT
    yr,
    total_claims,
    total_billed,
    LAG(total_claims)  OVER (ORDER BY yr) AS prev_year_claims,
    LAG(total_billed)  OVER (ORDER BY yr) AS prev_year_billed,
    ROUND(
        (total_claims - LAG(total_claims) OVER (ORDER BY yr)) * 100.0
        / NULLIF(LAG(total_claims) OVER (ORDER BY yr), 0), 2
    ) AS yoy_claims_pct_change
FROM yearly
ORDER BY yr;


-- Q19. Payment lag analysis (days between claim date and payment date)
SELECT
    c.claim_status,
    pr.specialty,
    ROUND(AVG(
        JULIANDAY(pay.payment_date) - JULIANDAY(c.claim_date)  -- SQLite
        -- DATEDIFF(pay.payment_date, c.claim_date)             -- MySQL
    ), 1)                          AS avg_payment_lag_days,
    COUNT(DISTINCT pay.payment_id) AS payment_count
FROM payments pay
JOIN claims   c  ON pay.claim_id   = c.claim_id
JOIN providers pr ON c.provider_id = pr.provider_id
GROUP BY c.claim_status, pr.specialty
ORDER BY avg_payment_lag_days DESC;


-- Q20. Top 5 most expensive claims per diagnosis (Subquery + RANK)
SELECT *
FROM (
    SELECT
        claim_id,
        diagnosis_code,
        diagnosis_desc,
        billed_amount,
        paid_amount,
        claim_status,
        RANK() OVER (
            PARTITION BY diagnosis_code
            ORDER BY billed_amount DESC
        ) AS rank_within_diag
    FROM claims
) ranked
WHERE rank_within_diag <= 5
ORDER BY diagnosis_code, rank_within_diag;


-- Q21. Fraud detection: claims where billed > 3x the average for same procedure
WITH avg_per_procedure AS (
    SELECT
        procedure_code,
        ROUND(AVG(billed_amount), 2) AS avg_billed,
        ROUND(STDEV(billed_amount), 2) AS std_billed  -- remove for SQLite
    FROM claims
    GROUP BY procedure_code
)
SELECT
    c.claim_id,
    c.procedure_code,
    c.billed_amount,
    a.avg_billed,
    ROUND(c.billed_amount / a.avg_billed, 2) AS times_above_avg,
    c.claim_status,
    c.provider_id
FROM claims c
JOIN avg_per_procedure a ON c.procedure_code = a.procedure_code
WHERE c.billed_amount > 3 * a.avg_billed
ORDER BY times_above_avg DESC
LIMIT 20;


-- Q22. Provider efficiency scorecard (CTE + multiple metrics)
WITH provider_metrics AS (
    SELECT
        pr.provider_id,
        pr.provider_name,
        pr.specialty,
        pr.hospital_name,
        COUNT(c.claim_id)                                              AS total_claims,
        SUM(CASE WHEN c.claim_status='Approved' THEN 1 ELSE 0 END)    AS approved_claims,
        SUM(CASE WHEN c.claim_status='Denied'   THEN 1 ELSE 0 END)    AS denied_claims,
        ROUND(AVG(c.processing_days), 1)                               AS avg_proc_days,
        ROUND(SUM(c.paid_amount), 2)                                   AS total_paid,
        ROUND(AVG(c.billed_amount), 2)                                 AS avg_billed,
        ROUND(SUM(c.paid_amount) / NULLIF(SUM(c.billed_amount),0) * 100, 2) AS collection_rate_pct
    FROM claims c
    JOIN providers pr ON c.provider_id = pr.provider_id
    GROUP BY pr.provider_id, pr.provider_name, pr.specialty, pr.hospital_name
)
SELECT *,
    ROUND(approved_claims * 100.0 / NULLIF(total_claims,0), 2) AS approval_rate_pct,
    ROUND(denied_claims   * 100.0 / NULLIF(total_claims,0), 2) AS denial_rate_pct
FROM provider_metrics
WHERE total_claims >= 50
ORDER BY collection_rate_pct DESC;
