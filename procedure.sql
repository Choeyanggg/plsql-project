-- Sample inserts using sequences
INSERT INTO students VALUES (student_seq.NEXTVAL, 'Choeyang');
INSERT INTO students VALUES (student_seq.NEXTVAL, 'Dhargyal');

INSERT INTO mentors VALUES (mentor_seq.NEXTVAL, 'Mr. Phagyal');
INSERT INTO mentors VALUES (mentor_seq.NEXTVAL, 'Ms. Lhamo');

-- Assign Mentor Procedure with OUT message
CREATE OR REPLACE PROCEDURE assign_mentor(
    p_student_id IN NUMBER,
    p_mentor_id IN NUMBER,
    p_message OUT VARCHAR2
) IS
    v_assignment_id NUMBER;
BEGIN
    v_assignment_id := assignment_seq.NEXTVAL;

    INSERT INTO mentor_assignments (assignment_id, student_id, mentor_id)
    VALUES (v_assignment_id, p_student_id, p_mentor_id);

    p_message := 'Mentor assigned successfully. Assignment ID = ' || v_assignment_id;
EXCEPTION
    WHEN OTHERS THEN
        p_message := 'Error assigning mentor: ' || SQLERRM;
END;
/

-- Log Review Procedure with OUT message
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

-- Procedure to Fetch Reviews by Student (console only)
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

-- Function: Get Total Reviews for a Student
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

-- Trigger to Auto-log Review
CREATE OR REPLACE TRIGGER auto_review_on_assignment
AFTER INSERT ON mentor_assignments
FOR EACH ROW
BEGIN
    INSERT INTO review_logs (
        review_id, assignment_id, remarks
    ) VALUES (
        review_seq.NEXTVAL,
        :NEW.assignment_id,
        'Auto-generated review on mentor assignment.'
    );
END;
/
