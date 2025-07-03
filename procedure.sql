SET SERVEROUTPUT ON;

-- Add sample students
INSERT INTO students VALUES (1, 'Tenzin');
INSERT INTO students VALUES (2, 'Priya');

-- Add sample mentors
INSERT INTO mentors VALUES (1, 'Mr. Sharma');
INSERT INTO mentors VALUES (2, 'Ms. Kapoor');


-- Procedure to Assign a Mentor
CREATE OR REPLACE PROCEDURE assign_mentor(
    p_student_id IN NUMBER,
    p_mentor_id IN NUMBER
) IS
    v_assignment_id NUMBER;
BEGIN
    SELECT NVL(MAX(assignment_id), 0) + 1 INTO v_assignment_id FROM mentor_assignments;

    INSERT INTO mentor_assignments (assignment_id, student_id, mentor_id)
    VALUES (v_assignment_id, p_student_id, p_mentor_id);

    DBMS_OUTPUT.PUT_LINE('Mentor assigned. Assignment ID = ' || v_assignment_id);
END;
/

-- Procedure to Log a Review
CREATE OR REPLACE PROCEDURE log_review(
    p_assignment_id IN NUMBER,
    p_remarks IN VARCHAR2
) IS
    v_review_id NUMBER;
BEGIN
    SELECT NVL(MAX(review_id), 0) + 1 INTO v_review_id FROM review_logs;

    INSERT INTO review_logs (review_id, assignment_id, remarks)
    VALUES (v_review_id, p_assignment_id, p_remarks);

    DBMS_OUTPUT.PUT_LINE('Review logged successfully. Review ID = ' || v_review_id);
END;
/

-- Procedure to Fetch All Reviews by Student
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
        DBMS_OUTPUT.PUT_LINE('Date   : ' || rec.review_date);
        DBMS_OUTPUT.PUT_LINE('Remarks: ' || rec.remarks);
        DBMS_OUTPUT.PUT_LINE('-----------------------------');
    END LOOP;
END;
/

EXEC assign_mentor(1, 2);
EXEC log_review(1, 'Initial meeting and goals discussed.');
EXEC get_reviews_by_student(1);
