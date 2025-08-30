-- This file contains the final, normalized schema for the HospitalDB.

-- Table to store department information
CREATE TABLE departments (
    departmentID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Table to store doctor information, linked to a department
CREATE TABLE doctors (
    doctorid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50),
    specialization VARCHAR(100),
    role VARCHAR(50),
    departmentid INT,
    FOREIGN KEY (departmentid) REFERENCES departments(departmentid)
);

-- Table to store patient information
CREATE TABLE patients (
    patientid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50),
    dateofbirth DATE,
    gender VARCHAR(1),
    phone VARCHAR(25),
    CHECK (gender IN ('m', 'f', 'o'))
);

-- Central table linking patients and doctors for appointments
CREATE TABLE appointments (
    appointmentid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patientid INT,
    doctorid INT,
    appointmentTime TIMESTAMP,
    status VARCHAR(50),
    FOREIGN KEY (patientid) REFERENCES patients(patientid),
    FOREIGN KEY (doctorid) REFERENCES doctors(doctorid),
    CHECK (status IN ('Scheduled', 'Completed', 'Cancelled'))
);

-- Table for prescriptions, linked to a specific appointment
CREATE TABLE prescriptions (
    prescriptionid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointmentid INT,
    medication VARCHAR(255),
    dosage VARCHAR(50),
    FOREIGN KEY (appointmentid) REFERENCES appointments(appointmentid)
);

-- Table for billing information, linked to a specific appointment
CREATE TABLE bills (
    billid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointmentid INT,
    amount DECIMAL(10, 2),
    paid BOOLEAN DEFAULT FALSE,
    billdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointmentid) REFERENCES appointments(appointmentid)
);

-- Table for lab reports, linked to a specific appointment
CREATE TABLE labreports (
    reportid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointmentid INT,
    reportdata TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointmentid) REFERENCES appointments(appointmentid)
);
