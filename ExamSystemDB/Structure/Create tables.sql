USE ExamSystemDB;
GO
-- 1. ROLES
CREATE TABLE Roles (
    role_id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE,
    permissions VARCHAR(MAX) NULL 
) ON [PRIMARY];

--2. Account >FG_Users
CREATE TABLE Users (
    user_id INT IDENTITY(10000,1) PRIMARY KEY,
    role_id SMALLINT NOT NULL REFERENCES Roles(role_id),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_password VARCHAR(255) NOT NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
) ON FG_Users

--3. Training_Manager >FG_Users
CREATE TABLE Train_Manager (
    manager_id INT IDENTITY(100,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES Users(user_id),
    M_Fname NVARCHAR(50) NOT NULL,
    M_Lname NVARCHAR(50) NOT NULL,
) ON FG_Users

--4. Department >FG_structure
CREATE TABLE Department (
    dept_id SMALLINT IDENTITY(10,10) PRIMARY KEY,
    dept_name NVARCHAR(100) NOT NULL UNIQUE,
    manager_id INT NULL FOREIGN KEY REFERENCES Train_Manager(manager_id)
) ON FG_structure

--5. branch >FG_structure
CREATE TABLE Branch (
    branch_id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    branch_name NVARCHAR(100) NOT NULL UNIQUE,
    location NVARCHAR(255) NULL
) ON FG_structure

--6. track >FG_Courses
CREATE TABLE Track (
    track_id SMALLINT IDENTITY(101,1) PRIMARY KEY,
    dept_id SMALLINT NOT NULL REFERENCES Department(dept_id),
    track_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(MAX) NULL
) ON FG_Courses

--7. intake >FG_structure
CREATE TABLE Intake (
    intake_id INT IDENTITY(2000,100) PRIMARY KEY,
    track_id SMALLINT NOT NULL REFERENCES Track(track_id), 
    branch_id SMALLINT NOT NULL REFERENCES Branch(branch_id), 
    intake_name NVARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    CONSTRAINT CHK_Intake_Dates CHECK (end_date >= start_date)
) ON FG_structure

--8 .course >FG_Courses
CREATE TABLE course (
    course_id INT IDENTITY(20,20) PRIMARY KEY,
    course_name NVARCHAR(150) NOT NULL UNIQUE,
    description NVARCHAR(MAX) NULL,
    credits SMALLINT NULL,
    MaxDegree INT NOT NULL CHECK (MaxDegree > 0) ,
    MinDegree INT NOT NULL CHECK (MinDegree >= 0) ,


    CONSTRAINT CHK_MinDegree_LessThan_MaxDegree CHECK (MinDegree <= MaxDegree)
) ON FG_Courses


--9.Instructor >FG_Users
CREATE TABLE Instructor (
    instructor_id INT IDENTITY(20000,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES Users(user_id),
    dept_id SMALLINT NOT NULL REFERENCES Department(dept_id), 
    specialization VARCHAR(100) NULL,
    ins_Fname NVARCHAR(50)  NOT NULL,
    ins_Lname NVARCHAR(50)  NOT NULL,
) ON FG_Users


--10 .COURSE_SESSION >FG_Courses
CREATE TABLE COURSE_SESSION (
    assignment_id INT IDENTITY(5,5) PRIMARY KEY,
    course_id INT NOT NULL REFERENCES Course(course_id),
    instructor_id INT NOT NULL REFERENCES Instructor(instructor_id), 
    track_id SMALLINT NOT NULL REFERENCES Track(track_id), 
    intake_id INT NOT NULL REFERENCES Intake(intake_id), 
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    semester NVARCHAR(50) NOT NULL,

    CONSTRAINT UQ_CourseAssignment UNIQUE (course_id, instructor_id, track_id, intake_id),
    CONSTRAINT CHK_Session_Dates CHECK (end_date >= start_date)
) ON FG_Courses

--11 .Student >FG_Users
CREATE TABLE Student (
    student_id INT IDENTITY(30000,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES Users(user_id), 
    intake_id INT NOT NULL REFERENCES Intake(intake_id), 
    enrollment_date DATE NOT NULL,
    gender	CHAR(1) CHECK (gender IN ('F','M')) ,
    st_Fname NVARCHAR(15)  NOT NULL ,
    st_Lname NVARCHAR(15)  NOT NULL ,
) ON FG_Users

--12 .Exam >FG_Exams
CREATE TABLE Exam (
    exam_id INT IDENTITY(900,9) PRIMARY KEY,
    course_id INT NOT NULL REFERENCES Course(course_id),
    instructor_id INT NOT NULL REFERENCES Instructor(instructor_id), 
    exam_title NVARCHAR(255) NOT NULL,
    exam_type VARCHAR(50) NOT NULL, --'exam or corrective'
    duration SMALLINT NOT NULL,
    total_marks DECIMAL(5,2) NOT NULL,
    available_from DATETIME2 NOT NULL,
    available_to DATETIME2 NOT NULL,

    CONSTRAINT CHK_Exam_Availability CHECK (available_to >= available_from)
) ON FG_Exams

--13 .Exam_Access >FG_Exams
CREATE TABLE Exam_Access (
    exam_id INT NOT NULL REFERENCES Exam(exam_id), 
    student_id INT NOT NULL REFERENCES Student(student_id), 
    granted_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    granted_by INT NULL, --Link with ex. Instructor/Trainer  

    PRIMARY KEY (exam_id, student_id)
) ON FG_Exams

-- 14. QUESTION_TYPE
CREATE TABLE QuestionType (
    type_id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL UNIQUE,
    has_options BIT NOT NULL , -- USE QuestionOption OR NOT ? 
) ON [PRIMARY];

--15.QUESTION_POOL >FG_Exams
CREATE TABLE Question_Pool (
    question_id INT IDENTITY(500,10) PRIMARY KEY,
    question_type_id SMALLINT NOT NULL REFERENCES QuestionType(type_id), 
    course_id INT NOT NULL REFERENCES Course(course_id), 
    question_text NVARCHAR(MAX) NOT NULL,
    marks DECIMAL(4,2) NOT NULL,
    best_accepted_answer NVARCHAR(MAX) NULL ,--COVER written answer
) ON FG_Exams

--16.Question_Option >FG_Exams
CREATE TABLE Question_Option (
    question_id INT NOT NULL REFERENCES Question_Pool(question_id), 
    option_id SMALLINT NOT NULL, 
    option_text NVARCHAR(MAX) NOT NULL,
    is_correct BIT NOT NULL, -- Correct Answer

    PRIMARY KEY (question_id, option_id)
) ON FG_Exams

--17. EXAM_QUESTIONS >FG_Exams
CREATE TABLE Exam_Questions (
    exam_id INT NOT NULL REFERENCES Exam(exam_id), 
    question_id INT NOT NULL REFERENCES Question_Pool(question_id),
    degree_weight DECIMAL(4,2) NOT NULL, --Degree Question in the current Exam

    PRIMARY KEY (exam_id, question_id)
) ON FG_Exams;


--18. STUDENT_EXAM_ATTEMPT >FG_Results
CREATE TABLE Student_Exam_Attempt (
    attempt_id BIGINT IDENTITY(1000000,10) PRIMARY KEY,
    student_id INT NOT NULL REFERENCES Student(student_id), 
    exam_id INT NOT NULL REFERENCES Exam(exam_id),
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2 NULL,
    total_score DECIMAL(5,2) NULL,
    status VARCHAR(20) NOT NULL, --e.g Started, Submitted, Graded

    CONSTRAINT CHK_Attempt_Time CHECK (end_time IS NULL OR end_time >= start_time)
) ON FG_Results;

--19. STUDENT_ANSWERS >FG_Results
CREATE TABLE Student_Answers (
    attempt_id BIGINT NOT NULL REFERENCES Student_Exam_Attempt(attempt_id),
    question_id INT NOT NULL REFERENCES Question_Pool(question_id), 
    selected_option_id SMALLINT NULL, --Multiple choice Answer
    answer_text NVARCHAR(MAX) NULL, --written Answer
    awarded_marks DECIMAL(4,2) NULL,

    PRIMARY KEY (attempt_id, question_id)
) ON FG_Results;
