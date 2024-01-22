############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$TaskList = @('Task1', 'Task2', 'Task3', 'Task4')
$MaxThreads = [Environment]::ProcessorCount


##################################################
## Step 2: Creating and Using a Single Runspace ##
##################################################

# Create a new runspace
$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()

# Create a PowerShell instance and add a script
$powerShell = [powershell]::Create()
$powerShell.Runspace = $runspace
$powerShell.AddScript({
    # Simulate a simple task
    Start-Sleep -Seconds 2
    "Task completed"
})

# Begin the invocation asynchronously
$asyncResult = $powerShell.BeginInvoke()

# End the invocation and get the results
$result = $powerShell.EndInvoke($asyncResult)
Write-Output $result

# Clean up
$powerShell.Dispose()
$runspace.Close()
$runspace.Dispose()


##################################
## Step 3: Using a RunspacePool ##
##################################
# Create a RunspacePool
$runspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
$runspacePool.Open()

# Example of using the RunspacePool with one task
$powerShell = [powershell]::Create()
$powerShell.RunspacePool = $runspacePool
$powerShell.AddScript({
    # Simulate a task
    Start-Sleep -Seconds 2
    "Task in RunspacePool completed"
})

# Begin and end the invocation as before
$asyncResult = $powerShell.BeginInvoke()
$result = $powerShell.EndInvoke($asyncResult)
Write-Output $result

# Clean up
$powerShell.Dispose()
$runspacePool.Close()
$runspacePool.Dispose()


#############################################################
## Step 4: Create a Basic Multi-threaded PowerShell Script ##
#############################################################
function Start-ParallelTasks {
    param(
        [Parameter(Mandatory)]
        [string[]]$TaskList
    )

    $runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
    $runspacePool.Open()

    $powershellInstances = foreach ($task in $TaskList) {
        $powershell = [powershell]::Create().AddScript({
            param($task)
            # Simulate a task (Replace this with your actual task)
            Start-Sleep -Seconds 2
            "Completed task: $task"
        }).AddArgument($task)

        $powershell.RunspacePool = $runspacePool
        [PSCustomObject]@{
            Pipeline = $powershell.BeginInvoke()
            Powershell = $powershell
        }
    }

    foreach ($instance in $powershellInstances) {
        $result = $instance.Powershell.EndInvoke($instance.Pipeline)
        $instance.Powershell.Dispose()
        Write-Output $result
    }

    $runspacePool.Close()
    $runspacePool.Dispose()
}

Start-ParallelTasks -TaskList $TaskList


######################################
## Step 5: Implement Error Handling ##
######################################
function Start-ParallelTasks {
    param(
        [Parameter(Mandatory)]
        [string[]]$TaskList
    )

    $runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
    $runspacePool.Open()

    $powershellInstances = foreach ($task in $TaskList) {
        $powershell = [powershell]::Create().AddScript({
            param($task)
            try {
                # Simulate a task
                Start-Sleep -Seconds 2
                if ($task -eq 'Error') {
                    throw 'Simulated error'
                }
                "Completed task: $task"
            } catch {
                "Error in task ${$task}: $_"
            }
        }).AddArgument($task)

        $powershell.RunspacePool = $runspacePool
        [PSCustomObject]@{
            Pipeline = $powershell.BeginInvoke()
            Powershell = $powershell
        }
    }

    foreach ($instance in $powershellInstances) {
        $result = $instance.Powershell.EndInvoke($instance.Pipeline)
        $instance.Powershell.Dispose()
        Write-Output $result
    }

    $runspacePool.Close()
    $runspacePool.Dispose()
}


# Execute the function but simulate an error
$TaskList = @('Task1', 'Task2', 'Error', 'Task4')
Start-ParallelTasks -TaskList $TaskList


##################################
## Step 6: Use Real-world Tasks ##
##################################
function Start-ParallelTasks {
    param(
        [Parameter(Mandatory)]
        [string[]]$TaskList
    )

    $runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
    $runspacePool.Open()

    $powershellInstances = foreach ($task in $TaskList) {
        $powershell = [powershell]::Create().AddScript({
            param($task)
            try {
                # Execute the actual PowerShell command
                $output = Invoke-Expression $task
                "Completed task: $task. Output: $output"
            } catch {
                "Error in task: $task. Error: $_"
            }
        }).AddArgument($task)

        $powershell.RunspacePool = $runspacePool
        [PSCustomObject]@{
            Pipeline = $powershell.BeginInvoke()
            Powershell = $powershell
        }
    }

    foreach ($instance in $powershellInstances) {
        $result = $instance.Powershell.EndInvoke($instance.Pipeline)
        $instance.Powershell.Dispose()
        Write-Output $result
    }

    $runspacePool.Close()
    $runspacePool.Dispose()
}

# Example usage

$TaskList = @(
    'Get-NetAdapter | Select-Object Name, Status',
    'Get-Service -Name wuauserv | Select-Object Name, Status',
    'Get-Date',
    'NonExistent-Command'
)
Start-ParallelTasks -TaskList $TaskList



