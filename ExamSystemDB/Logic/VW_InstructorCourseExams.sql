USE ExamSystemDB;
GO

-- 1. display exam and course summaries (for Instructors/Managers)
CREATE OR ALTER VIEW VW_InstructorCourseExams
AS
SELECT
    E.exam_id,
    E.exam_title,
    C.course_name,
    E.total_marks,
    U_Ins.username AS Instructor_Name,
    -- Number of students who started Attempt
    COUNT(SEA.attempt_id) AS Total_Attempts, 
    E.available_from,
    E.available_to
FROM
    Exam E
INNER JOIN 
    Course C ON E.course_id = C.course_id
INNER JOIN 
    Instructor I ON E.instructor_id = I.instructor_id
INNER JOIN 
    Users U_Ins ON I.user_id = U_Ins.user_id
LEFT JOIN --to show even exams that no one has taken.
    Student_Exam_Attempt SEA ON E.exam_id = SEA.exam_id
GROUP BY
    E.exam_id,
    E.exam_title,
    C.course_name,
    E.total_marks,
    U_Ins.username,
    E.available_from,
    E.available_to;
GO

---------------------------
--CHECK:
SELECT * FROM VW_InstructorCourseExams;