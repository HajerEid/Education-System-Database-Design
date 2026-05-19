USE ExamSystemDB;
GO

-- 1. TRIGGER > Prevent deletion of a user associated with a sub-entity (Instructor or manager)
CREATE OR ALTER TRIGGER TR_PreventUserDeletion
ON Users
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Verify user association with > Train_Manager ?
    IF EXISTS (
        SELECT 1
        FROM deleted AS d
        INNER JOIN Train_Manager AS tm
        ON d.user_id = tm.user_id
    )
    BEGIN
        RAISERROR (N'Cannot delete a user who is currently assigned as a Training Manager.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Verify user association with > Instructor ?
    IF EXISTS (
        SELECT 1
        FROM deleted AS d
        INNER JOIN Instructor AS i 
        ON d.user_id = i.user_id
    )
    BEGIN
        RAISERROR (N'Cannot delete a user who is currently registered as an Instructor.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Verify user association with > Student ?
    IF EXISTS (
        SELECT 1
        FROM deleted AS d
        INNER JOIN Student AS s 
        ON d.user_id = s.user_id
    )
    BEGIN
        RAISERROR (N'Cannot delete a user who is currently registered as a Student.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If there is no association, Run the original deletion operation.
    DELETE FROM Users
    WHERE user_id IN (SELECT user_id FROM deleted);
END
GO



---------------------------------------------------------------------
--test:
--Deletion Failure Case:
DELETE FROM Users 
WHERE username = 'manager_karen';
GO

--Deletion success Case:
-- 1. create temp user
INSERT INTO Users (role_id, username, email, user_password) 
VALUES ((SELECT role_id FROM Roles WHERE role_name = N'Student'), 'temp_user', 'temp@example.com', 'TempPass');
GO

-- 2.display temp user
SELECT * FROM Users WHERE username = 'temp_user';
GO

-- 3. try delete user [success]
DELETE FROM Users 
WHERE username = 'temp_user';
GO

-- 4. check 
SELECT * FROM Users WHERE username = 'temp_user';
GO