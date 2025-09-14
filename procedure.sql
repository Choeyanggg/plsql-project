SET SERVEROUTPUT ON;

INSERT INTO students 
VALUES (student_seq.NEXTVAL, 'Choeyang', 'choeyang@email.com', '9876543210', 'CSE', '3rd');

INSERT INTO students 
VALUES (student_seq.NEXTVAL, 'Dhargyal', 'dhargyal@email.com', '9876543211', 'ECE', '2nd');

INSERT INTO mentors 
VALUES (mentor_seq.NEXTVAL, 'Mr. Phagyal', 'phagyal@university.edu', '1234567890', 'Computer Science');

INSERT INTO mentors 
VALUES (mentor_seq.NEXTVAL, 'Ms. Lhamo', 'lhamo@university.edu', '1234567891', 'Electronics');


-- PROCEDURE: Assign Mentor and Add Remarks Together
CREATE OR REPLACE PROCEDURE assign_mentor_with_review(
    p_student_id IN NUMBER,
    p_mentor_id IN NUMBER,
    p_remarks IN VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_assignment_id NUMBER;
    v_review_id NUMBER;
BEGIN
    v_assignment_id := assignment_seq.NEXTVAL;

    INSERT INTO mentor_assignments (assignment_id, student_id, mentor_id)
    VALUES (v_assignment_id, p_student_id, p_mentor_id);

    v_review_id := review_seq.NEXTVAL;

    INSERT INTO review_logs (review_id, assignment_id, remarks)
    VALUES (v_review_id, v_assignment_id, p_remarks);

    p_message := 'Mentor assigned with your remarks. Assignment ID = ' || v_assignment_id;
EXCEPTION
    WHEN OTHERS THEN
        p_message := 'Error: ' || SQLERRM;
END;
/

DECLARE
  v_msg VARCHAR2(200);
BEGIN
  assign_mentor_with_review(1, 1, 'Initial mentor assignment remark', v_msg);
  DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/


-- PROCEDURE: Log Review Separately
CREATE OR REPLACE PROCEDURE log_review(
    p_assignment_id IN NUMBER,
    p_remarks IN VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_review_id NUMBER;
BEGIN
    v_review_id := review_seq.NEXTVAL;

    INSERT INTO review_logs (review_id, assignment_id, remarks)
    VALUES (v_review_id, p_assignment_id, p_remarks);

    p_message := 'Review logged successfully. Review ID = ' || v_review_id;
EXCEPTION
    WHEN OTHERS THEN
        p_message := 'Error logging review: ' || SQLERRM;
END;
/

DECLARE
  v_msg VARCHAR2(200);
BEGIN
  log_review(1, 'Working on PLSQL', v_msg);
  DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/


-- PROCEDURE: View Reviews by Student
CREATE OR REPLACE PROCEDURE get_reviews_by_student(
    p_student_id IN NUMBER
) IS
BEGIN
    FOR rec IN (
        SELECT s.student_name, m.mentor_name, r.review_date, r.remarks
        FROM students s
        JOIN mentor_assignments a ON s.student_id = a.student_id
        JOIN mentors m ON m.mentor_id = a.mentor_id
        JOIN review_logs r ON r.assignment_id = a.assignment_id
        WHERE s.student_id = p_student_id
        ORDER BY r.review_date
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Student: ' || rec.student_name);
        DBMS_OUTPUT.PUT_LINE('Mentor : ' || rec.mentor_name);
        DBMS_OUTPUT.PUT_LINE('Date   : ' || TO_CHAR(rec.review_date, 'DD-MM-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('Remarks: ' || rec.remarks);
        DBMS_OUTPUT.PUT_LINE('-----------------------------');
    END LOOP;
END;
/

BEGIN
  get_reviews_by_student(1);
END;
/


-- FUNCTION: Get Total Reviews by Student
CREATE OR REPLACE FUNCTION get_total_reviews(p_student_id IN NUMBER)
RETURN NUMBER
IS
    v_total_reviews NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_reviews
    FROM review_logs r
    JOIN mentor_assignments a ON r.assignment_id = a.assignment_id
    WHERE a.student_id = p_student_id;

    RETURN v_total_reviews;
END;
/

DECLARE
  v_total NUMBER;
BEGIN
  v_total := get_total_reviews(1);
  DBMS_OUTPUT.PUT_LINE('Total reviews for student 1: ' || v_total);
END;
/


-- TRIGGER: Only insert auto review if one doesn't exist
CREATE OR REPLACE TRIGGER auto_review_on_assignment
AFTER INSERT ON mentor_assignments
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM review_logs
    WHERE assignment_id = :NEW.assignment_id;

    IF v_count = 0 THEN
        INSERT INTO review_logs (
            review_id, assignment_id, remarks
        ) VALUES (
            review_seq.NEXTVAL,
            :NEW.assignment_id,
            'Auto-generated review on mentor assignment.'
        );
    END IF;
END;
/

-- Test insert to trigger auto review and display it
DECLARE
    v_new_assignment_id NUMBER;
BEGIN
    v_new_assignment_id := assignment_seq.NEXTVAL;
    INSERT INTO mentor_assignments (assignment_id, student_id, mentor_id) 
    VALUES (v_new_assignment_id, 2, 2);

    FOR rec IN (
        SELECT review_id, remarks, review_date
        FROM review_logs WHERE assignment_id = v_new_assignment_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Auto Review ID: ' || rec.review_id);
        DBMS_OUTPUT.PUT_LINE('Remarks     : ' || rec.remarks);
        DBMS_OUTPUT.PUT_LINE('Date        : ' || TO_CHAR(rec.review_date, 'DD-MM-YYYY HH24:MI'));
    END LOOP;
END;
/
