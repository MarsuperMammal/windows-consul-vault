write-output "Setting up..."

SSLDIR=C:\opt\vault\data\
SSLCERTPATH=$SSLDIR\vault.crt
SSLKEYPATH=$SSLDIR\vault.key

write-output "Configuring Consul.."
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ datacenter }}", \"${datacenter}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ node_name }}", \"$${node_name}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\vault.json | ForEach-Object { $_ -replace "{{ node_name }}", \"$${node_name}\" } ) | Set-Content C:\etc\config.d\vault.json
(Get-Content C:\etc\consul.d\join.json | ForEach-Object { $_ -replace "{{ consul_tag_key }}", \"${consul_join_tag_key}\" } ) | Set-Content C:\etc\consul.d\join.json
(Get-Content C:\etc\consul.d\join.json | ForEach-Object { $_ -replace "{{ consul_tag_value }}", \"${consul_join_tag_value}\" } ) | Set-Content C:\etc\consul.d\join.json

write-output "Staging SSL certs"
"${ssl_cert}" | out-file C:\opt\vault\data\vault.crt
"${ssl_key}" | out-file C:\opt\vault\data\vault.key

write-output "Updating cert..."
Import-Certificate -FilePath C:\opt\vault\data\vault.crt -CertStoreLocation Cert:\LocalMachine\Root

write-output "Configuring Vault.."
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ consul_server_count }}", \"${consul_server_count}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ node_name }}", \"$${node_name}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ tls_cert_file }}", "C:\\opt\\vault\\data\\vault.crt" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ tls_key_file }}", "C:\\opt\\vault\\data\\vault.key" } ) | Set-Content C:\etc\vault.d\vault.hcl

C:\opt\nssm.exe restart consul
C:\opt\nssm.exe restart vault

C:\opt\vault\scripts\setup_vault.ps1
