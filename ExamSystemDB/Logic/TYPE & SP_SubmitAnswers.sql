USE ExamSystemDB;
GO

-- 1. create new TYPE {list of student Answer }
CREATE TYPE dbo.AnswerListType AS TABLE
(
    QuestionID INT NOT NULL,
    SelectedOptionID INT NULL, -- (MCQ/T&F)
    AnswerText NVARCHAR(MAX) NULL, -- (Essay)
    AwardedMarks DECIMAL(5, 2) NULL --for essay answers that may be corrected later by the instructor.
);
GO
----------------------------------------------------------
USE ExamSystemDB;
GO

-- 2. Procedure: To record answers and calculate the final grade
CREATE OR ALTER PROCEDURE SP_SubmitAnswers
    @AttemptID BIGINT,
    @StudentAnswers dbo.AnswerListType READONLY -- Pass the answer list as a table
AS
BEGIN
    SET NOCOUNT ON;
    -- Everything must be executed successfully or fail completely (Transaction) >
    BEGIN TRANSACTION;
    
    DECLARE @CalculatedScore DECIMAL(5, 2);

    -- 1. Insert all answers from "the passed list" into a "Student_Answers"
    -- 
    INSERT INTO Student_Answers (attempt_id, question_id, selected_option_id, answer_text, awarded_marks)
    SELECT 
        @AttemptID,
        QuestionID,
        SelectedOptionID,
        AnswerText,
        AwardedMarks --It is sent from the Form (usually NULL or 0 at this stage)
    FROM 
        @StudentAnswers;

    -- 2. Setting the time for the attempt to end
    DECLARE @EndTime DATETIME2 = GETDATE();

    -- 3. Update End time and attempt status
    UPDATE Student_Exam_Attempt
    SET 
        end_time = @EndTime,
        status = N'Submitted' 
    WHERE 
        attempt_id = @AttemptID;

    -- 4. Calculate the final grade using the function :
    SET @CalculatedScore = dbo.FN_CalculateAttemptScore(@AttemptID);

    -- 5. Update the final overall grade in the Student_Exam_Attempt table
    UPDATE Student_Exam_Attempt
    SET 
        total_score = @CalculatedScore
    WHERE 
        attempt_id = @AttemptID;

    -- 6. End of TRANSACTION 
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR (N'An error occurred during submission. Transaction rolled back.', 16, 1);
        RETURN;
    END

    COMMIT TRANSACTION;
    
    SELECT N'Exam submitted successfully. Calculated Score: ' + CAST(@CalculatedScore AS NVARCHAR(10)) AS Status;
END
GO

-------------------------------------------------------------------------
--TEST:
USE ExamSystemDB;
GO

-- 1. set test data (Exam, Student)
DECLARE @TestExamID INT = 
    (SELECT MAX(exam_id) FROM Exam); -- The latest exam created
DECLARE @StudentID INT = 
    (SELECT student_id FROM Student WHERE st_Fname = N'Emily'); 

-- 2. Simulating the start of the exam (creating a new attempt)
INSERT INTO Student_Exam_Attempt (student_id, exam_id, start_time, status)
VALUES (@StudentID, @TestExamID, GETDATE(), N'Started');

DECLARE @NewAttemptID BIGINT = SCOPE_IDENTITY(); -- Get ID (New Attempt)

-- 3. Preparing the answer list (including automatic correction)
DECLARE @Answers AS dbo.AnswerListType;

-- Answer to the MCQ question (the correct option is 3)
INSERT INTO @Answers (QuestionID, SelectedOptionID, AnswerText, AwardedMarks)
VALUES (
        (SELECT question_id FROM Question_Pool 
        WHERE marks = 5.00 AND course_id = 
            (SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals')
        ),
        3, -- correct answer
        NULL,
        0.00 -- Leave 0.00 here, and the function will handle the correction.
);

-- Answering the essay question (requires manual correction later)
INSERT INTO @Answers (QuestionID, SelectedOptionID, AnswerText, AwardedMarks)
VALUES (
        (SELECT question_id FROM Question_Pool WHERE marks = 10.00 AND course_id = 
            (SELECT course_id FROM Course WHERE course_name = N'Python Core')
        ),
    NULL,
    N'Polymorphism allows methods to do different things based on the object.',
    --set the full score for the test here > 10.00, 
    -- but in practice it will be 0 until manual correction.
    10.00 
);

-- 4.Implementing the procedure to provide answers
EXEC SP_SubmitAnswers
    @AttemptID = @NewAttemptID,
    @StudentAnswers = @Answers;

-- 5. Check the final score (it must be 15.00)
SELECT 
    attempt_id,
    start_time,
    end_time,
    total_score, --> it must be 15.00
    status 
FROM Student_Exam_Attempt
WHERE attempt_id = @NewAttemptID;
GO