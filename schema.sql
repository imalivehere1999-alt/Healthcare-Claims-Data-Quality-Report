-- ================================================================
-- Healthcare Claims Analytics — Database Schema
-- Compatible with: MySQL 8+, PostgreSQL 13+, SQLite 3.35+
-- ================================================================

-- ── DROP TABLES (for re-runs) ────────────────────────────────────
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS providers;
DROP TABLE IF EXISTS patients;

-- ── 1. PATIENTS ──────────────────────────────────────────────────
CREATE TABLE patients (
    patient_id      VARCHAR(10)  PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    date_of_birth   DATE,
    age             INT,
    gender          VARCHAR(10),
    city            VARCHAR(50),
    state           VARCHAR(50),
    phone           VARCHAR(20),
    insurance_type  VARCHAR(30),
    member_since    DATE
);

-- ── 2. PROVIDERS ─────────────────────────────────────────────────
CREATE TABLE providers (
    provider_id     VARCHAR(10)  PRIMARY KEY,
    provider_name   VARCHAR(100) NOT NULL,
    specialty       VARCHAR(50),
    hospital_name   VARCHAR(100),
    city            VARCHAR(50),
    state           VARCHAR(50),
    npi_number      VARCHAR(20),
    years_practice  INT
);

-- ── 3. CLAIMS (main fact table) ──────────────────────────────────
CREATE TABLE claims (
    claim_id         VARCHAR(10)  PRIMARY KEY,
    patient_id       VARCHAR(10)  NOT NULL,
    provider_id      VARCHAR(10)  NOT NULL,
    claim_date       DATE         NOT NULL,
    service_date     DATE,
    diagnosis_code   VARCHAR(15),
    diagnosis_desc   VARCHAR(100),
    procedure_code   VARCHAR(15),
    billed_amount    DECIMAL(12,2),
    allowed_amount   DECIMAL(12,2),
    paid_amount      DECIMAL(12,2),
    claim_status     VARCHAR(25),
    denial_reason    VARCHAR(100),
    processing_days  INT,
    FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

-- ── 4. PAYMENTS ──────────────────────────────────────────────────
CREATE TABLE payments (
    payment_id       VARCHAR(15)  PRIMARY KEY,
    claim_id         VARCHAR(10)  NOT NULL,
    patient_id       VARCHAR(10),
    payment_date     DATE,
    paid_amount      DECIMAL(12,2),
    payment_method   VARCHAR(20),
    transaction_ref  VARCHAR(20),
    FOREIGN KEY (claim_id)    REFERENCES claims(claim_id),
    FOREIGN KEY (patient_id)  REFERENCES patients(patient_id)
);

-- ── INDEXES (improve query performance) ─────────────────────────
CREATE INDEX idx_claims_patient   ON claims(patient_id);
CREATE INDEX idx_claims_provider  ON claims(provider_id);
CREATE INDEX idx_claims_date      ON claims(claim_date);
CREATE INDEX idx_claims_status    ON claims(claim_status);
CREATE INDEX idx_payments_claim   ON payments(claim_id);
CREATE INDEX idx_payments_date    ON payments(payment_date);
