############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$path = "C:\Users\Public\Desktop\LAB_FILES\"
$log = $path + "Challenge-5\Challenge-5.log"
$summary = $path + "Challenge-5\SummaryReport.txt"


##############################
## Step 2: Parse a Log File ##
##############################

# Import and Read a Log File and Return the Count
function Import-LogFile {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    $logData = Get-Content -Path $FilePath -ReadCount 1000 | ForEach-Object { $_ -split "`r?`n" }
    return $logData
}

# Execute the Function
$logData = Import-LogFile -FilePath $log


################################
## Step 3: Query the Log File ##
################################

# Analyze Log Data
function Get-MostVisitedPages {
    param(
        [Parameter(Mandatory)]
        [string[]]$LogData
    )

    $pageHits = @{}

    foreach ($line in $LogData) {
        if ($line -match '^(\S+)\s') {
            if ($line -match '"GET\s+(\S+)\s+HTTP\/[0-9.]+"') {
                $page = $matches[1]
                $pageHits[$page] = $pageHits[$page] + 1
            }
        }
    }

    return $pageHits.GetEnumerator() | Sort-Object Value -Descending
}

function Get-HighTrafficIPAddresses {
    param(
        [Parameter(Mandatory)]
        [string[]]$LogData
    )

    $ipHits = @{}

    foreach ($line in $LogData) {
        if ($line -match '^(\S+)\s') {
            $ip = $matches[1]
            $ipHits[$ip] = $ipHits[$ip] + 1
        }
    }

    return $ipHits.GetEnumerator() | Sort-Object Value -Descending
}

# Execute the Function
Get-MostVisitedPages -LogData $logData
Get-HighTrafficIPAddresses -LogData $logData


########################################
## Step 4: Create the Summary Report ##
########################################

# Generate a Summary Report
function New-SummaryReport {
    param(
        [Parameter(Mandatory)]
        [string[]]$LogData,
        [Parameter(Mandatory)]
        [string]$ReportPath
    )

    $mostVisitedPages = Get-MostVisitedPages -LogData $LogData
    $highTrafficIPs = Get-HighTrafficIPAddresses -LogData $LogData

    $reportContent = "Summary Report`n`n"
    $reportContent += "Most Visited Pages:`n"
    foreach ($page in $mostVisitedPages) {
        $reportContent += "$($page.Name): $($page.Value) hits`n"
    }

    $reportContent += "`nHigh Traffic IP Addresses:`n"
    foreach ($ip in $highTrafficIPs) {
        $reportContent += "$($ip.Name): $($ip.Value) requests`n"
    }

    Set-Content -Path $ReportPath -Value $reportContent
}

# Execute the Function
New-SummaryReport -LogData $logData -ReportPath $summary


###################################
## Step 5: Execute All Together ##
###################################

# Import the log file
$logData = Import-LogFile -FilePath $log

# Generate the summary report
$reportPath = $summary
New-SummaryReport -LogData $logData -ReportPath $reportPath

# Display the report
Get-Content -Path $reportPath

