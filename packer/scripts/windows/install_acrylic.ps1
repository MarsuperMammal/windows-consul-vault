
write-output "Creating Acrylic DNS Proxy directory"
New-Item -Path "C:\Program Files (x86)\Acrylic DNS Proxy" -ItemType Directory -Force

write-output "Setting urls"
$acrylicUrl = "https://sourceforge.net/projects/acrylic/files/Acrylic/0.9.35/Acrylic-Portable.zip/download"

write-output "Setting file paths"
$acrylicFilePath = "$($env:TEMP)\Acrylic-Portable.zip"

write-output "Downloading acrylic"
(New-Object System.Net.WebClient).DownloadFile($acrylicUrl, $acrylicFilePath)

write-output "Creating shell object"
$shell = New-Object -ComObject Shell.Application

write-output "Setting namespaces"
$acrylicZip = $shell.NameSpace($acrylicFilePath)

write-output "Setting destinations"
$acrylicDestination = $shell.NameSpace("C:\Program Files (x86)\Acrylic DNS Proxy")

write-output "Setting copy flags"
$copyFlags = 0x00
$copyFlags += 0x04 # Hide progress dialogs
$copyFlags += 0x10 # Overwrite existing files

write-output "Copying acrylic"
$acrylicDestination.CopyHere($acrylicZip.Items(), $copyFlags)
$acrylicConfig = "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicConfiguration.ini"

$ini = @"
[GlobalSection]
PrimaryServerAddress=127.0.0.1
PrimaryServerPort=8600
PrimaryServerProtocol=UDP
PrimaryServerDomainNameAffinityMask=*.consul
IgnoreNegativeResponsesFromPrimaryServer=No
SecondaryServerAddress={{ dns_server }}
SecondaryServerPort=53
SecondaryServerProtocol=UDP
IgnoreNegativeResponsesFromSecondaryServer=No
AddressCacheDisabled=Yes
LocalIPv4BindingAddress=0.0.0.0
LocalIPv4BindingPort=53
LocalIPv6BindingAddress=0:0:0:0:0:0:0:0
LocalIPv6BindingPort=53
LocalIPv6BindingEnabledOnWindowsVersionsPriorToWindowsVistaOrWindowsServer2008=No
GeneratedResponseTimeToLive=60
[AllowedAddressesSection]
[CacheExceptionsSection]
[WhiteExceptionsSection]
"@

$ini | out-file "$acrylicConfig"

(Get-Content "$acrylicConfig" | ForEach-Object { $_ -replace "{{ dns_server }}", "$dns" } ) | Set-Content "$acrylicConfig"

Start-Process "C:\Program Files (x86)\Acrylic DNS Proxy\RestartAcrylicServiceSilently.bat"
# Clean up
write-output "Cleanup"
Remove-Item -Force -Path $acrylicFilePath
