# This script will set up the system to request a password reset on the next boot.
# The new password will be exposed via the EC2 console.
# It will also make the system handle any new userdata passed in.
$EC2LaunchFile="C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Config\\LaunchConfig.json"
$json = get-content $EC2LaunchFile | ConvertFrom-Json
$json.adminPasswordType = "Random"
$json.setComputerName = "false"
$json | ConvertTo-Json | out-file $EC2LaunchFile -Force -encoding utf8
Write-Output "Set EC2 Machine Configuration"
Invoke-Expression 'C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule'
