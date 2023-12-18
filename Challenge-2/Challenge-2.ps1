##############################
## Step 1: Define Variables ##
##############################

# Define the variables
$interfaceToCapture = "Ethernet"
$localPath = "C:\\PowerShell\Network"



#################################################################
## Step 2: Using the "NetEventPacketCapture" PowerSHell Module ##
#################################################################

# Import the module
Import-Module NetEventPacketCapture

# Define the parameters for the New-NetEventSession cmdlet
$sessionName = "NetEventPacketCaptureSession"
$localFilePath = "$localPath\NetEventPacketCapture.etl"

# Create a new packet capture session
New-NetEventSession -Name $sessionName -LocalFilePath $localFilePath

# Add a packet capture provider to the session
Add-NetEventProvider -Name Microsoft-Windows-TCPIP -SessionName $sessionName

# Start the packet capture session
Start-NetEventSession -Name $sessionName

# Wait for some time (e.g., 10 seconds)
Start-Sleep -Seconds 10

# Stop the packet capture session
Stop-NetEventSession -Name $sessionName

# Remove the packet capture session
Remove-NetEventSession -Name $sessionName

# Display the captured packets
netsh trace convert $localFilePath


# Modify the variables to retrieve the txt file, and set the IP address
$localFilePath = "$localPath\NetEventPacketCapture.etl"
$localFilePath = $localFilePath.Replace(".etl", ".txt")
$ip = "10.211.55.3"

# Display the captured packets by filtering for the IP address
Get-Content $localFilePath | Where-Object { $_ -match "local=$ip" }

# Display the remote IP and port for the packets
Get-Content $localFilePath | Select-String -Pattern "remote=(.*?):(\d+)" -AllMatches | ForEach-Object {
    $_.Matches | ForEach-Object {
        $remoteIP = $_.Groups[1].Value
        $remotePort = $_.Groups[2].Value
        "Remote IP: $remoteIP, Remote Port: $remotePort"
    }
}



#################################################
## Step 3: Using the Wireshark from PowerSHell ##
#################################################

# Define a function to capture network traffic
function Invoke-NetworkCapture {
    param (
        [string]$Interface = "Ethernet",
        [string]$CaptureFilter = "",
        [int]$Duration = 30
    )

    # Define the output file
    $outputFile = "$localPath\capture.pcap"

    # Build the command to capture network traffic
    $tsharkCommand = "tshark -i $Interface -a duration:$Duration -w $outputFile"
    if ($CaptureFilter -ne "") {
        $tsharkCommand += " -f `"$CaptureFilter`""
    }

    # Execute the command
    Invoke-Expression $tsharkCommand

    # Return the path to the output file
    return $outputFile
}

# Function to analyze captured traffic
function Invoke-NetworkAnalysis {
    param (
        [string]$CaptureFile
    )

    # Run analysis with tshark
    # For the purpose of this example, we'll just count the packets
    $analysisCommand = "tshark -r $CaptureFile | Measure-Object | Select-Object -ExpandProperty Count"
    $packetCount = Invoke-Expression $analysisCommand

    Write-Host "Total number of packets: $packetCount"

    # Here you could add more analysis logic, such as filtering for specific protocols, IPs, etc.
}

# Main logic of the script
$interfaceToCapture = "Ethernet"
$filter = "tcp"
$duration = 60 # capture for 60 seconds

# Start capturing network traffic
Write-Host "Capturing network traffic on $interfaceToCapture..."
$captureFile = Invoke-NetworkCapture -Interface $interfaceToCapture -CaptureFilter $filter -Duration $duration

# Analyze the captured network traffic
Write-Host "Analyzing captured network traffic..."
Invoke-NetworkAnalysis -CaptureFile $captureFile

Write-Host "Network traffic capture and analysis complete."



###########################################
## Step 4: Using "netsh" from PowerSHell ##
###########################################

# Define a function to start network trace
function Start-NetworkTrace {
    param (
        [string]$CaptureFileName = "network_trace.etl"
    )

    # Start the trace
    netsh trace start capture=yes tracefile=$CaptureFileName
    Write-Host "Network trace started."
}

# Define a function to stop network trace
function Stop-NetworkTrace {
    # Stop the trace
    netsh trace stop
    Write-Host "Network trace stopped."
}

# Define a function to analyze the network trace
function Invoke-NetworkTrace {
    param (
        [string]$CaptureFileName
    )

    # For the purpose of this example, we will just list the trace file
    # More complex analysis might require additional tools or scripts
    Write-Host "Network trace file saved to: $CaptureFileName"
    
    # Here you could potentially convert the ETL to a readable format
    # and then perform analysis using PowerShell
}

# Main logic of the script
$traceFileName = "$localPath\NetshTrace.etl"

# Start capturing network traffic
Start-NetworkTrace -CaptureFileName $traceFileName

# Here, we sleep for 30 seconds simulating capture duration
# In a real scenario, you would likely have more complex logic to determine when to stop the capture
Start-Sleep -Seconds 30

# Stop capturing network traffic
Stop-NetworkTrace

# Analyze the captured network trace
Invoke-NetworkTrace -CaptureFileName $traceFileName

Write-Host "Network traffic capture and analysis complete."



