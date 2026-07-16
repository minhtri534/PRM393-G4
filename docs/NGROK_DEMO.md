# Demo DLSS bằng Ngrok (1 tunnel — đơn giản)

Dùng khi Wi-Fi trường chặn máy nói chuyện nhau, hoặc muốn test khác mạng LAN.

**Lưu ý:** Gói ngrok free chỉ có **1 domain cố định**, nên project dùng **1 tunnel** cho cả API + chat (realtime server tự proxy `/api` sang backend).

## Cần chạy gì?

```
Laptop
├── Docker: db + backend (5000) + realtime (5001)
└── Ngrok 1 tunnel → port 5001 (API + chat cùng URL)

Điện thoại / emulator
└── App trỏ 1 URL ngrok (HTTPS)
```

## Bước 1 — Cài Ngrok + authtoken (một lần)

1. Tải: https://ngrok.com/download
2. Đăng ký free: https://dashboard.ngrok.com/signup
3. Copy authtoken: https://dashboard.ngrok.com/get-started/your-authtoken
4. PowerShell:

```powershell
ngrok config add-authtoken <DÁN_TOKEN_VÀO_ĐÂY>
```

## Bước 2 — Chạy Docker

```powershell
cd C:\Users\ADMIN\Documents\GitHub\PRM393-G4
docker compose up -d --build db backend realtime
docker compose ps
```

Cả 3 service phải **Up**.

## Bước 3 — Mở Ngrok (1 cửa sổ PowerShell, giữ mở suốt demo)

```powershell
cd C:\Users\ADMIN\Documents\GitHub\PRM393-G4
ngrok start dlss-demo --config "C:\Users\ADMIN\AppData\Local\Packages\ngrok.ngrok_1g87z0zv29zzc\LocalCache\Local\ngrok\ngrok.yml" --config "C:\Users\ADMIN\Documents\GitHub\PRM393-G4\ngrok.yml"
```

URL public (domain cố định của bạn):

```text
https://spinach-subtext-moonstone.ngrok-free.dev
```

Mở dashboard ngrok trên laptop: http://127.0.0.1:4040

## Bước 4 — Test nhanh

Health (chat server):

```text
https://spinach-subtext-moonstone.ngrok-free.dev/health
```

Kỳ vọng: `{"ok":true}`

Login API (PowerShell):

```powershell
Invoke-WebRequest -Uri "https://spinach-subtext-moonstone.ngrok-free.dev/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Headers @{ "ngrok-skip-browser-warning" = "true" } `
  -Body '{"email":"annotator@demo.local","password":"Password123!"}'
```

Thấy `accessToken` → OK.

## Bước 5 — Build / chạy app

Chỉ cần **1 URL** cho cả API và chat:

```text
API:   https://spinach-subtext-moonstone.ngrok-free.dev/api
Chat:  https://spinach-subtext-moonstone.ngrok-free.dev
```

### Android APK (điện thoại thật)

```powershell
cd C:\Users\ADMIN\Documents\GitHub\PRM393-G4\mobile_app

flutter build apk --debug `
  --dart-define=API_BASE_URL=https://spinach-subtext-moonstone.ngrok-free.dev/api `
  --dart-define=SOCKET_URL=https://spinach-subtext-moonstone.ngrok-free.dev
```

APK: `mobile_app\build\app\outputs\flutter-apk\app-debug.apk`

### Emulator Android

```powershell
flutter run `
  --dart-define=API_BASE_URL=https://spinach-subtext-moonstone.ngrok-free.dev/api `
  --dart-define=SOCKET_URL=https://spinach-subtext-moonstone.ngrok-free.dev
```

### iPhone (Safari — Flutter Web)

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 `
  --dart-define=API_BASE_URL=https://spinach-subtext-moonstone.ngrok-free.dev/api `
  --dart-define=SOCKET_URL=https://spinach-subtext-moonstone.ngrok-free.dev
```

Mở Safari: `http://<IP-laptop>:8080` (giao diện web vẫn host trên laptop, API/chat qua ngrok).

## Bước 6 — Test chat realtime

| Máy | Tài khoản |
|-----|-----------|
| 1 | `annotator@demo.local` / `Password123!` |
| 2 | `reviewer@demo.local` / `Password123!` |

Vào tab **Chat** → chọn cùng project → nhắn thử.

## Lưu ý khi demo

- Laptop phải **bật**, Docker + **cửa sổ ngrok** chạy suốt buổi demo
- Cần **internet** (ngrok đi qua cloud)
- Đừng tắt ngrok giữa chừng
- Nếu cùng Wi-Fi LAN ổn định, có thể demo bằng IP `192.168.x.x` (không cần ngrok) — xem README chính

## Tài khoản demo

| Role | Email | Password |
|------|-------|----------|
| Annotator | annotator@demo.local | Password123! |
| Reviewer | reviewer@demo.local | Password123! |
| Manager | manager@demo.local | Password123! |
