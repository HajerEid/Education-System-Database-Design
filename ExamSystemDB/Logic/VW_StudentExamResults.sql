USE ExamSystemDB;
GO

-- 2.displaying the detailed results of students' attempts.
CREATE VIEW VW_StudentExamResults
AS
SELECT
    ST.st_Fname + ' ' + ST.st_Lname AS Student_Name,
    C.course_name,
    E.exam_title,
    SEA.attempt_id,
    SEA.total_score AS Score_Achieved,
    E.total_marks AS Max_Score,
    -- Use the function to check the success status
    dbo.FN_CheckPassingStatus(SEA.total_score, C.course_id) AS Passing_Status,
    SEA.status AS Attempt_Status,
    SEA.end_time
FROM
    Student_Exam_Attempt SEA
INNER JOIN 
    Exam E ON SEA.exam_id = E.exam_id
INNER JOIN 
    Course C ON E.course_id = C.course_id
INNER JOIN 
    Student ST ON SEA.student_id = ST.student_id
WHERE
    SEA.status = N'Submitted'; -- Show only submitted attempts
GO

---------------------------------------
--CHECK:
SELECT * FROM VW_StudentExamResults;