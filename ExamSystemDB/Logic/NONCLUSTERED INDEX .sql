USE ExamSystemDB;
GO
-------1) Indexing of master transaction tables
-- 1. Indexing answers by attempt number
CREATE NONCLUSTERED INDEX IX_StudentAnswers_Attempt 
ON Student_Answers (attempt_id);

-- 2. Indexing exam attempts (to search for a student's attempt)
CREATE NONCLUSTERED INDEX IX_Attempt_StudentExam 
ON Student_Exam_Attempt (student_id, exam_id);

-- 3. Indexing exam questions (to retrieve exam content)
CREATE NONCLUSTERED INDEX IX_ExamQuestions_Exam
ON Exam_Questions (exam_id);


--------2) Indexing of Foreign Key Tables:


-- 4. Indexing users by role
CREATE NONCLUSTERED INDEX IX_Users_RoleID
ON Users (role_id);

-- 5. Indexing trainers by user and department
CREATE NONCLUSTERED INDEX IX_Instructor_UserDept
ON Instructor (user_id, dept_id);

-- 6. Indexing the question bank by course and type
CREATE NONCLUSTERED INDEX IX_QuestionPool_CourseType
ON Question_Pool (course_id, question_type_id);

-- 7. Indexing students by Intake
CREATE NONCLUSTERED INDEX IX_Student_Intake
ON Student (intake_id);
GO

