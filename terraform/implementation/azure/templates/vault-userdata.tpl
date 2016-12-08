write-output "Setting up..."

SSLDIR=C:\opt\vault\data\
SSLCERTPATH=$SSLDIR\vault.crt
SSLKEYPATH=$SSLDIR\vault.key

write-output "Configuring Consul.."
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ atlas_username }}", \"${atlas_username}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ atlas_token }}", \"${atlas_token}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ datacenter }}", \"${atlas_environment}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ node_name }}", \"${node_name}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\vault.json | ForEach-Object { $_ -replace "{{ node_name }}", \"${node_name}\" } ) | Set-Content C:\etc\config.d\vault.json

write-output "Staging SSL certs"
"${ssl_cert}" | out-file C:\opt\vault\data\vault.crt
"${ssl_key}" | out-file C:\opt\vault\data\vault.key

write-output "Updating cert..."
Import-Certificate -FilePath C:\opt\vault\data\vault.crt -CertStoreLocation Cert:\LocalMachine\Root

write-output "Configuring Vault.."
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ atlas_username }}", \"${atlas_username}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ atlas_token }}", \"${atlas_token}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ consul_server_count }}", \"${consul_server_count}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ node_name }}", \"${node_name}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ tls_cert_file }}", "C:\\opt\\vault\\data\\vault.crt" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ tls_key_file }}", "C:\\opt\\vault\\data\\vault.key" } ) | Set-Content C:\etc\vault.d\vault.hcl
