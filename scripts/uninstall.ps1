# Go container. Them -RemoveData de xoa luon volume (MAT DU LIEU).
param([switch]$RemoveData)
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
docker compose down
if ($RemoveData) {
    docker volume ls -q --filter label=project=monitoring | ForEach-Object { docker volume rm $_ }
}
