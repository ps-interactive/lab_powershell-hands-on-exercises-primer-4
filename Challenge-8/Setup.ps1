# Shutdown SQL Server
Stop-Service -Name 'MSSQL$SQLEXPRESS'

# Launch a Seperate PowerShell Windows and execute the following commands
$sqlServerExePath = "C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Binn\sqlservr.exe"
$arguments = "-m -s SQLEXPRESS"
Start-Process -FilePath $sqlServerExePath -ArgumentList $arguments

# Setup the Database for the API in Challenge 8
$createLoginCommand = "CREATE LOGIN dbconnect WITH PASSWORD = 'Pass@word1';"

$createDatabaseCommand = "CREATE DATABASE Employees;"
$sqlCommands = @"
USE Employees;
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(255),
    Address VARCHAR(255),
    OfficeLocation VARCHAR(255),
    JobTitle VARCHAR(255)
);

CREATE TABLE ContactDetails (
    EmployeeID INT,
    Email VARCHAR(255),
    Phone VARCHAR(20),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE SalaryDetails (
    EmployeeID INT,
    BaseSalary DECIMAL(10, 2),
    Currency VARCHAR(3),
    Bonus DECIMAL(10, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
"@

$createDbCmd = "sqlcmd -S .\SQLEXPRESS -Q `"$createDatabaseCommand`""
$tableCmd = "sqlcmd -S .\SQLEXPRESS -Q `"$sqlCommands`""
Invoke-Expression $createDbCmd
Invoke-Expression $tableCmd

$setupDbUserCommands = @"
USE Employees;CREATE USER dbconnect FOR LOGIN dbconnect;EXEC sp_addrolemember 'db_owner', 'dbconnect';
"@

$createLoginCmd = "sqlcmd -S .\SQLEXPRESS -Q `"$createLoginCommand`""
$setupUserCmd = "sqlcmd -S .\SQLEXPRESS -Q `"$setupDbUserCommands`""
Invoke-Expression $createLoginCmd
Invoke-Expression $setupUserCmd


# Define the SQL INSERT statements
$sqlDataLoad = @"
INSERT INTO Employees (EmployeeID, Name, Address, OfficeLocation, JobTitle) VALUES
(1, 'John Doe', '123 Maple Street, Anytown, AT 12345', 'Headquarters', 'Software Engineer'),
(2, 'Jane Smith', '456 Oak Avenue, Othertown, OT 67890', 'Regional Office', 'Project Manager'),
(3, 'Alice Johnson', '789 Pine Road, Sometown, ST 90123', 'Branch Office', 'Marketing Director'),
(4, 'David Brown', '321 Cedar Blvd, New City, NC 45678', 'Headquarters', 'HR Manager'),
(5, 'Emma Wilson', '987 Elm Street, Oldtown, OT 11223', 'Regional Office', 'Sales Representative'),
(6, 'Michael Clark', '654 Willow Way, Lake City, LC 77889', 'Branch Office', 'IT Specialist'),
(7, 'Sophia Turner', '213 Oak Lane, Hilltown, HT 33445', 'Headquarters', 'Quality Analyst'),
(8, 'Ethan Harris', '568 Maple Avenue, Greentown, GT 55677', 'Regional Office', 'Financial Advisor'),
(9, 'Olivia Martinez', '742 Pine Street, Coast City, CC 12333', 'Branch Office', 'Graphic Designer'),
(10, 'William Anderson', '369 Birch Road, Mountain Town, MT 99876', 'Headquarters', 'Operations Manager');

INSERT INTO ContactDetails (EmployeeID, Email, Phone) VALUES
(1, 'johndoe@example.com', '555-0100'),
(2, 'janesmith@example.com', '555-0200'),
(3, 'alicejohnson@example.com', '555-0300'),
(4, 'davidbrown@example.com', '555-0400'),
(5, 'emmawilson@example.com', '555-0500'),
(6, 'michaelclark@example.com', '555-0600'),
(7, 'sophiaturner@example.com', '555-0700'),
(8, 'ethanharris@example.com', '555-0800'),
(9, 'oliviamartinez@example.com', '555-0900'),
(10, 'williamanderson@example.com', '555-1000');

INSERT INTO SalaryDetails (EmployeeID, BaseSalary, Currency, Bonus) VALUES
(1, 70000, 'USD', 5000),
(2, 80000, 'USD', 6000),
(3, 90000, 'USD', 7000),
(4, 75000, 'USD', 5500),
(5, 65000, 'USD', 4000),
(6, 72000, 'USD', 5200),
(7, 68000, 'USD', 4600),
(8, 83000, 'USD', 6200),
(9, 70000, 'USD', 5000),
(10, 78000, 'USD', 5800);
"@

# Execute the SQL Query
$dataCmd = "sqlcmd -S .\SQLEXPRESS -d Employees -Q `"$sqlDataLoad`""
Invoke-Expression $dataCmd

Stop-Process -Name sqlservr -Force

# Start SQL Server
Start-Service -Name 'MSSQL$SQLEXPRESS'