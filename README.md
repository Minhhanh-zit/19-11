# Bộ giám sát Docker cho Windows (Docker Desktop + WSL2)

## Cài nhanh
1. Mở Docker Desktop (đảm bảo đang dùng WSL2 backend).
2. Giải nén thư mục, mở PowerShell tại đó:
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\scripts\install.ps1
   ```
3. Mở Grafana http://localhost:3000, vào thư mục **Docker** > **Docker Overview**.

## Thành phần
| Công cụ | Vai trò | Địa chỉ |
|---|---|---|
| Prometheus | Lưu metrics, đánh giá luật cảnh báo | :9090 |
| node-exporter | Metrics máy chủ (VM WSL2) | nội bộ |
| cAdvisor | Metrics từng container | :8080 |
| Alertmanager | Gom và gửi cảnh báo (Telegram) | :9093 |
| Loki + Alloy | Lưu và thu log tập trung | nội bộ |
| Dozzle | Xem log realtime | :8888 |
| Grafana | Dashboard metrics và log | :3000 |
| Uptime Kuma | Giám sát uptime HTTP/TCP/ping | :3001 |
| Portainer | Quản lý container, volume, network | https://:9443 |

Mọi cổng chỉ mở ở 127.0.0.1 (chỉ truy cập được từ chính máy bạn).

## Volume
Tất cả dữ liệu nằm trong named volume tiền tố `mon_`:
`docker volume ls --filter label=project=monitoring`
Sao lưu: `.\scripts\backup-volumes.ps1`. Gỡ giữ dữ liệu: `.\scripts\uninstall.ps1`.

## Lấy Telegram token
Chat với @BotFather để tạo bot, lấy token. Gửi 1 tin cho bot, rồi mở
`https://api.telegram.org/bot<TOKEN>/getUpdates` để lấy `chat.id`.
Hoặc sửa tay `alertmanager/alertmanager.yml` rồi: `docker compose restart alertmanager`.

## Lưu ý riêng cho Docker Desktop
- node-exporter và cAdvisor đo **VM WSL2 của Docker**, không phải toàn bộ Windows. Muốn giám sát Windows host, cài thêm windows_exporter.
- Trên một số bản Docker Desktop, cAdvisor có thể thiếu nhãn `name` của container. Khi đó dùng Portainer/Dozzle cho từng container, hoặc xem `id` thay cho `name`.
- Đổi cấu hình Prometheus: sửa file rồi `curl -X POST http://localhost:9090/-/reload`.
