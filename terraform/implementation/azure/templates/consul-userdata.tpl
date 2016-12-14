node_name = $env:computername
New-Item -Path "C:\opt\vault\data" -ItemType Directory -Force
write-output "Setting up..."

SSLDIR=C:\opt\vault\data\
SSLCERTPATH=$SSLDIR\vault.crt

write-output "Staging SSL certs"
"${ssl_cert}" | out-file C:\opt\vault\data\vault.crt

write-output "Updating cert..."
Import-Certificate -FilePath C:\opt\vault\data\vault.crt -CertStoreLocation Cert:\LocalMachine\Root

(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ consul_server_count }}", \"${consul_server_count}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ datacenter }}", \"${datacenter}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ node_name }}", \"$${node_name}\" } ) | Set-Content C:\etc\consul.d\config.json

C:\opt\nssm.exe restart consul
