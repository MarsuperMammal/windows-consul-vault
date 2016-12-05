(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ atlas_username }}", \"${atlas_username}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ atlas_token }}", \"${atlas_token}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ datacenter }}", \"${atlas_environment}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\config.json | ForEach-Object { $_ -replace "{{ node_name }}", \"${node_name}\" } ) | Set-Content C:\etc\consul.d\config.json
(Get-Content C:\etc\consul.d\vault.json | ForEach-Object { $_ -replace "{{ node_name }}", \"${node_name}\" } ) | Set-Content C:\etc\config.d\vault.json

(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ atlas_username }}", \"${atlas_username}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ atlas_token }}", \"${atlas_token}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ consul_server_count }}", \"${consul_server_count}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ node_name }}", \"${node_name}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ tls_cert_file }}", \"${tls_cert_file}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
(Get-Content C:\etc\vault.d\vault.hcl | ForEach-Object { $_ -replace "{{ tls_key_file }}", \"${tls_key_file}\" } ) | Set-Content C:\etc\vault.d\vault.hcl
