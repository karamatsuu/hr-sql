/*=====================================================================
  HR — Employee skills & certification system (Microsoft SQL Server / T-SQL)

  Creates the HR database and the EMPLOYEE, SKILL and CERTIFIED tables
  with the required keys and constraints:
    - SKILL.Skill_ID is IDENTITY(100, 10)  -> 100, 110, 120, ...
    - Foreign keys from CERTIFIED to EMPLOYEE and SKILL
    - CHECK: CERTIFIED.Skill_ID must be between 100 and 220
    - DEFAULT 'Unknown' on EMPLOYEE.Employee_Title

  The script is RE-RUNNABLE: running it on an empty server, or again on a
  server where it has already run, completes without errors.
=====================================================================*/

-------------------------------------------------------------------------------
-- 1. Database (create only if it does not already exist)
-------------------------------------------------------------------------------
USE master;
GO

IF DB_ID('HR') IS NULL
    CREATE DATABASE HR;
GO

USE HR;
GO

-------------------------------------------------------------------------------
-- 2. Drop existing tables in dependency order (child first) so the script
--    can be re-run cleanly. Dropping SKILL also reseeds its IDENTITY to 100.
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS CERTIFIED;
DROP TABLE IF EXISTS SKILL;
DROP TABLE IF EXISTS EMPLOYEE;
GO

-------------------------------------------------------------------------------
-- 3. Tables
-------------------------------------------------------------------------------
-- Employee_ID is stored as CHAR(5) to preserve the leading zeros (e.g. '02345').
CREATE TABLE EMPLOYEE (
    Employee_ID       CHAR(5)      NOT NULL,
    Employee_FName    VARCHAR(50)  NOT NULL,
    Employee_LName    VARCHAR(50)  NOT NULL,
    Employee_HireDate DATE         NULL,
    Employee_Title    VARCHAR(50)  NOT NULL
        CONSTRAINT DF_EMPLOYEE_Title DEFAULT ('Unknown'),
    CONSTRAINT PK_EMPLOYEE PRIMARY KEY (Employee_ID)
);
GO

-- Skill_ID starts at 100 and increases by 10 for each new skill.
CREATE TABLE SKILL (
    Skill_ID          INT           NOT NULL IDENTITY(100, 10),
    Skill_Name        VARCHAR(100)  NOT NULL,
    Skill_Description VARCHAR(255)  NULL,
    CONSTRAINT PK_SKILL PRIMARY KEY (Skill_ID)
);
GO

-- CERTIFIED links employees to the skills they are certified in.
CREATE TABLE CERTIFIED (
    Employee_ID    CHAR(5) NOT NULL,
    Skill_ID       INT     NOT NULL,
    Certified_Date DATE    NULL,
    CONSTRAINT PK_CERTIFIED PRIMARY KEY (Employee_ID, Skill_ID),
    CONSTRAINT FK_CERTIFIED_EMPLOYEE
        FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEE (Employee_ID),
    CONSTRAINT FK_CERTIFIED_SKILL
        FOREIGN KEY (Skill_ID)    REFERENCES SKILL (Skill_ID),
    CONSTRAINT CK_CERTIFIED_Skill_ID
        CHECK (Skill_ID BETWEEN 100 AND 220)
);
GO

-------------------------------------------------------------------------------
-- 4. Sample data (matches the reference tables)
-------------------------------------------------------------------------------
INSERT INTO EMPLOYEE (Employee_ID, Employee_FName, Employee_LName, Employee_HireDate, Employee_Title) VALUES
    ('02345', 'Johnny',   'Jones',      '1999-02-14', 'DBA'),
    ('03373', 'Franklin', 'Johnson',    '2002-03-15', 'Purchasing Agent'),
    ('01893', 'Patricia', 'Richards',   '2004-06-11', 'DBA'),
    ('06234', 'Jasmine',  'Patel',      '2005-08-10', 'Programmer'),
    ('08273', 'Marco',    'Bienz',      '2006-07-28', 'Analyst'),
    ('09002', 'Ben',      'Joiner',     '2010-05-20', 'Clerk'),
    ('09283', 'Juan',     'Chavez',     '2010-07-04', 'Clerk'),
    ('09382', 'Jessica',  'Johnson',    '2010-08-02', 'Database Programmer'),
    ('10282', 'Amanda',   'Richardson', '2011-04-11', 'Clerk'),
    ('13383', 'Raymond',  'Matthews',   '2012-03-12', 'Programmer'),
    ('13557', 'Robert',   'Almond',     '2012-09-30', 'Analyst'),
    ('13932', 'Megan',    'Lee',        '2013-09-29', 'Programmer'),
    ('14311', 'Lee',      'Duong',      '2014-09-01', 'Programmer');
