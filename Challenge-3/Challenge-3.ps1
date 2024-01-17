############################################
## Step 1: Set Variables and Prerequistes ##
############################################
Install-Module -Name SqlServer
Import-Module SqlServer

$sqlInstance = "localhost"
$username = "sa"
$password = "Pass@word1"

######################################
## Step 2: Backing Up SQL Databases ##
######################################

# Set Database Name
$databaseName = "AdventureWorks2022"
$path = "C:\PowerShell\Database"

# Backup the Complete Database
$backupPath = "$path\AdventureWorks2022.bak"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName

# Backup the Complete Database to the Specific Path
$backupPath = "$path\AdventureWorks2022.bak"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath

# Backup a Database based on Location
Set-Location "SQLSERVER:\SQL\$sqlInstance\DEFAULT\Databases\$databaseName"
Backup-SqlDatabase -Database $databaseName

# Set Database Logging to Full
$Query = "ALTER DATABASE [$databaseName] SET RECOVERY FULL;"
Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $Query -Username $username -Password $password -TrustServerCertificate:$true

# Do a Full Backup
$backupPath = "$path\AdventureWorks2022.bak"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -BackupAction Database

# Backup the Transaction Log
$backupPath = "$path\AdventureWorks2022.trn"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -BackupAction Log

# Set Database Logging to Simple
$Query = "ALTER DATABASE [$databaseName] SET RECOVERY SIMPLE;"
Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $Query -Username $username -Password $password -TrustServerCertificate:$true

# Create a Differential Backup
$backupPath = "$path\AdventureWorks2022.dif"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -BackupAction Database -Incremental

# Create a Compressed Backup
$backupPath = "$path\AdventureWorks2022.cmp"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -CompressionOption On

# Create an Encrypted Backup
$backupPath = "$path\AdventureWorks2022.enc"
$EncryptionOption = New-SqlBackupEncryptionOption -Algorithm Aes256 -EncryptorType ServerCertificate -EncryptorName "BackupCert"
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -EncryptionOption $EncryptionOption



#####################################
## Step 3: Restoring SQL Databases ##
#####################################
$databaseName = "AdventureWorks2022"
$path = "C:\PowerShell\Database" 

# Restore Database
$backupFile = "$path\AdventureWorks2022.bak"
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupFile

# Restore a Database Transaction Log
$backupFile = "$path\AdventureWorks2022.trn"
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupFile -RestoreAction Log

# Restore a Database with Replace
$backupFile = "$path\AdventureWorks2022.bak"
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupFile -ReplaceDatabase

# Restore a Database with No Recovery
$backupFile = "$path\AdventureWorks2022.bak"
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupFile -NoRecovery

# Restore and Create a New Database
$backupFile = "$path\AdventureWorks2022.bak"
$sqlFilePath = "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA"
$newDatabaseName = "AdventureWorks2023"
$mdfPath = "$sqlFilePath\AdventureWorks2023.mdf"
$ldfPath = "$sqlFilePath\AdventureWorks2023_log.ldf"

$data = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$($databaseName)", "$mdfPath")
$log = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$($databaseName)_Log", "$ldfPath")
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $newDatabaseName -BackupFile "$backupFile" -RelocateFile @($data,$log)



#########################
## Step 4: Add Logging ##
#########################
# Function for Backing Up a Database and Providing Logging
function Backup-Database {
    param (
        [Parameter(Mandatory=$true)]
        [string]$sqlInstance,
        [Parameter(Mandatory=$true)]
        [string]$databaseName,
        [Parameter(Mandatory=$true)]
        [string]$backupPath
    )
    $success = $true

    Write-Host "Setting database recovery mode to FULL..."
    $Query = "ALTER DATABASE [$databaseName] SET RECOVERY FULL;"
    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $Query -Username $username -Password $password -TrustServerCertificate:$true
    if ($?) {
        Write-Host "Database recovery mode set to FULL successfully."
    } else {
        Write-Host "Failed to set database recovery mode to FULL."
        $success = $false
    }

    Write-Host "Backing up the database..."
    Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -BackupAction Database
    if ($?) {
        Write-Host "Database backup completed successfully."
    } else {
        Write-Host "Failed to backup the database."
        $success = $false
    }

    Write-Host "Setting database recovery mode to SIMPLE..."
    $Query = "ALTER DATABASE [$databaseName] SET RECOVERY SIMPLE;"
    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $Query -Username $username -Password $password -TrustServerCertificate:$true
    if ($?) {
        Write-Host "Database recovery mode set to SIMPLE successfully."
    } else {
        Write-Host "Failed to set database recovery mode to SIMPLE."
        $success = $false
    }

    return $success
}

# Execute the Function
$databaseName = "AdventureWorks2022"
$path = "C:\PowerShell\Database"
$backupPath = "$path\AdventureWorks2022-F.bak"
Backup-Database -sqlInstance $sqlInstance -databaseName $databaseName -backupPath $backupPath


