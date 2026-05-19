USE ExamSystemDB;
GO
---3- INSERT Exam Setup and Attempt Simulation---
------------------------------------
-- 11. COURSE SESSION (set the course by instructor)
------------------------------------
INSERT INTO COURSE_SESSION (course_id, instructor_id, track_id, intake_id, start_date, end_date, semester) 
VALUES
(
    (SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals'),  --course_id
    (SELECT instructor_id FROM Instructor WHERE ins_Fname = N'David'), --instructor_id
    (SELECT track_id FROM Track WHERE track_name = N'Full Stack JS'), --track_id
    (SELECT intake_id FROM Intake WHERE intake_name = N'2026-FALL-01'), --intake_id
    '2026-10-01', '2026-11-30', N'Fall Semester' ---start_date, end_date, semester
);

------------------------------------
-- 12. EXAM (create)
------------------------------------
DECLARE @SQL_CourseID INT =
    (SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals');

DECLARE @Ins_ID INT =
    (SELECT instructor_id FROM Instructor WHERE ins_Fname = N'David');

INSERT INTO Exam (course_id, instructor_id, exam_title, exam_type, duration, total_marks, available_from, available_to) 
VALUES
(
    @SQL_CourseID, --get course_id from var.
    @Ins_ID, --get instructor_id from var.
    N'Midterm SQL Test', --exam_title
    'Exam', --exam_type
    60, 15.00, --duration, total_marks
    GETDATE(), --//from current 
    DATEADD(HOUR, 24, GETDATE()) --//during 24 Hour
); 

------------------------------------
-- 13. EXAM QUESTIONS (Link question by exam)
------------------------------------
DECLARE @ExamID INT = SCOPE_IDENTITY(); -- last Id created

DECLARE @Q_MCQ_ID INT = --add mcq question
    (
        SELECT question_id FROM Question_Pool 
        WHERE marks = 5.00 AND course_id = @SQL_CourseID
     );

DECLARE @Q_Essay_ID INT = --add written question
    (
         SELECT question_id FROM Question_Pool 
         WHERE marks = 10.00 AND course_id = 
            (SELECT course_id FROM Course 
            WHERE course_name = N'Python Core')
    ); -- add error [python question in sql exam] test only 
    -----dont allow wrong FK leter>> SP_CreateNewExam--

--add Question:
INSERT INTO Exam_Questions (exam_id, question_id, degree_weight) 
VALUES
    (@ExamID, @Q_MCQ_ID, 5.00), -- 5 degree 
    (@ExamID, @Q_Essay_ID, 10.00); -- 10 degree

------------------------------------
-- 14. EXAM ACCESS (add access for student)
------------------------------------
INSERT INTO Exam_Access (exam_id, student_id) 
VALUES
    (
        @ExamID,
        (SELECT student_id FROM Student WHERE st_Fname = N'Emily')
    );

------------------------------------
-- 15. STUDENT EXAM ATTEMPT (prossess <<start Exam>>)
------------------------------------
DECLARE @Stu_ID INT = 
    (SELECT student_id FROM Student WHERE st_Fname = N'Emily');

DECLARE @StartTime DATETIME2 = GETDATE(); --save current datetime

INSERT INTO Student_Exam_Attempt (student_id, exam_id, start_time, status) 
VALUES
(@Stu_ID, @ExamID, @StartTime, N'Started'); --set status > 

-- <<End Exam>> after 30 min 
DECLARE @AttemptID BIGINT = SCOPE_IDENTITY(); --last id (Student_Exam_Attempt)
DECLARE @EndTime DATETIME2 =
    DATEADD(MINUTE, 30, @StartTime);

--Update data 
UPDATE Student_Exam_Attempt
SET end_time = @EndTime,
    total_score = 15.00, -- full Marks
    status = N'Submitted' --change state 
WHERE attempt_id = @AttemptID;

------------------------------------
-- 16. STUDENT ANSWERS 
------------------------------------
INSERT INTO Student_Answers (attempt_id, question_id, selected_option_id, answer_text, awarded_marks) 
VALUES
    (@AttemptID, @Q_MCQ_ID, 3, NULL
    , 5.00),
    -- mcq Answer >correct chose 3 
    (@AttemptID, @Q_Essay_ID, NULL, 
    N'Polymorphism is the ability of an object to take on many forms.',
    10.00); -- written Answer > full Marks