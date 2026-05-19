USE ExamSystemDB;
GO

--Procedure: Create the exam & randomly draw questions.
CREATE OR ALTER PROCEDURE SP_CreateNewExam
    @CourseID INT,
    @InstructorID INT,
    @Title NVARCHAR(255),
    @ExamType VARCHAR(50), -- 'Exam' or 'Corrective'
    @Duration SMALLINT,
    @AvailableFrom DATETIME2,
    @AvailableTo DATETIME2,
    @TotalMarks DECIMAL(5,2),
    @NumQuestions INT 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewExamID INT;
    DECLARE @MarkPerQuestion DECIMAL(5,2);

    -- 1. Ensure that the required questions are in the question bank.
    IF (
        SELECT COUNT(*) 
        FROM Question_Pool 
        WHERE course_id = @CourseID
        )   < @NumQuestions
    BEGIN
        RAISERROR (N'Insufficient number of questions available in the question pool for this course.', 16, 1);
        RETURN;
    END
    --Calculating grades
    SET @MarkPerQuestion = @TotalMarks / @NumQuestions;

    -- 2. Insert into the Exam Table
    INSERT INTO Exam (course_id, instructor_id, exam_title, exam_type, duration, total_marks, available_from, available_to)
    VALUES 
        (@CourseID, @InstructorID, @Title, @ExamType, @Duration, @TotalMarks, @AvailableFrom, @AvailableTo);

    SET @NewExamID = SCOPE_IDENTITY();

    -- 3. Randomly pull questions and associate them with Exam_Questions:

    ---Linking Questions---
    -- This logic ensures that the pulled questions are only for the exam session.
    INSERT INTO Exam_Questions (exam_id, question_id, degree_weight)

    SELECT TOP (@NumQuestions)
        @NewExamID AS exam_id,
        qp.question_id,
        @MarkPerQuestion -- Distribute the grade equally
    FROM Question_Pool AS qp
    WHERE qp.course_id = @CourseID 
    ORDER BY NEWID(); -- Random withdrawal order (generate id/row)

    SELECT @NewExamID AS CreatedExamID,
           N'Exam created successfully with ' + CAST(@NumQuestions AS NVARCHAR(10)) + N' questions.' AS StatusMessage;
END
GO

---------------------------------------------------------------------------------------
--Test--
--> success Case:
-- 1.ID course & instructor 
DECLARE @SQL_CourseID INT = (SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals');
DECLARE @Instructor_ID INT = (SELECT instructor_id FROM Instructor WHERE ins_Fname = N'David');

-- 2. Run Procedure to create Exam:
EXEC SP_CreateNewExam
    @CourseID = @SQL_CourseID,
    @InstructorID = @Instructor_ID,
    @Title = N'SQL Fundamentals Final Exam',
    @ExamType = 'Exam',
    @Duration = 90,
    @AvailableFrom = '2026-12-10',
    @AvailableTo = '2026-12-15',
    @TotalMarks = 20.00,  
    @NumQuestions = 1;    -- pic random Question > 1
GO
--Failure Case:
/**
    @NumQuestions = 5; < more than number of Question in curent dataset >
**/

--check 
SELECT * FROM Exam
