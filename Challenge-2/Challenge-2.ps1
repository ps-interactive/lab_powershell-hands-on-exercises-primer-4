##############################
## Step 1: Define Variables ##
##############################

# Define the variables
$interfaceToCapture = Get-NetAdapter | Where-Object { $_.InterfaceDescription -notlike "*Loopback*" }
$interfaceToCapture = $interfaceToCapture.ifIndex
$localPath = "C:\PowerShell\Network"
$tsharkPath = "C:\Program Files\Wireshark"


#################################################################
## Step 2: Using the "NetEventPacketCapture" PowerShell Module ##
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

# Convert the captured packets into a text file
netsh trace convert $localFilePath


# Modify the variables to retrieve the txt file, and set the IP address
$localFilePath = "$localPath\NetEventPacketCapture.etl"
$localFilePath = $localFilePath.Replace(".etl", ".txt")
$ip = "172.31.24.20"

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



#############################################
## Step 3: Using Wireshark from PowerShell ##
#############################################

# Define a function to capture network traffic
function Invoke-NetworkCapture {
    param (
        [string]$Interface = "Ethernet",
        [string]$CaptureFilter = "",
        [int]$Duration = 30
    )

    # Define the output file
    $outputFile = "$localPath\capture.pcap"

    $tsharkCommand = & "$tsharkPath\tshark.exe" `-i $Interface `-a duration:$Duration `-w $outputFile `-f "$CaptureFilter"

    # Execute the command
    Invoke-Expression -ScriptBlock $tsharkCommand

    # Return the path to the output file
    return $outputFile
}

# Function to analyze captured traffic
function Invoke-NetworkAnalysis {
    param (
        [string]$CaptureFile
    )

    # Assign the command to the variable as a script block
    $analysisCommand = {
        & "$tsharkPath\tshark.exe" -r $CaptureFile -T fields -e ip.src -e ip.dst -E separator=',' | ConvertFrom-Csv -Header 'Source IP', 'Destination IP' | Format-Table
    }

    # Replace $CaptureFile with the actual path to your .pcap file before running the command
    $captureFile = "$localPath\capture.pcap"

    # Execute the command
    $packetInfo = Invoke-Command -ScriptBlock $analysisCommand

    return $packetInfo
}

# Set the variables
$interfaceToCapture = "Ethernet"
$filter = "tcp"
$duration = 60 # capture for 60 seconds

# Start capturing network traffic
Write-Host "Capturing network traffic on $interfaceToCapture..."
$captureFile = Invoke-NetworkCapture -Interface $interfaceToCapture -CaptureFilter $filter -Duration $duration

# Analyze the captured network traffic
Write-Host "Analyzing captured network traffic..."
Invoke-NetworkAnalysis -CaptureFile $captureFile



###########################################
## Step 4: Using "netsh" from PowerShell ##
###########################################

# Define a function to start network trace
function Start-NetworkTrace {
    param (
        [string]$CaptureFileName
    )

    # Start the trace
    netsh trace start capture=yes tracefile="$localPath\$CaptureFileName"                
    Write-Host "Network trace started."
}

# Define a function to stop network trace
function Stop-NetworkTrace {
    # Stop the trace
    netsh trace stop
    Write-Host "Network trace stopped."
}

# Define a function to analyze the network trace
function Invoke-AnalyzeNetworkTrace {
    param (
        [string]$CaptureFileName,
        [string]$Protocol = ""
    )

    # Convert the trace to pcapng format
    & "$localPath\etl2pcapng.exe" "$localPath\$CaptureFileName" "$localPath\$CaptureFileName.pcapng"

    # CUse WireShark to analyze the trace
    $analysisCommand = {
        & "$tsharkPath\tshark.exe" -r "$localPath\$CaptureFileName.pcapng" -T fields -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport -e tcp.len -E separator=',' -Y $Protocol | ConvertFrom-Csv -Header 'Source IP', 'Source Port', 'Destination IP', 'Destination Port' | Format-Table
    }

    # Execute the command
    $packetInfo = Invoke-Command -ScriptBlock $analysisCommand  

    # Return the packet information
    return $packetInfo
}

# Trace file name
$traceFileName = "NetshTrace.etl"

# Start capturing network traffic
Start-NetworkTrace -CaptureFileName $traceFileName

# Sleep for 60 seconds simulating capture duration
Start-Sleep -Seconds 30

# Stop capturing network traffic
Stop-NetworkTrace

# Analyze the captured network trace
Invoke-AnalyzeNetworkTrace -CaptureFileName $traceFileName -Protocol "tcp"
