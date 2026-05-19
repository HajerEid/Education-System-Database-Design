USE ExamSystemDB;
GO
----------------------------------------------------------
-- 1. create loges to enter server (Server Logins)
-- allow connect server 
CREATE LOGIN [sql_manager] 
WITH PASSWORD = 'ManagerPass123!', CHECK_POLICY = OFF;

CREATE LOGIN [sql_instructor] 
WITH PASSWORD = 'InstructorPass123!', CHECK_POLICY = OFF;

CREATE LOGIN [sql_student] 
WITH PASSWORD = 'StudentPass123!', CHECK_POLICY = OFF;

-- 2. link login with >(Database Users)
CREATE USER [db_manager] FOR LOGIN [sql_manager];
CREATE USER [db_instructor] FOR LOGIN [sql_instructor];
CREATE USER [db_student] FOR LOGIN [sql_student];

--3. grant main access for user on schema (dbo)
-- These permissions grant basic read/write access. 
-- Role-based management access is controlled by the application logic via the 'Roles' table. 
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO [db_manager];
GRANT SELECT, INSERT, UPDATE ON SCHEMA::dbo TO [db_instructor];
GRANT SELECT, INSERT ON SCHEMA::dbo TO [db_student];