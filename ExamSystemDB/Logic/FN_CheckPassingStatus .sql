USE ExamSystemDB;
GO
--function : to Comparing the exam score & min passing grade (course).
CREATE OR ALTER FUNCTION FN_CheckPassingStatus 
(
    @Score DECIMAL(5, 2),
    @CourseID INT
)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @MinDegree DECIMAL(5, 2);
    
    -- get the minimum passing grade from the course table.
    SELECT @MinDegree = MinDegree
    FROM Course
    WHERE course_id = @CourseID;

    IF @Score >= @MinDegree
        RETURN N'Passed';
    
    RETURN N'Failed';
END
GO

----------------------------------------
--TEST:

USE ExamSystemDB;
GO

-- 1.get ID > course SQL Fundamentals
DECLARE @SQL_CourseID INT = 
    (SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals');

-- Case 1: Pass (Grade = 65.00)
SELECT 
    dbo.FN_CheckPassingStatus(65.00, @SQL_CourseID) AS Passing_Status,
    N'Expected result: Passed' AS Test_Case;

-- Case 2: Failure (Grade = 55.00)
SELECT 
    dbo.FN_CheckPassingStatus(55.00, @SQL_CourseID) AS Passing_Status,
    N'Expected result: Failed' AS Test_Case;
GO