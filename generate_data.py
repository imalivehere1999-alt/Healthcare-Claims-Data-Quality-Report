"""
Healthcare Claims Dataset Generator
Generates 4 CSV files: patients, providers, claims, payments
Run: python generate_data.py
"""

import csv, random, os
from datetime import datetime, timedelta
from faker import Faker

fake = Faker('en_IN')
random.seed(42)

OUTPUT_DIR = "data"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ── Config ─────────────────────────────────────────────────────────
N_PATIENTS  = 1000
N_PROVIDERS = 50
N_CLAIMS    = 10000
# payments are generated per claim (only for approved/partial)

# ── Reference Data ─────────────────────────────────────────────────
INSURANCE_TYPES  = ["Medicare", "Medicaid", "BlueCross", "Aetna", "United Health", "Cigna", "Self-Pay"]
SPECIALTIES      = ["Cardiology", "Orthopedics", "General Surgery", "Neurology", "Oncology",
                    "Dermatology", "Pediatrics", "Internal Medicine", "Radiology", "Emergency Medicine"]
HOSPITALS        = ["Apollo Hospital", "Fortis Hospital", "Manipal Hospital", "AIIMS",
                    "Narayana Health", "Max Healthcare", "Medanta", "Aster CMI",
                    "Global Hospitals", "Kauvery Hospital"]
CITIES           = ["Chennai", "Mumbai", "Delhi", "Bengaluru", "Hyderabad",
                    "Pune", "Kolkata", "Ahmedabad", "Jaipur", "Coimbatore"]
STATES           = {"Chennai":"Tamil Nadu","Mumbai":"Maharashtra","Delhi":"Delhi",
                    "Bengaluru":"Karnataka","Hyderabad":"Telangana","Pune":"Maharashtra",
                    "Kolkata":"West Bengal","Ahmedabad":"Gujarat","Jaipur":"Rajasthan",
                    "Coimbatore":"Tamil Nadu"}
DIAGNOSIS_CODES  = {
    "E11.9":"Type 2 Diabetes","I10":"Hypertension","J18.9":"Pneumonia",
    "M54.5":"Low Back Pain","I25.10":"Coronary Artery Disease","N18.3":"Chronic Kidney Disease",
    "J44.1":"COPD","K21.0":"GERD","F32.1":"Depression","G43.909":"Migraine",
    "C34.10":"Lung Cancer","Z00.00":"Routine Checkup","S72.001A":"Hip Fracture",
    "I63.9":"Cerebrovascular Accident","E78.5":"Hyperlipidemia"
}
PROCEDURE_CODES  = {
    "99213":"Office Visit","93000":"ECG","71046":"Chest X-Ray","85027":"CBC",
    "80053":"Comprehensive Metabolic Panel","27447":"Total Knee Replacement",
    "43239":"Upper GI Endoscopy","70553":"MRI Brain","74177":"CT Abdomen",
    "99291":"Critical Care","36415":"Venipuncture","90837":"Psychotherapy",
    "20610":"Joint Injection","99285":"ER Visit"
}
CLAIM_STATUSES   = ["Approved", "Denied", "Pending", "Partially Approved"]
DENIAL_REASONS   = ["Not Medically Necessary", "Prior Auth Required", "Out of Network",
                    "Duplicate Claim", "Exceeded Benefit Limit", "Incorrect Billing Code", None]
PAYMENT_METHODS  = ["EFT", "Check", "Credit Card", "Cash", "Online Transfer"]

def rand_date(start_year=1950, end_year=2005):
    start = datetime(start_year, 1, 1)
    end   = datetime(end_year, 12, 31)
    return start + timedelta(days=random.randint(0, (end - start).days))

def rand_claim_date():
    start = datetime(2021, 1, 1)
    end   = datetime(2024, 12, 31)
    return start + timedelta(days=random.randint(0, (end - start).days))

# ── Generate PATIENTS ──────────────────────────────────────────────
print("Generating patients...")
patients = []
for i in range(1, N_PATIENTS + 1):
    dob  = rand_date(1940, 2005)
    city = random.choice(CITIES)
    patients.append({
        "patient_id":       f"P{i:04d}",
        "first_name":       fake.first_name(),
        "last_name":        fake.last_name(),
        "date_of_birth":    dob.strftime("%Y-%m-%d"),
        "age":              datetime.now().year - dob.year,
        "gender":           random.choice(["Male", "Female"]),
        "city":             city,
        "state":            STATES[city],
        "phone":            fake.phone_number()[:15],
        "insurance_type":   random.choice(INSURANCE_TYPES),
        "member_since":     rand_date(2010, 2022).strftime("%Y-%m-%d"),
    })