GO

-- Insert in order; IDENTITY assigns 100, 110, 120, ... 220.
INSERT INTO SKILL (Skill_Name, Skill_Description) VALUES
    ('Basic Database Management',    'Create and manage database user accounts.'),
    ('Basic Web Design',             'Create and maintain HTML and CSS documents.'),
    ('Advanced Spreadsheets',        'Use of advanced functions, user-defined functions, and macroing.'),
    ('Basic Process Modeling',       'Create core business process models using standard libraries.'),
    ('Basic Database Design',        'Create simple data models.'),
    ('Master Database Programming',  'Create integrated trigger and procedure packages for a distributed environment.'),
    ('Basic Spreadsheets',           'Create single tab worksheets with basic formulas.'),
    ('Basic C# Programming',         'Create single-tier data aware modules.'),
    ('Advanced Database Management', 'Manage Database Server Clusters.'),
    ('Advance Process Modeling',     'Evaluate and Redesign cross-functional internal and external business processes.'),
    ('Advanced C# Programming',      'Create multi-tier applications using multi-threading.'),
    ('Basic Database Manipulation',  'Create simple data retrieval and manipulation statements in SQL.'),
    ('Advanced Database Manipulation','Use of advanced data manipulation methods for multi-table inserts, set operations, and correlated subqueries.');
GO

INSERT INTO CERTIFIED (Employee_ID, Skill_ID, Certified_Date) VALUES
    ('02345', 100, '2002-02-14'),
    ('02345', 110, '2003-08-09'),
    ('02345', 180, '2006-02-14'),
    ('03373', 120, '2011-06-20'),
    ('01893', 190, '2006-06-11'),
    ('01893', 220, '2012-09-20'),
    ('06234', 110, '2007-08-10'),
    ('06234', 200, '2007-08-10'),
    ('08273', 210, '2012-01-29'),
    ('08273', 110, '2009-03-08'),
    ('09002', 110, '2013-05-16'),
    ('09002', 120, '2013-05-16'),
    ('09382', 140, '2012-08-02'),
    ('09382', 210, '2012-08-02'),
    ('09382', 220, '2013-05-01'),
    ('13383', 170, '2014-03-12'),
    ('13557', 130, '2014-09-30'),
    ('13557', 140, '2015-05-23'),
    ('14311', 110, '2016-09-01');
GO

-------------------------------------------------------------------------------
-- 5. Optional verification (safe: the demo insert is rolled back)
-------------------------------------------------------------------------------
-- (a) DEFAULT 'Unknown' applies when Employee_Title is not supplied:
BEGIN TRANSACTION;
    INSERT INTO EMPLOYEE (Employee_ID, Employee_FName, Employee_LName, Employee_HireDate)
    VALUES ('99999', 'Test', 'User', '2020-01-01');
    SELECT Employee_ID, Employee_Title AS Title_Defaulted
    FROM EMPLOYEE WHERE Employee_ID = '99999';   -- -> 'Unknown'
ROLLBACK TRANSACTION;
GO

-- (b) The CHECK constraint rejects a Skill_ID outside 100..220. Uncomment to test;
--     it intentionally raises an error:
-- INSERT INTO CERTIFIED (Employee_ID, Skill_ID, Certified_Date)
-- VALUES ('02345', 999, '2020-01-01');   -- fails CK_CERTIFIED_Skill_ID
GO

PRINT 'HR database and tables created successfully.';
GO
