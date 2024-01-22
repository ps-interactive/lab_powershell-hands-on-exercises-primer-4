############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$path = "C:\PowerShell\Files"
$output = "C:\PowerShell\Logs\Output.log"

###########################################
## Step 2: Implement a Basic FileWatcher ##
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
Get-EventSubscriber | Unregister-Event



########################################################
## Step 3: FileWatcher for File and Directory Changes ##
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
Get-EventSubscriber | Unregister-Event



#####################################################################
## Step 4: FileWatcher for File and Directory Changes with Message ##
#####################################################################

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

    # Write to the console
    Write-Host "File Changed: $fullPath"
    
}

# Register the event with the action script block
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action

# Start the watcher
$watcher.EnableRaisingEvents = $true

# To stop monitoring, you would run:
Get-EventSubscriber | Unregister-Event