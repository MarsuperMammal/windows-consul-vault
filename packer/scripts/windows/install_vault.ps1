write-output "Creating Consul directories"
foreach ($dir in @('log', 'data')) {
  New-Item -Path "C:\opt\vault\$dir" -ItemType Directory -Force
}

write-output "Setting urls"
$vaultUrl = "https://releases.hashicorp.com/vault/0.6.2/vault_0.6.2_windows_amd64.zip"

write-output "Setting file paths"
$nssmFilePath = "$($env:TEMP)\nssm.zip"
$vaultFilePath = "$($env:TEMP)\vault.zip"

write-output "Downloading Vault"
(New-Object System.Net.WebClient).DownloadFile($vaultUrl, $vaultFilePath)

write-output "Creating shell object"
$shell = New-Object -ComObject Shell.Application

write-output "Setting namespaces"
$vaultZip = $shell.NameSpace($vaultFilePath)

write-output "Setting destinations"
$vaultDestination = $shell.NameSpace("C:\opt\vault")

write-output "Setting copy flags"
$copyFlags = 0x00
$copyFlags += 0x04 # Hide progress dialogs
$copyFlags += 0x10 # Overwrite existing files

write-output "Copying Vault"
$vaultDestination.CopyHere($vaultZip.Items(), $copyFlags)

# Clean up
write-output "Cleanup"
Remove-Item -Force -Path $vaultFilePath

# Create the Vault service and set its options
write-output "Creating Vault service"
C:\opt\nssm.exe install vault "C:\opt\vault\vault.exe" server -config "C:\etc\vault.d"
write-output "Setting Vault options"
C:\opt\nssm.exe set vault AppEnvironmentExtra "GOMAXPROCS=%NUMBER_OF_PROCESSORS%"
C:\opt\nssm.exe set vault AppRotateFiles 1
C:\opt\nssm.exe set vault AppRotateOnline 1
C:\opt\nssm.exe set vault AppRotateBytes 10485760
C:\opt\nssm.exe set vault AppStdout C:\opt\vault\log\vault.log
C:\opt\nssm.exe set vault AppStderr C:\opt\vault\log\vault.log

write-output "Stopping Vault service"
Stop-Service vault -EA silentlycontinue
Set-Service vault -StartupType Manual

# Disable negative DNS response caching
write-output "Disable negative DNS response caching"
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters -Name MaxNegativeCacheTtl -Value 0 -Type DWord

# Allow Consul Serf traffic through the firewall
write-output "Set firewall"
netsh advfirewall firewall add rule name="Vault Sever TCP" dir=in action=allow protocol=TCP localport=8200