# Function for Restoring a Database and Providing Logging
function Restore-Database {
    param (
        [Parameter(Mandatory=$true)]
        [string]$sqlInstance,
        [Parameter(Mandatory=$true)]
        [string]$databaseName,
        [Parameter(Mandatory=$true)]
        [string]$backupPath
    )
    $success = $true

    Write-Host "Restoring the database..."
    Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath
    if ($?) {
        Write-Host "Database restore completed successfully."
    } else {
        Write-Host "Failed to restore the database."
        $success = $false
    }

    return $success
}

# Execute the Function
$databaseName = "AdventureWorks2022"
$path = "C:\PowerShell\Database"
$backupPath = "$path\AdventureWorks2022-F.bak"
Restore-Database -sqlInstance $sqlInstance -databaseName $databaseName -backupPath $backupPath


# Function for Restoring a Database as a New Database and Providing Logging
function Restore-DatabaseAsNew {
    param (
        [Parameter(Mandatory=$true)]
        [string]$sqlInstance,
        [Parameter(Mandatory=$true)]
        [string]$databaseName,
        [Parameter(Mandatory=$true)]
        [string]$backupPath,
        [Parameter(Mandatory=$true)]
        [string]$newDatabaseName
    )
    $success = $true

    Write-Host "Restoring the database..."
    $sqlFilePath = "C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA"
    $mdfPath = "$sqlFilePath\$newDatabaseName.mdf"
    $ldfPath = "$sqlFilePath\$newDatabaseName_log.ldf"
    $data = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$($databaseName)", "$mdfPath")
    $log = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("$($databaseName)_Log", "$ldfPath")
    Restore-SqlDatabase -ServerInstance $sqlInstance -Database $newDatabaseName -BackupFile "$backupPath" -RelocateFile @($data,$log)
    if ($?) {
        Write-Host "Database restore completed successfully."
    } else {
        Write-Host "Failed to restore the database."
        $success = $false
    }

    return $success
}

# Execute the Function
$databaseName = "AdventureWorks2022"
$path = "C:\PowerShell\Database"
$backupPath = "$path\AdventureWorks2022-F.bak"
$newDatabaseName = "AdventureWorks2023"
Restore-DatabaseAsNew -sqlInstance $sqlInstance -databaseName $databaseName -backupPath $backupPath -newDatabaseName $newDatabaseName


# Function to Backup ALL Databases and Provide a CSV Report of the Backup
function Backup-AllDatabases {
    param (
        [Parameter(Mandatory=$true)]
        [string]$sqlInstance,
        [Parameter(Mandatory=$true)]
        [string]$backupPath
    )
    $success = $true
    $output = @()

    Write-Host "Setting database recovery mode to FULL..."
    $Query = "ALTER DATABASE [$databaseName] SET RECOVERY FULL;"
    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $Query -Username $username -Password $password -TrustServerCertificate:$true
    if ($?) {
        Write-Host "Database recovery mode set to FULL successfully."
        $output += [PSCustomObject]@{
            Step = "Set Recovery Mode to FULL"
            Status = "Success"
        }
    } else {
        Write-Host "Failed to set database recovery mode to FULL."
        $success = $false
        $output += [PSCustomObject]@{
            Step = "Set Recovery Mode to FULL"
            Status = "Failure"
        }
    }

    Write-Host "Backing up the database..."
    Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -BackupAction Database
    if ($?) {
        Write-Host "Database backup completed successfully."
        $output += [PSCustomObject]@{
            Step = "Database Backup"
            Status = "Success"
        }
    } else {
        Write-Host "Failed to backup the database."
        $success = $false
        $output += [PSCustomObject]@{
            Step = "Database Backup"
            Status = "Failure"
        }
    }

    Write-Host "Setting database recovery mode to SIMPLE..."
    $Query = "ALTER DATABASE [$databaseName] SET RECOVERY SIMPLE;"
    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $Query -Username $username -Password $password -TrustServerCertificate:$true
    if ($?) {
        Write-Host "Database recovery mode set to SIMPLE successfully."
        $output += [PSCustomObject]@{
            Step = "Set Recovery Mode to SIMPLE"
            Status = "Success"
        }
    } else {
        Write-Host "Failed to set database recovery mode to SIMPLE."
        $success = $false
        $output += [PSCustomObject]@{
            Step = "Set Recovery Mode to SIMPLE"
            Status = "Failure"
        }
    }

    $output | Export-Csv -Path "C:\PowerShell\Database\BackupReport.csv" -NoTypeInformation

    return $success
}

# Execute the Function
$path = "C:\PowerShell\Database"
$backupPath = "$path\AdventureWorks2022-F.bak"
Backup-AllDatabases -sqlInstance $sqlInstance -backupPath $backupPath






