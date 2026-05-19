USE ExamSystemDB;
GO

--Function: To calculate the [total score] for a student's exam attempt
CREATE OR ALTER FUNCTION FN_CalculateAttemptScore (@AttemptID BIGINT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @TotalScore DECIMAL(5, 2) = 0.00;

   -- Calculating the score for <automatically graded> questions (MCQ, True/False)
    SELECT @TotalScore = SUM(
        -- use the CASE > to check if the answer is correct.
        CASE
            -- 1. Check the correct answer (MCQ/T&F)
            WHEN T.has_options = 1 
                AND SA.selected_option_id IS NOT NULL  -- The selected answer must be present
                AND QOC.is_correct = 1 --check correct linked option
            THEN EQ.degree_weight  -- Award full marks
            
           -- Case 2: Essay or objective questions where automatic grading failed
               --rely on the [grade manually] awarded by > instructor (awarded_marks).
            WHEN T.has_options = 0 
            THEN SA.awarded_marks 
            
            ELSE 0.00 -- other cases (wrong answer or question not answered automatically)
        END
    )
    FROM Student_Answers SA
    INNER JOIN 
        Question_Pool QP ON SA.question_id = QP.question_id
    INNER JOIN 
        QuestionType T ON QP.question_type_id = T.type_id
    INNER JOIN 
        Exam_Questions EQ ON SA.question_id = EQ.question_id

    --Link with options table > to check correct option
   
    LEFT JOIN  ---the written Question has no option <LEFT>
        Question_Option QOC ON SA.question_id = QOC.question_id 
            AND SA.selected_option_id = QOC.option_id --link stu. Answer with choice in QuestionPool
    
    
    WHERE SA.attempt_id = @AttemptID;
    RETURN @TotalScore;
END
GO



------------------------------------------------------------
--TEST:
USE ExamSystemDB;
GO

-- set Student_Exam_Attempt(AttemptID) for student: Emily
DECLARE @EmilyAttemptID BIGINT = (
    SELECT TOP 1 attempt_id 
    FROM Student_Exam_Attempt 
    WHERE student_id = 
    (SELECT student_id FROM Student WHERE st_Fname = N'Emily')
    ORDER BY attempt_id DESC
);
-- set(MCQ) and (Essay) question
DECLARE @Q_MCQ_ID INT = (
    SELECT question_id FROM Question_Pool 
    WHERE marks = 5.00 AND course_id = 
    (SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals')
);
DECLARE @Q_Essay_ID INT = (
    SELECT question_id FROM Question_Pool 
    WHERE marks = 10.00 AND course_id = 
    (SELECT course_id FROM Course WHERE course_name = N'Python Core')
);

SELECT N'--- TEST FUNCTION FN_CalculateAttemptScore ---';
--***********************************
------ 1) Sucess All Case:
-- 1. set Answers :
-- MCQ: corect Answer = 3
UPDATE Student_Answers
SET selected_option_id = 3, awarded_marks = 5.00 
WHERE attempt_id = @EmilyAttemptID AND question_id = @Q_MCQ_ID;
-- Essay: Grade = 10.00
UPDATE Student_Answers
SET selected_option_id = NULL, awarded_marks = 10.00 
WHERE attempt_id = @EmilyAttemptID AND question_id = @Q_Essay_ID;

-- 2. call FUNCTION
SELECT 
    N'1. Sucess All Case (MCQ corect option + Essay 10)' AS Test_Case,
    dbo.FN_CalculateAttemptScore(@EmilyAttemptID) AS Calculated_Score,
    15.00 AS Expected_Score;
GO
----------->
-----------2 ) Fail On MCQ Case:
-- 1. the Answer of  MCQ Wrong =4
UPDATE Student_Answers
SET selected_option_id = 4, awarded_marks = 0.00 
    -- FUCTION must ignore { awarded_marks = 0.00 } , Depend Auto Correct
WHERE attempt_id = @EmilyAttemptID AND question_id = @Q_MCQ_ID;

-- 2. call FUNCTION
SELECT 
    N'2. Fail On MCQ CAse (MCQ wrong option + Essay 10)' AS Test_Case,
    dbo.FN_CalculateAttemptScore(@EmilyAttemptID) AS Calculated_Score,
    10.00 AS Expected_Score;
GO
-------------->
-------------- 3) Fail All Case:
-- 1. set Essay grade = 0 
UPDATE Student_Answers
SET awarded_marks = 0.00 
WHERE attempt_id = @EmilyAttemptID AND question_id = @Q_Essay_ID;

-- 2. call FUNCTION
SELECT 
    N'3. Fail All Case (MCQ wrong option + Essay 0)' AS Test_Case,
    dbo.FN_CalculateAttemptScore(@EmilyAttemptID) AS Calculated_Score,
    0.00 AS Expected_Score;
GO

---------
--==Create the stored procedure SP_SubmitAnswers: 
--==1. will record the student's answers 
--==2. call function <FN_CalculateAttemptScore> :
--== >to calculate the final score and update the attempt status.