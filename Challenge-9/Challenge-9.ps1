############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$path = "C:\Users\Public\Desktop\LAB_FILES\Challenge-9\"
$firewallPath = $path + "Challenge-9.csv"
$output = "C:\PowerShell\Logs\FirewallReport.txt"
$htmlOutput = "C:\PowerShell\Logs\FirewallReport.html"


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


##############################################
## Step 5: Create a Detailed Report as HTML ##
##############################################
function New-HtmlAnalysisReport {
    param(
        [Parameter(Mandatory)]
        [hashtable]$AnalysisResults,
        [Parameter(Mandatory)]
        [string]$ReportFilePath
    )
    # Start building HTML content
    $reportContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Firewall Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        h1 { color: #333366; }
        h2 { color: #666699; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #dddddd; text-align: left; padding: 8px; }
        th { background-color: #eeeeee; }
    </style>
</head>
<body>
    <h1>Firewall Analysis Report</h1>
    <h2>Connection Summary</h2>
    <table>
        <tr>
            <th>Name</th>
            <th>Occurrences</th>
        </tr>
"@
    foreach ($item in $AnalysisResults.ConnectionSummary) {
        $reportContent += "<tr><td>$($item.Name)</td><td>$($item.Count)</td></tr>`n"
    }
    $reportContent += @"
    </table>
    <h2>Potential Security Threats (TCP Drops)</h2>
    <table>
        <tr>
            <th>Date</th>
            <th>Time</th>
            <th>Source IP</th>
            <th>Destination IP</th>
        </tr>
"@
    foreach ($threat in $AnalysisResults.PotentialThreats) {
        $reportContent += "<tr><td>$($threat.Date)</td><td>$($threat.Time)</td><td>$($threat.SourceIP)</td><td>$($threat.DestinationIP)</td></tr>`n"
    }
    $reportContent += @"
    </table>
</body>
</html>
"@
    # Save the HTML content to a file
    Set-Content -Path $ReportFilePath -Value $reportContent
}
New-HtmlAnalysisReport -AnalysisResults $firewallAnalysis -ReportFilePath $htmlOutput
Invoke-Item -Path $htmlOutput




