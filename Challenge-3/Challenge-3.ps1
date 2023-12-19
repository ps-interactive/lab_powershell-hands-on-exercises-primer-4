############################################
## Step 1: Set Variables and Prerequistes ##
############################################
Install-Module -Name SqlServer
Import-Module SqlServer

$sqlInstance = "localhost"


######################################
## Step 2: Backing Up SQL Databases ##
######################################

# Set Database Name
$databaseName = "AdventureWorks2017"
$backupPath = "C:\temp\AdventureWorks2017.bak"

# Backup Database
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath

# Backup Database with Compression
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -CompressionOption On

# Backup Database with Compression and Checksum
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -CompressionOption On -Checksum

# Backup Database with Compression and Checksum and CopyOnly
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -CompressionOption On -Checksum -CopyOnly

# Backup Database with Compression and Checksum and CopyOnly and Description
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -CompressionOption On -Checksum -CopyOnly -Description "AdventureWorks2017 Backup"

# Backup Database with Compression and Checksum and CopyOnly and Description and Initialize
Backup-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $backupPath -CompressionOption On -Checksum -CopyOnly -Description "AdventureWorks2017 Backup" -Initialize



#####################################
## Step 3: Restoring SQL Databases ##
#####################################
$databaseName = "AdventureWorks2017"
$restorePath = "C:\temp\AdventureWorks2017.bak" 

# Restore Database
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $restorePath -ReplaceDatabase -NoRecovery

# Restore Database with Recovery
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $restorePath -ReplaceDatabase -Recovery

# Restore Database with Recovery and Rename
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $restorePath -ReplaceDatabase -Recovery -DatabaseName "AdventureWorks2017_Restored"

# Restore Database with Recovery and Rename and Move
Restore-SqlDatabase -ServerInstance $sqlInstance -Database $databaseName -BackupFile $restorePath -ReplaceDatabase -Recovery -DatabaseName "AdventureWorks2017_Restored" -RelocateFile "AdventureWorks2017" "C:\temp\AdventureWorks2017_Restored.mdf" -RelocateFile "AdventureWorks2017_log" "C:\temp\AdventureWorks2017_Restored.ldf"




#########################
## Step 4: Add Logging ##
#########################




