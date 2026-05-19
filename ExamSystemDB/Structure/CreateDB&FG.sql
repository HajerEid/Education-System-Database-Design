CREATE DATABASE ExamSystemDB
ON PRIMARY
( --FIXED table size 
    NAME = ExamDB_Primary,
    FILENAME = 'D:\DB\Data\ExamDB_Primary.mdf',
    SIZE = 100MB,
    MAXSIZE = 500MB, 
    FILEGROWTH = 50MB
),
-- Users: [user , student , instractor , manager ]
FILEGROUP FG_Users DEFAULT
(
    NAME = ExamDB_Users,
    FILENAME = 'D:\DB\Data\ExamDB_Users.ndf',
    SIZE = 200MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 100MB
),
-- Examination [Exam , Question  ]
FILEGROUP FG_Exams 
(
    NAME = ExamDB_Exams,
    FILENAME = 'D:\DB\Data\ExamDB_Exams.ndf',
    SIZE = 1GB,
    MAXSIZE = 5GB,
    FILEGROWTH = 500MB
),
-- structure [Departmint , Branch , Intake ]
FILEGROUP FG_Structure  
(
    NAME = ExamDB_Structure,
    FILENAME = 'D:\DB\Data\ExamDB_Structure.ndf',
    SIZE = 100MB,
    MAXSIZE = 1GB,
    FILEGROWTH = 50MB
),
-- Courses [Course , Track ]
FILEGROUP FG_Courses
(
    NAME = ExamDB_Courses,
    FILENAME = 'D:\DB\Data\ExamDB_Courses.ndf',
    SIZE = 200MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 100MB
),
--Result [Answer]
FILEGROUP FG_Results 
(
    NAME = ExamDB_Results,
    FILENAME = 'D:\DB\Data\ExamDB_Results.ndf',
    SIZE = 2GB,
    MAXSIZE = 8GB,
    FILEGROWTH = 1GB
),
-- Indexes
FILEGROUP FG_Indexes 
(
    NAME = ExamDB_Indexes,
    FILENAME = 'D:\DB\Data\ExamDB_Indexes.ndf',
    SIZE = 1GB,
    MAXSIZE = 5GB,
    FILEGROWTH = 500MB
)
LOG ON 
(
    NAME = ExamDB_Log,
    FILENAME = 'D:\DB\Logs\ExamDB_Log.ldf',
    SIZE = 500MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 10%
);
GO


