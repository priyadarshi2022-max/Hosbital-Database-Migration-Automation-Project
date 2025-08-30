-- Step 1: Create a temporary "staging" table to hold the raw CSV data.
DROP TABLE IF EXISTS hospital_data_staging;
CREATE TABLE hospital_data_staging (
    department_id INT,
    department_name VARCHAR(100),
    doctor_id INT,
    doctor_name VARCHAR(100),
    doctor_specialization VARCHAR(100),
    doctor_role VARCHAR(50),
    doctor_department_id INT,
    patient_id INT,
    patient_name VARCHAR(100),
    patient_dob VARCHAR(20),
    patient_gender VARCHAR(10),
    patient_phone VARCHAR(25),
    appointment_id INT,
    appointment_patient_id INT,
    appointment_doctor_id INT,
    appointment_time VARCHAR(30),
    appointment_status VARCHAR(50),
    prescription_id INT,
    prescription_appointment_id INT,
    prescription_medication VARCHAR(255),
    prescription_dosage VARCHAR(100),
    bill_id INT,
    bill_appointment_id INT,
    bill_amount NUMERIC(10, 2),
    bill_paid INT,
    bill_date VARCHAR(30),
    lab_report_id INT,
    lab_report_appointment_id INT,
    lab_report_data TEXT,
    lab_report_created_at VARCHAR(30)
);

-- Step 2: Load the raw data from your CSV into the staging table.
COPY hospital_data_staging FROM '/data/hospital_data.csv' WITH (FORMAT csv, HEADER);


-- Step 2.5: IMPORTANT - Clear all existing data from the final tables.
-- This makes the script runnable multiple times without causing duplicate errors.
-- "RESTART IDENTITY" resets the auto-incrementing counters (like SERIAL).
-- "CASCADE" also truncates tables that have foreign keys pointing to these tables.
TRUNCATE departments, doctors, patients, appointments, prescriptions, bills, labreports RESTART IDENTITY CASCADE;


-- Step 3: Migrate data from the staging table into the final, normalized tables.
-- We add "OVERRIDING SYSTEM VALUE" to allow inserting into IDENTITY columns.

-- Populate Departments
INSERT INTO departments (departmentID, name)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT department_id, department_name
FROM hospital_data_staging
WHERE department_id IS NOT NULL;

-- Populate Doctors
INSERT INTO doctors (doctorid, name, specialization, role, departmentid)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT doctor_id, doctor_name, doctor_specialization, doctor_role, doctor_department_id
FROM hospital_data_staging
WHERE doctor_id IS NOT NULL;

-- Populate Patients, converting the date and GENDER formats on the fly
INSERT INTO patients (patientid, name, dateofbirth, gender, phone)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT patient_id, patient_name, TO_DATE(patient_dob, 'DD-MM-YYYY'), LOWER(patient_gender), patient_phone
FROM hospital_data_staging
WHERE patient_id IS NOT NULL;

-- Populate Appointments, converting the timestamp format on the fly
INSERT INTO appointments (appointmentid, patientid, doctorid, appointmentTime, status)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT appointment_id, appointment_patient_id, appointment_doctor_id, TO_TIMESTAMP(appointment_time, 'DD-MM-YYYY HH24:MI'), appointment_status
FROM hospital_data_staging
WHERE appointment_id IS NOT NULL;

-- Populate Prescriptions
INSERT INTO prescriptions (prescriptionid, appointmentid, medication, dosage)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT prescription_id, prescription_appointment_id, prescription_medication, prescription_dosage
FROM hospital_data_staging
WHERE prescription_id IS NOT NULL;

-- Populate Bills, converting data types as we go
INSERT INTO bills (billid, appointmentid, amount, paid, billdate)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT bill_id, bill_appointment_id, bill_amount, (bill_paid = 1), TO_TIMESTAMP(bill_date, 'YYYY-MM-DD HH24:MI:SS')
FROM hospital_data_staging
WHERE bill_id IS NOT NULL;

-- Populate Lab Reports
INSERT INTO labreports (reportid, appointmentid, reportdata, createdAt)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT lab_report_id, lab_report_appointment_id, lab_report_data, TO_TIMESTAMP(lab_report_created_at, 'YYYY-MM-DD HH24:MI:SS')
FROM hospital_data_staging
WHERE lab_report_id IS NOT NULL;


-- (Optional) Step 4: Clean up by deleting the staging table after migration is successful.
DROP TABLE hospital_data_staging;

-- End of Script