with open(f"{OUTPUT_DIR}/patients.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=patients[0].keys())
    writer.writeheader(); writer.writerows(patients)
print(f"  → {len(patients)} patients written")

# ── Generate PROVIDERS ─────────────────────────────────────────────
print("Generating providers...")
providers = []
for i in range(1, N_PROVIDERS + 1):
    city = random.choice(CITIES)
    providers.append({
        "provider_id":    f"PR{i:03d}",
        "provider_name":  "Dr. " + fake.last_name() + ", " + fake.first_name(),
        "specialty":      random.choice(SPECIALTIES),
        "hospital_name":  random.choice(HOSPITALS),
        "city":           city,
        "state":          STATES[city],
        "npi_number":     str(random.randint(1000000000, 9999999999)),
        "years_practice": random.randint(1, 35),
    })

with open(f"{OUTPUT_DIR}/providers.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=providers[0].keys())
    writer.writeheader(); writer.writerows(providers)
print(f"  → {len(providers)} providers written")

# ── Generate CLAIMS ────────────────────────────────────────────────
print("Generating claims...")
claims = []
patient_ids  = [p["patient_id"]  for p in patients]
provider_ids = [p["provider_id"] for p in providers]
diag_codes   = list(DIAGNOSIS_CODES.keys())
proc_codes   = list(PROCEDURE_CODES.keys())

for i in range(1, N_CLAIMS + 1):
    status       = random.choices(CLAIM_STATUSES, weights=[55, 20, 10, 15])[0]
    billed       = round(random.uniform(200, 85000), 2)
    allowed      = round(billed * random.uniform(0.4, 0.95), 2) if status != "Denied" else 0.0
    paid         = round(allowed * random.uniform(0.7, 1.0), 2) if status == "Approved" else \
                   round(allowed * random.uniform(0.3, 0.6), 2) if status == "Partially Approved" else 0.0
    denial_reason = random.choice(DENIAL_REASONS[:-1]) if status == "Denied" else \
                    random.choice(DENIAL_REASONS[:-1]) if status == "Partially Approved" and random.random() > 0.5 else None
    claim_date   = rand_claim_date()
    claims.append({
        "claim_id":         f"C{i:05d}",
        "patient_id":       random.choice(patient_ids),
        "provider_id":      random.choice(provider_ids),
        "claim_date":       claim_date.strftime("%Y-%m-%d"),
        "service_date":     (claim_date - timedelta(days=random.randint(0,14))).strftime("%Y-%m-%d"),
        "diagnosis_code":   random.choice(diag_codes),
        "diagnosis_desc":   DIAGNOSIS_CODES[diag_codes[0]],   # simplified
        "procedure_code":   random.choice(proc_codes),
        "billed_amount":    billed,
        "allowed_amount":   allowed,
        "paid_amount":      paid,
        "claim_status":     status,
        "denial_reason":    denial_reason if denial_reason else "",
        "processing_days":  random.randint(1, 45),
    })
    # fix diagnosis_desc properly
    claims[-1]["diagnosis_desc"] = DIAGNOSIS_CODES[claims[-1]["diagnosis_code"]]

with open(f"{OUTPUT_DIR}/claims.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=claims[0].keys())
    writer.writeheader(); writer.writerows(claims)
print(f"  → {len(claims)} claims written")

# ── Generate PAYMENTS ──────────────────────────────────────────────
print("Generating payments...")
payments = []
pay_id = 1
for claim in claims:
    if claim["claim_status"] in ("Approved", "Partially Approved") and float(claim["paid_amount"]) > 0:
        n_payments = random.choices([1, 2, 3], weights=[70, 20, 10])[0]
        remaining  = float(claim["paid_amount"])
        base_date  = datetime.strptime(claim["claim_date"], "%Y-%m-%d")
        for j in range(n_payments):
            pay_amount = round(remaining / (n_payments - j), 2) if j < n_payments - 1 else round(remaining, 2)
            remaining -= pay_amount
            pay_date   = base_date + timedelta(days=random.randint(3, 60))
            payments.append({
                "payment_id":     f"PAY{pay_id:06d}",
                "claim_id":       claim["claim_id"],
                "patient_id":     claim["patient_id"],
                "payment_date":   pay_date.strftime("%Y-%m-%d"),
                "paid_amount":    pay_amount,
                "payment_method": random.choice(PAYMENT_METHODS),
                "transaction_ref":f"TXN{random.randint(100000,999999)}",
            })
            pay_id += 1

with open(f"{OUTPUT_DIR}/payments.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=payments[0].keys())
    writer.writeheader(); writer.writerows(payments)
print(f"  → {len(payments)} payments written")
print("\n✅ All CSV files generated in ./data/")
