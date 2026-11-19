<#
 Sao luu toan bo volume cua bo giam sat ra thu muc .\backups (file .tar.gz).
 Chay:  .\scripts\backup-volumes.ps1
 Khoi phuc 1 volume:
   docker run --rm -v mon_grafana_data:/data -v ${PWD}\backups:/backup alpine `
     sh -c "cd /data && tar xzf /backup/<file>.tar.gz"
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $root "backups"
New-Item -ItemType Directory -Force $dest | Out-Null
$stamp = Get-Date -Format "yyyyMMdd-HHmm"
$vols = docker volume ls -q --filter label=project=monitoring
foreach ($v in $vols) {
    docker run --rm -v "${v}:/data:ro" -v "${dest}:/backup" alpine `
        tar czf "/backup/$v-$stamp.tar.gz" -C /data .
    Write-Host "[OK] $v -> backups\$v-$stamp.tar.gz"
}
