USE ExamSystemDB;
GO
--procedure: To grant access to the exam
CREATE OR ALTER PROCEDURE SP_GrantExamAccess
    @ExamID INT,
    @IntakeID INT,
    @GrantedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check the exam and Intake details
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE exam_id = @ExamID)
    BEGIN
        RAISERROR (N'Exam ID not found.', 16, 1);
        RETURN;
    END

    --Insert in Exam_Access :all stu. associated with the Intake (@IntakeID)
    INSERT INTO Exam_Access (exam_id, student_id, granted_at, granted_by)
    SELECT 
        @ExamID,
        S.student_id,
        GETDATE(),
        @GrantedBy -- instroctor / manger ID
    FROM 
        Student S
    WHERE 
        S.intake_id = @IntakeID

        -- Preventing the same student from get access to the same exam multiple times.
        AND NOT EXISTS (
            SELECT 1 FROM Exam_Access EA 
            WHERE EA.exam_id = @ExamID AND EA.student_id = S.student_id
        );

    SELECT CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' students granted access to Exam ID ' + CAST(@ExamID AS NVARCHAR(10)) AS StatusMessage;
END
GO

-----------------------------------------------------------------
--TEST:
USE ExamSystemDB;
GO
------1)Success status (granting access to a new Intake) :

-- 1. set test data(Exam, Intake, Instructor)
DECLARE @TestExamID INT = 
    (SELECT MAX(exam_id) FROM Exam); -- The latest exam created
DECLARE @TestIntakeID INT = 
    (SELECT intake_id FROM Intake 
        WHERE intake_name = N'2026-FALL-01'); -- The Intake that belongs "Emily" 
DECLARE @InstructorID INT = 
    (SELECT instructor_id FROM Instructor 
    WHERE ins_Fname = N'David'); -- The Instructor who grants access

-- 2. execute the procedure to grant access (must succeed).
EXEC SP_GrantExamAccess
    @ExamID = @TestExamID,
    @IntakeID = @TestIntakeID,
    @GrantedBy = @InstructorID; --"David" grants access

-- 3. CHECK Exam_Access
SELECT 
    EA.exam_id,
    ST.st_Fname + ' ' + ST.st_Lname AS Student_Name,
    U.username AS Granted_By_User,
    EA.granted_at
FROM 
    Exam_Access EA
INNER JOIN 
    Student ST ON EA.student_id = ST.student_id
INNER JOIN 
    Instructor INS ON EA.granted_by = INS.instructor_id
INNER JOIN
    Users U ON INS.user_id = U.user_id
WHERE 
    EA.exam_id = @TestExamID;
GO

--Expected Output: 
    --linking student Emily Jackson to the exam
    --and she was granted access by instructor David.

-----------------------------------------------------

--2)failure case (preventing redundancy)

DECLARE @TestExamID INT = 
    (SELECT MAX(exam_id) FROM Exam);
DECLARE @TestIntakeID INT = 
    (SELECT intake_id FROM Intake WHERE intake_name = N'2026-FALL-01');
DECLARE @InstructorID INT = 
    (SELECT instructor_id FROM Instructor WHERE ins_Fname = N'David');

-- Try execute again (the result should be 0 rows affected)
EXEC SP_GrantExamAccess
    @ExamID = @TestExamID,
    @IntakeID = @TestIntakeID,
    @GrantedBy = @InstructorID;

-- Check the number of records (must remain 1)
SELECT COUNT(*) AS Total_Access_Records
FROM Exam_Access
WHERE exam_id = @TestExamID;
GO