############################################
## Step 1: Set Variables and Prerequistes ##
############################################

# Variables
$path = "C:\Users\Public\Desktop\LAB_FILES\Challenge-7\"
$csv = $path + "Challenge-7.csv"
$output = "C:\PowerShell\Logs\FirewallRulesReport.txt"


####################################################
## Step 2: Basic NetFirewallRule Command Examples ##
####################################################

# Retrieve all existing firewall rules
Get-NetFirewallRule

# Retrieve all firewall rules and display selected properties in a table format
Get-NetFirewallRule | 
    Select-Object -Property Name, DisplayName, Enabled, Direction, Action |
    Format-Table -AutoSize

# Add a new firewall rule allowing inbound TCP traffic on port 80
New-NetFirewallRule -DisplayName "Allow HTTP Inbound" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow

# Disable an existing firewall rule by DisplayName
Set-NetFirewallRule -DisplayName "Allow HTTP Inbound" -Enabled False

# Remove a firewall rule by DisplayName
Remove-NetFirewallRule -DisplayName "Allow HTTP Inbound"


#######################################################
## Step 3: Script to Process Firewall Rules from CSV ##
#######################################################
function Import-FirewallRulesFromCSV {
    param(
        [Parameter(Mandatory)]
        [string]$CsvFilePath
    )

    $firewallRules = Import-Csv -Path $CsvFilePath

    foreach ($rule in $firewallRules) {
        $existingRule = Get-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue

        if ($null -eq $existingRule) {
            # Add new rule
            New-NetFirewallRule -DisplayName $rule.DisplayName -Direction $rule.Direction -Protocol $rule.Protocol -LocalPort $rule.LocalPort -Action $rule.Action
        } else {
            # Modify existing rule
            Set-NetFirewallRule -DisplayName $rule.DisplayName -Direction $rule.Direction -Protocol $rule.Protocol -LocalPort $rule.LocalPort -Action $rule.Action
        }
    }
}

Import-FirewallRulesFromCSV -CsvFilePath $csv


###########################################
## Step 4: Check the Created Rules ##
###########################################
# Get all firewall rules where the name starts with 'PWSH'
$rules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "PWSH*" }
$rules | Select-Object DisplayName

# Delete the retrieved rules
$rules | Remove-NetFirewallRule


##############################################
## Step 5: Export all Firewall Rules to CSV ##
##############################################
function Export-FirewallRulesToCSV {
    param(
        [Parameter(Mandatory)]
        [string]$CsvFilePath
    )

    $rules = Get-NetFirewallRule

    $rules | Export-Csv -Path $CsvFilePath -NoTypeInformation
}

Export-FirewallRulesToCSV -CsvFilePath $output


