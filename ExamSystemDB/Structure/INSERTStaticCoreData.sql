USE ExamSystemDB;
GO
---1- INSERT Static Core Data---
------------------------------------
-- 1. ROLES
------------------------------------
INSERT INTO Roles (role_name, permissions) 
VALUES
	(N'Admin', N'Full System Access'),
	---
	(N'Training Manager', N'Manage Depts and Intakes'),
	---
	(N'Instructor', N'Create Exams & Grade'),
	---
	(N'Student', N'Take Exams');

------------------------------------
-- 2. DEPARTMENTS & BRANCHES
------------------------------------
INSERT INTO Department (dept_name) 
VALUES
	(N'Web Development'),
	--
	(N'Cloud Computing');
-- add manager_id  letar

INSERT INTO Branch (branch_name, location) 
VALUES
	(N'Downtown', N'San Francisco, CA'),
	--
	(N'Remote_Hub', N'Global Online');

------------------------------------
-- 3. QUESTION TYPES
------------------------------------
INSERT INTO QuestionType (type_name, has_options) 
VALUES
	(N'Multiple Choice', 1),
	(N'True/False', 1),
	(N'Essay', 0);

------------------------------------
-- 4. COURSES & TRACKS
------------------------------------
INSERT INTO Course (course_name, MaxDegree, MinDegree) 
VALUES
	(N'SQL Fundamentals', 100, 60),
	---
	(N'Python Core', 100, 50);

INSERT INTO Track (dept_id, track_name, description) 
VALUES
(
	(SELECT dept_id FROM Department WHERE dept_name = N'Web Development'),--dept_id
	N'Full Stack JS', N'Node.js & React curriculum' --track_name, description
),
-----
(
	(SELECT dept_id FROM Department WHERE dept_name = N'Cloud Computing'),--dept_id
	N'Azure/AWS Ops', N'Cloud deployment and security' --track_name, description
);

------------------------------------
-- 5. INTAKES
------------------------------------
INSERT INTO Intake (track_id, branch_id, intake_name, Start_date, end_date) 
VALUES
(
	(SELECT track_id FROM Track WHERE track_name = N'Full Stack JS'),--track_id
	(SELECT branch_id FROM Branch WHERE branch_name = N'Downtown'),  --branch_id
	N'2026-FALL-01', '2026-09-01', '2027-01-31' --intake_name, Start_date, end_date
);

------------------------------------
-- 6. QUESTION POOL
------------------------------------
INSERT INTO Question_Pool (question_type_id, course_id, question_text, marks, best_accepted_answer) 
VALUES
(
	(SELECT type_id FROM QuestionType WHERE type_name = N'Multiple Choice'), --question_type_id
	(SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals'), --course_id
	N'Which clause is used to filter results based on aggregate functions?', --question_text
	5.00, --marks
	NULL --NO best_accepted_answer FOR >(MCQ)
),

(
	(SELECT type_id FROM QuestionType WHERE type_name = N'Essay'), --question_type_id
	(SELECT course_id FROM Course WHERE course_name = N'Python Core'), --course_id
	N'Describe the concept of "Polymorphism" in Python.', --question_text
	10.00, --marks
	N'Polymorphism allows methods to do different things based on the object.' --best_accepted_answer
);
----------->
-- ADD MCQ
INSERT INTO Question_Option (question_id, option_id, option_text, is_correct) 
VALUES
(
	(SELECT question_id FROM Question_Pool WHERE marks = 5.00 AND course_id = --question_id
		(SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals')
	),
		1, N'WHERE', 0 --option_id, option_text, is_correct
),
----
(
	(SELECT question_id FROM Question_Pool WHERE marks = 5.00 AND course_id = --question_id
		(SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals')
	),
		2, N'GROUP BY', 0 --option_id, option_text, is_correct
),
----
(
	(SELECT question_id FROM Question_Pool WHERE marks = 5.00 AND course_id = --question_id
		(SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals')
	),
		3, N'HAVING', 1 --option_id, option_text, is_correct
),
----
(
	(SELECT question_id FROM Question_Pool WHERE marks = 5.00 AND course_id = --question_id
		(SELECT course_id FROM Course WHERE course_name = N'SQL Fundamentals')
	),
		4, N'ORDER BY', 0); --option_id, option_text, is_correct
-----