-- DROP TABLES SAFELY
BEGIN EXECUTE IMMEDIATE 'DROP TABLE review_logs CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE mentor_assignments CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE mentors CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE students CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/

-- CREATE TABLES
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(100) NOT NULL,
    student_email VARCHAR2(100) DEFAULT 'not_provided@example.com',
    student_phone VARCHAR2(15) DEFAULT 'N/A',
    course VARCHAR2(100) DEFAULT 'Undeclared',
    academic_year VARCHAR2(10) DEFAULT 'N/A'
);

CREATE TABLE mentors (
    mentor_id NUMBER PRIMARY KEY,
    mentor_name VARCHAR2(100) NOT NULL,
    mentor_email VARCHAR2(100) DEFAULT 'not_provided@example.com',
    mentor_phone VARCHAR2(15) DEFAULT 'N/A',
    department VARCHAR2(100) DEFAULT 'General'
);

CREATE TABLE mentor_assignments (
    assignment_id NUMBER PRIMARY KEY,
    student_id NUMBER REFERENCES students(student_id),
    mentor_id NUMBER REFERENCES mentors(mentor_id),
    assigned_on DATE DEFAULT SYSDATE
);

CREATE TABLE review_logs (
    review_id NUMBER PRIMARY KEY,
    assignment_id NUMBER REFERENCES mentor_assignments(assignment_id),
    review_date DATE DEFAULT SYSDATE,
    remarks VARCHAR2(500) NOT NULL
);

-- CREATE SEQUENCES
CREATE SEQUENCE student_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mentor_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE assignment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE review_seq START WITH 1 INCREMENT BY 1;

-- CREATE VIEW FOR APEX REPORTS/CHARTS
CREATE OR REPLACE VIEW student_review_summary AS
SELECT 
    s.student_id,
    s.student_name,
    COUNT(r.review_id) AS total_reviews
FROM students s
LEFT JOIN mentor_assignments a ON s.student_id = a.student_id
LEFT JOIN review_logs r ON a.assignment_id = r.assignment_id
GROUP BY s.student_id, s.student_name;
