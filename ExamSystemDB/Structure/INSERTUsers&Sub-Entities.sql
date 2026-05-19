USE ExamSystemDB;
GO
---2- INSERT Users and Sub-Entities---
------------------------------------
-- 7. USERS: LINK tables with system Structure 
------------------------------------
INSERT INTO Users (role_id, username, email, user_password) VALUES
(
	(SELECT role_id FROM Roles WHERE role_name = N'Training Manager'),
	'manager_karen', 'karen.g@exam.com', 'KPass123'
),
--
(
	(SELECT role_id FROM Roles WHERE role_name = N'Instructor'),
	'ins_david', 'david.b@exam.com', 'IPass123'
),
--
(	(SELECT role_id FROM Roles WHERE role_name = N'Student'),
	'stu_emily', 'emily.j@exam.com', 'SPass123'
);

------------------------------------
-- 8. TRAINING MANAGER (Sub-Entitie)
------------------------------------
INSERT INTO Train_Manager (user_id, M_Fname, M_Lname) 
VALUES
(
	(SELECT user_id FROM Users WHERE username = 'manager_karen'),
	N'Karen', N'Grant'
);

-- Add manager for department:
UPDATE Department 
SET manager_id =
	(SELECT manager_id FROM Train_Manager WHERE M_Fname = N'Karen')
WHERE dept_name = N'Web Development';

------------------------------------
-- 9. INSTRUCTOR (Sub-Entitie)
------------------------------------
INSERT INTO Instructor (user_id, dept_id, specialization, ins_Fname, ins_Lname) 
VALUES
(
	(SELECT user_id FROM Users WHERE username = 'ins_david'), --user_id
	(SELECT dept_id FROM Department WHERE dept_name = N'Web Development'), --dept_id
	N'SQL & Python', N'David', N'Barnes' --specialization, ins_Fname, ins_Lname
);

------------------------------------
-- 10. STUDENT (Sub-Entitie)
------------------------------------
INSERT INTO Student (user_id, intake_id, enrollment_date, gender, st_Fname, st_Lname) 
VALUES
(
	(SELECT user_id FROM Users WHERE username = 'stu_emily'), --user_id
	(SELECT intake_id FROM Intake WHERE intake_name = N'2026-FALL-01'), --intake_id
	'2026-08-15', 'F', N'Emily', N'Jackson' --enrollment_date, gender, st_Fname, st_Lname
);