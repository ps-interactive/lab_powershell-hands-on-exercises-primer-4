############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$path = "C:\Users\Public\Desktop\LAB_FILES\"
$now = Get-Date
$before = $now.AddMinutes(-1)
$output = $path + "Output.log"

##########################################
## Step 2: Check for Basic File Changes ##
##########################################

# Check Directory for Changes
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.LastWriteTime -gt $before -and $_.CreationTime -le $before } | ForEach-Object {
    Write-Host "File: $($_.FullName) has been created, modified, or deleted" -ForegroundColor Green
}

# Check for Opened Files
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.LastAccessTime -gt $before } | ForEach-Object {
    Write-Host "File: $($_.FullName) has been opened" -ForegroundColor Green
}

# Check for Closed Files
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.LastAccessTime -gt $before } | ForEach-Object {
    Write-Host "File: $($_.FullName) has been closed" -ForegroundColor Green
}


###########################################
## Step 3: Implement a Basic FileWatcher ##
###########################################

# Create a new FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $path
$watcher.Filter = "*.txt"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'

$action = {
    param($source, $e)

    $changeType = $e.ChangeType
    $fullPath = $e.FullPath
    $logline = "$(Get-Date), $changeType, $fullPath"
    Add-Content -Path $output -Value $logline
}

# Register the event with the action script block
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action

# Start the watcher
$watcher.EnableRaisingEvents = $true

# To stop monitoring, you would run:
Unregister-Event -SubscriptionId (Get-EventSubscriber -EventName Changed).SubscriptionId



########################################################
## Step 4: FileWatcher for File and Directory Changes ##
########################################################

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $path
$watcher.Filter = "*.*"
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite'

$action = {
    param($source, $e)

    $changeType = $e.ChangeType
    $fullPath = $e.FullPath
    $logline = "$(Get-Date), $changeType, $fullPath"
    Add-Content -Path $output -Value $logline
}

# Register the event with the action script block
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action

# Start the watcher
$watcher.EnableRaisingEvents = $true

# To stop monitoring, you would run:
Unregister-Event -SubscriptionId (Get-EventSubscriber -EventName Changed).SubscriptionId



##################################
## Step 5: FileWatcher Function ##
##################################

# FileWatcher Function
function FileWatcher {
    # Create a FileWatcher
    $watcher = New-Object System.IO.FileSystemWatcher

    # Set the Path
    $watcher.Path = $path

    # Set the Filter
    $watcher.Filter = "*.*"

    # Set the Notify Filters
    $watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, LastAccess, DirectoryName'

    # Set the Event Handler
    $watcher.add_Changed({
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType
        $logline = "$(Get-Date), $changeType, $path"
        Add-Content $output -Value $logline
    })

    # Start the Watcher
    $watcher.EnableRaisingEvents = $true
}

# Call the Function
FileWatcher


#############################################################################
## Step 6: Create a Function that uses FileWatcher and Registers the Event ##
#############################################################################

function Watch-FileSystem {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PathToMonitor,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$LogFilePath,
        [string]$AdministratorEmail
    )

    $fileWatcher = New-Object System.IO.FileSystemWatcher
    $fileWatcher.Path = $PathToMonitor
    $fileWatcher.IncludeSubdirectories = $true
    $fileWatcher.EnableRaisingEvents = $true
    $fileWatcher.NotifyFilter = 'FileName, LastWrite, LastAccess, DirectoryName'

    $onChange = {
        param($changeType, $path)

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        $logEntry = "$timestamp - [$changeType] $path"
        Add-Content -Path $LogFilePath -Value $logEntry

        if ($AdministratorEmail) {
            Write-Host "Notification sent to $($AdministratorEmail): $logEntry"
            # Send-MailMessage -To $AdministratorEmail -Subject "File System Change Detected" -Body $logEntry -SmtpServer "YourSMTPServer" -From "YourFromAddress"
        }
    }

    Register-ObjectEvent -InputObject $fileWatcher -EventName Created -SourceIdentifier FileCreated -Action {
        $onChange.Invoke('Created', $Event.SourceEventArgs.FullPath)
    }
    Register-ObjectEvent -InputObject $fileWatcher -EventName Deleted -SourceIdentifier FileDeleted -Action {
        $onChange.Invoke('Deleted', $Event.SourceEventArgs.FullPath)
    }
    Register-ObjectEvent -InputObject $fileWatcher -EventName Changed -SourceIdentifier FileChanged -Action {
        $onChange.Invoke('Changed', $Event.SourceEventArgs.FullPath)
    }
    Register-ObjectEvent -InputObject $fileWatcher -EventName Renamed -SourceIdentifier FileRenamed -Action {
        $onChange.Invoke('Renamed', $Event.SourceEventArgs.FullPath)
    }

    $fileWatcher
    Get-EventSubscriber -SourceIdentifier FileCreated
    Get-EventSubscriber -SourceIdentifier FileDeleted
    Get-EventSubscriber -SourceIdentifier FileChanged
    Get-EventSubscriber -SourceIdentifier FileRenamed
}

# Unregister the events
function Stop-WatchingFileSystem {
    # Unregister events
    Unregister-Event -SourceIdentifier FileCreated
    Unregister-Event -SourceIdentifier FileDeleted
    Unregister-Event -SourceIdentifier FileChanged
    Unregister-Event -SourceIdentifier FileRenamed

    # Dispose the FileSystemWatcher
    $Global:fileWatcher.Dispose()

    Write-Host "File system watching stopped."
}

# Call the Function
Watch-FileSystem -PathToMonitor $path -LogFilePath $output -AdministratorEmail

# Stop the Function
Stop-WatchingFileSystem










        


