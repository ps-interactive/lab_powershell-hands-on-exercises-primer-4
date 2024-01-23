# Shutdown SQL Server
Stop-Service -Name 'MSSQL$SQLEXPRESS'

# Launch a Seperate PowerShell Windows and execute the following commands
$sqlServerExePath = "C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Binn\sqlservr.exe"
$arguments = "-m -s SQLEXPRESS"
Start-Process -FilePath $sqlServerExePath -ArgumentList $arguments

# Add pslearner to SysAdmin Role, then Stop SQL Server
$cmd = 'sqlcmd -S .\SQLEXPRESS -Q "EXEC sp_addsrvrolemember ''ps-win-1\pslearner'', ''sysadmin'';"'
Invoke-Expression $cmd

# Stop the single mode SQL Server
Stop-Process -Name sqlservr -Force

# Start SQL Server
Start-Service -Name 'MSSQL$SQLEXPRESS'
