# rclone-extra for macOS, Windows, Linux, Android & iOS

> **rclone-extra** = [rclone](https://rclone.org) chính thức + các backend bổ sung:  
> **Teldrive** (Telegram) · **Terabox** · **Alldebrid** · **Alist** · **iCloud Photos**

Repo này sửa lỗi Terabox pre-check / rapid upload và bổ sung build workflow hoàn chỉnh cho tất cả các hệ điều hành: **macOS, Windows, Linux, Android, iOS**.

---

## 🛠 Nâng cấp & Sửa lỗi trong bản này

1. **Fix Terabox Pre-check & Rapid Upload**:
   - Khắc phục lỗi trả về mã lỗi `-8` khi Terabox kiểm tra file trùng /秒传 (Rapid Upload).
   - Xử lý chính xác `return_type == 2` (Rapid Upload Success) giúp upload file siêu nhanh và ổn định.
   - Thêm kiểm tra lỗi response trong `apiCheckPremium`.

2. **Hỗ trợ đầy đủ các bản dựng (Multi-Platform Build)**:
   - **macOS**: Intel (`darwin/amd64`) & Apple Silicon (`darwin/arm64`)
   - **Windows**: `windows/amd64` (WinFsp/cmount CGO static) & `windows/arm64`
   - **Linux**: `linux/amd64`, `linux/arm64`, `linux/arm-v7`
   - **Android**: `android/arm`, `android/arm64`, `android/386`, `android/amd64`
   - **iOS**: `ios/arm64`

---

## 🚀 Cách sử dụng

### 1. Build trực tiếp trên Mac (Script tự động)

```bash
# Tải script
curl -fsSL https://raw.githubusercontent.com/duongbui-drt1/rclone4mac/master/build-macos.sh -o build-macos.sh
chmod +x build-macos.sh

# Chạy build
bash build-macos.sh                  # Build cả Intel + Apple Silicon
bash build-macos.sh --arm64          # Build cho Mac mini M1 / Apple Silicon
bash build-macos.sh --amd64          # Build cho Mac mini 2014 / Intel
```

### 2. Build tự động qua GitHub Actions (CI/CD)

Khi bạn push tag dạng `v*` (ví dụ `v1.75.0-extra`):
Workflow `.github/workflows/build.yml` sẽ tự động biên dịch và tạo file phát hành (Release) cho tất cả các nền tảng:
- `rclone-macos-amd64.zip` / `rclone-macos-arm64.zip`
- `rclone-windows-amd64.zip` / `rclone-windows-arm64.zip`
- `rclone-linux-amd64.zip` / `rclone-linux-arm64.zip` / `rclone-linux-arm-v7.zip`
- `rclone-android-all.zip`
- `rclone-ios-arm64.zip`

---

## 📄 License

MIT License — Giống với [rclone](https://github.com/rclone/rclone/blob/master/COPYING) và [gulp79/rclone-extra](https://github.com/gulp79/rclone-extra).
