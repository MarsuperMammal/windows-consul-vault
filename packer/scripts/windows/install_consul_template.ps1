write-output "Creating Consul-Template directory"
foreach ($dir in @('log', 'data')) {
  New-Item -Path "C:\opt\ctmpl\$dir" -ItemType Directory -Force
}

write-output "Setting urls"
$ctmplUrl = "https://releases.hashicorp.com/consul-template/0.18.0-rc1/consul-template_0.18.0-rc1_windows_amd64.zip"

write-output "Setting file paths"
$ctmplFilePath = "$($env:TEMP)\ctmpl.zip"

write-output "Downloading ctmpl"
(New-Object System.Net.WebClient).DownloadFile($ctmplUrl, $ctmplFilePath)

write-output "Creating shell object"
$shell = New-Object -ComObject Shell.Application

write-output "Setting namespaces"
$ctmplZip = $shell.NameSpace($ctmplFilePath)

write-output "Setting destinations"
$ctmplDestination = $shell.NameSpace("C:\opt\ctmpl")

write-output "Setting copy flags"
$copyFlags = 0x00
$copyFlags += 0x04 # Hide progress dialogs
$copyFlags += 0x10 # Overwrite existing files

write-output "Copying ctmpl"
$ctmplDestination.CopyHere($ctmplZip.Items(), $copyFlags)

# Clean up
write-output "Cleanup"
Remove-Item -Force -Path $ctmplFilePath

# Create the ctmpl service and set its options
write-output "Creating ctmpl service"
C:\opt\nssm.exe install ctmpl "C:\opt\ctmpl\ctmpl.exe" agent -config-dir "C:\etc\ctmpl.d"
write-output "Setting ctmpl options"
C:\opt\nssm.exe set ctmpl AppEnvironmentExtra "GOMAXPROCS=%NUMBER_OF_PROCESSORS%"
C:\opt\nssm.exe set ctmpl AppRotateFiles 1
C:\opt\nssm.exe set ctmpl AppRotateOnline 1
C:\opt\nssm.exe set ctmpl AppRotateBytes 10485760
C:\opt\nssm.exe set ctmpl AppStdout C:\opt\ctmpl\log\ctmpl.log
C:\opt\nssm.exe set ctmpl AppStderr C:\opt\ctmpl\log\ctmpl.log

write-output "Stopping ctmpl service"
Stop-Service ctmpl -EA silentlycontinue
Set-Service ctmpl -StartupType Manual
