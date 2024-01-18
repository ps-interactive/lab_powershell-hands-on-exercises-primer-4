############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$path = "C:\Users\Public\Desktop\LAB_FILES\Challenge-9\"
$firewallPath = $path + "Challenge-9.csv"
$output = $path + "FirewallReport.txt"


############################################################
## Step 2: Loading and Parsing Windows Firewall Log Files ##
############################################################

function Import-FirewallLog {
    param(
        [Parameter(Mandatory)]
        [string]$LogFilePath
    )

    $parsedLogData = Import-Csv -Path $LogFilePath -Delimiter ',' -Header 'Date', 'Time', 'Action', 'Protocol', 'SourceIP', 'DestinationIP'

    return $parsedLogData
}

$firewallLog = Import-FirewallLog -LogFilePath $firewallPath
$firewalllog


################################
## Step 3: Analyzing Log Data ##
################################
function Invoke-AnalyzeFirewallLog {
    param(
        [Parameter(Mandatory)]
        [pscustomobject[]]$ParsedLogData
    )

    $connectionSummary = $ParsedLogData | Group-Object Action, Protocol | Sort-Object Count -Descending
    $potentialThreats = $ParsedLogData | Where-Object { $_.Action -eq 'DROP' -and $_.Protocol -eq 'TCP' }

    return @{
        ConnectionSummary = $connectionSummary
        PotentialThreats = $potentialThreats
    }
}

$firewallAnalysis = Invoke-AnalyzeFirewallLog -ParsedLogData $firewallLog
$firewallAnalysis.ConnectionSummary
$firewallAnalysis.PotentialThreats


######################################
## Step 4: Create a Detailed Report ##
######################################
function New-AnalysisReport {
    param(
        [Parameter(Mandatory)]
        [hashtable]$AnalysisResults,
        [Parameter(Mandatory)]
        [string]$ReportFilePath
    )

    $reportContent = "Firewall Analysis Report`n`n"
    $reportContent += "Connection Summary:`n"
    foreach ($item in $AnalysisResults.ConnectionSummary) {
        $reportContent += "$($item.Name): $($item.Count) occurrences`n"
    }

    $reportContent += "`nPotential Security Threats (TCP Drops):`n"
    foreach ($threat in $AnalysisResults.PotentialThreats) {
        $reportContent += "Date: $($threat.Date) Time: $($threat.Time) Source: $($threat.SourceIP) Destination: $($threat.DestinationIP)`n"
    }

    Set-Content -Path $ReportFilePath -Value $reportContent
}

New-AnalysisReport -AnalysisResults $firewallAnalysis -ReportFilePath $output
Get-Content -Path $output




