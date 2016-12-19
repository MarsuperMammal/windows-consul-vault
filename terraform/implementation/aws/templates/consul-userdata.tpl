<powershell>
node_name = $env:computername
New-Item -Path "C:\opt\vault\data" -ItemType Directory -Force
write-output "Setting up..."

SSLDIR=C:\opt\vault\data\
SSLCERTPATH=$SSLDIR\vault.crt

write-output "Staging SSL certs"
"${ssl_cert}" | out-file C:\opt\vault\data\vault.crt

invoke-expression -Command C:\opt\install_acrylic.ps1

$defaultInterface = (Get-DnsClientServerAddress).InterfaceAlias[0]
$dns = (Get-DnsClientServerAddress -InterfaceAlias $defaultInterface).ServerAddresses
Set-DnsClientServerAddress -InterfaceAlias $defaultInterface -ServerAddresses '127.0.0.1'
$acrylicConfig = "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicConfiguration.ini"
(Get-Content "$acrylicConfig" | ForEach-Object { $_ -replace "{{ dns_server }}", "$dns" } ) | Set-Content "$acrylicConfig"
Start-Process "C:\Program Files (x86)\Acrylic DNS Proxy\RestartAcrylicServiceSilently.bat"

write-output "Updating cert..."
Import-Certificate -FilePath C:\opt\vault\data\vault.crt -CertStoreLocation Cert:\LocalMachine\Root

(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ consul_server_count }}", \"${consul_server_count}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ datacenter }}", \"${datacenter}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ node_name }}", \"$${node_name}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\join.json | ForEach-Object { $_ -replace "{{ consul_tag_key }}", \"${consul_server_join_tag_key}\" } ) | Set-Content C:\etc\consul.d\join.json
(Get-Content C:\etc\consul.d\join.json | ForEach-Object { $_ -replace "{{ consul_tag_value }}", \"${consul_server_join_tag_value}\" } ) | Set-Content C:\etc\consul.d\join.json

C:\opt\nssm.exe restart consul
</powershell>
