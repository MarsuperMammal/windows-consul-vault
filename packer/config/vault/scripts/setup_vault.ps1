$body = @{
  secret_shares = 5
  secret_threshold = 3
}
$json = $body | ConvertTo-Json
$resp = Invoke-RestMethod -Method Put -Body $json -Uri "https://{{ vault_fqdn }}:8200/v1/sys/init" -OutFile "C:\Windows\Temp\vault.init"

$respo = Get-Content -Path C:\Windows\Temp\vault.init |ConvertFrom-Json
Remove-Item -Path C:\Windows\Temp\vault.init
$keys = $respo.keys
$counter = 1
forEach ($key in $keys) {
  Invoke-RestMethod -Method Put -Body $key -Uri "http://{{ consul_fqdn }}:8500/v1/kv/service/vault/unseal-key-$counter"
  $counter=$counter+1
}

Invoke-RestMethod -Method Put -Body $respo.root_token -Uri "http://{{ consul_fqdn }}:8500/v1/kv/service/vault/root_token"
$root_token = $respo.root_token

C:\opt\vault\vault.exe unseal -address="https://{{ vault_fqdn }}:8200" $respo.keys[0]
C:\opt\vault\vault.exe unseal -address="https://{{ vault_fqdn }}:8200" $respo.keys[1]
C:\opt\vault\vault.exe unseal -address="https://{{ vault_fqdn }}:8200" $respo.keys[2]
