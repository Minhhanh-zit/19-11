<#
 Cai dat bo giam sat Docker tren Windows (Docker Desktop + WSL2).
 Chay trong PowerShell:  .\scripts\install.ps1
 Co the chay lai nhieu lan (idempotent).
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# 1. Kiem tra Docker
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw "Docker chua chay. Hay mo Docker Desktop roi chay lai." }
docker compose version *> $null
if ($LASTEXITCODE -ne 0) { throw "Khong tim thay 'docker compose'. Hay cap nhat Docker Desktop." }
Write-Host "[OK] Docker san sang" -ForegroundColor Green

# 2. Tao volume (named volume do Docker quan ly)
$volumes = "mon_prometheus_data","mon_alertmanager_data","mon_loki_data","mon_alloy_data",
           "mon_grafana_data","mon_uptime_kuma_data","mon_portainer_data"
foreach ($v in $volumes) {
    docker volume create --label project=monitoring $v | Out-Null
    Write-Host "[OK] Volume $v"
}

# 3. Mat khau Grafana (.env)
if (-not (Test-Path .env)) {
    $chars = (48..57)+(65..90)+(97..122)
    $pw = -join ($chars | Get-Random -Count 16 | ForEach-Object {[char]$_})
    "GRAFANA_ADMIN_PASSWORD=$pw" | Set-Content .env -Encoding ascii
    Write-Host "[OK] Da tao .env voi mat khau Grafana ngau nhien"
}

# 4. Canh bao Telegram (tuy chon, Enter de bo qua)
$token = Read-Host "Telegram bot token (Enter de bo qua)"
if ($token) {
    $chat = Read-Host "Telegram chat_id (so)"
    @"
route:
  receiver: telegram
  group_by: [alertname]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
receivers:
  - name: telegram
    telegram_configs:
      - bot_token: "$token"
        chat_id: $chat
        parse_mode: ""
"@ | Set-Content alertmanager\alertmanager.yml -Encoding ascii
    Write-Host "[OK] Da cau hinh Alertmanager gui Telegram"
}

# 5. Khoi dong
docker compose pull
docker compose up -d
docker compose ps

$pw = (Get-Content .env | Where-Object { $_ -like "GRAFANA_ADMIN_PASSWORD=*" }) -replace "GRAFANA_ADMIN_PASSWORD=",""
Write-Host "`n===== TRUY CAP =====" -ForegroundColor Cyan
Write-Host "Grafana       http://localhost:3000   (admin / $pw)"
Write-Host "Prometheus    http://localhost:9090"
Write-Host "Alertmanager  http://localhost:9093"
Write-Host "cAdvisor      http://localhost:8080"
Write-Host "Dozzle (log)  http://localhost:8888"
Write-Host "Uptime Kuma   http://localhost:3001   (tao tai khoan lan dau)"
Write-Host "Portainer     https://localhost:9443 (tao tai khoan trong 5 phut dau)"
