# rclone-extra for macOS, Windows, Linux & Android

[![Release](https://img.shields.io/github/v/release/duongbui-drt1/rclone4mac?include_prereleases)](https://github.com/duongbui-drt1/rclone4mac/releases/latest)
[![License](https://img.shields.io/github/license/duongbui-drt1/rclone4mac)](https://github.com/duongbui-drt1/rclone4mac/blob/master/COPYING)

[**Tiếng Việt**](#tiếng-việt) | [**English**](#english-version) | [**Credits & Acknowledgments**](#credits--acknowledgments)

---

<a name="tiếng-việt"></a>
## 🇻🇳 Tiếng Việt

**rclone4mac** là bản nâng cấp từ [gulp79/rclone-extra](https://github.com/gulp79/rclone-extra) (dựa trên [rclone](https://rclone.org)), bổ sung hỗ trợ chính thức cho **macOS** (Intel & Apple Silicon), sửa lỗi Terabox pre-check / rapid upload (秒传), và tự động hóa quy trình build đa nền tảng.

### 🛠 Nâng cấp & Sửa lỗi

1. **Sửa lỗi Terabox Pre-check & Rapid Upload (秒传)**:
   - Khắc phục lỗi trả về mã lỗi `-8` khi Terabox kiểm tra file trùng / rapid upload.
   - Xử lý chính xác `return_type == 2` (Rapid Upload Success), giúp upload file siêu nhanh khi file đã tồn tại trên server Terabox.
   - Thêm kiểm tra lỗi response trong `apiCheckPremium`.

2. **Hỗ trợ đầy đủ các bản dựng (Multi-Platform Build)**:
   - **macOS**: `macos-amd64` (Intel Mac) & `macos-arm64` (Apple Silicon M1/M2/M3/M4).
   - **Windows**: `windows-amd64` (kèm WinFsp/cmount CGO static) & `windows-arm64`.
   - **Linux**: `linux-amd64`, `linux-arm64`, `linux-arm-v7`.
   - **Android**: `android-arm`, `android-arm64`, `android-386`, `android-amd64`.

3. **Tự động build Release qua GitHub Actions**:
   - Tự động biên dịch và tạo bản phát hành (Release) khi push tag `v*`.

---

### 🚀 Cách sử dụng

#### 1. Tải bản dựng có sẵn (Pre-built Binaries)
Vào phần [**Releases**](https://github.com/duongbui-drt1/rclone4mac/releases) để tải file `.zip` tương ứng với thiết bị của bạn.

#### 2. Build trực tiếp trên máy Mac (Tự động hoàn toàn)

```bash
# Tải script
curl -fsSL https://raw.githubusercontent.com/duongbui-drt1/rclone4mac/master/build-macos.sh -o build-macos.sh
chmod +x build-macos.sh

# Chạy build
bash build-macos.sh                  # Build cả Intel + Apple Silicon
bash build-macos.sh --arm64          # Build riêng cho Apple Silicon (M1/M2/M3/M4)
bash build-macos.sh --amd64          # Build riêng cho Intel Mac
```

---

<a name="english-version"></a>
## 🇬🇧 English Version

**rclone4mac** is an enhanced fork of [gulp79/rclone-extra](https://github.com/gulp79/rclone-extra) (based on official [rclone](https://rclone.org)), adding complete **macOS** support (Intel & Apple Silicon), fixing Terabox pre-check & rapid upload issues, and providing automated multi-platform release builds.

### 🛠 Enhancements & Fixes

1. **Terabox Pre-check & Rapid Upload Fix**:
   - Fixed `-8` error returned when Terabox performs rapid upload / file hash matching (`return_type == 2`).
   - Handles `return_type == 2` as Rapid Upload Success, allowing instant file uploads when matching files exist on Terabox servers.
   - Added response error checking in `apiCheckPremium`.

2. **Full Multi-Platform Binary Builds**:
   - **macOS**: `macos-amd64` (Intel Mac) & `macos-arm64` (Apple Silicon M1/M2/M3/M4).
   - **Windows**: `windows-amd64` (with WinFsp/cmount CGO static) & `windows-arm64`.
   - **Linux**: `linux-amd64`, `linux-arm64`, `linux-arm-v7`.
   - **Android**: `android-arm`, `android-arm64`, `android-386`, `android-amd64`.

3. **Automated CI/CD Release Pipeline**:
   - GitHub Actions workflow automatically builds binaries and publishes GitHub Releases upon pushing `v*` tags.

---

### 🚀 Usage

#### 1. Download Pre-built Binaries
Visit the [**Releases Page**](https://github.com/duongbui-drt1/rclone4mac/releases) to download the binary for your platform.

#### 2. Build directly on macOS (Self-Contained Script)

```bash
# Download script
curl -fsSL https://raw.githubusercontent.com/duongbui-drt1/rclone4mac/master/build-macos.sh -o build-macos.sh
chmod +x build-macos.sh

# Run build
bash build-macos.sh                  # Build both Intel & Apple Silicon
bash build-macos.sh --arm64          # Build for Apple Silicon (M1/M2/M3/M4)
bash build-macos.sh --amd64          # Build for Intel Mac
```

---

<a name="credits--acknowledgments"></a>
## 👏 Credits & Acknowledgments

This project is built upon the hard work of the open-source community:

- **Original rclone Project**: Created by [Nick Craig-Wood](https://github.com/ncw) and the amazing [rclone contributors](https://github.com/rclone/rclone/graphs/contributors). Website: [rclone.org](https://rclone.org).
- **rclone-extra Maintainer**: [gulp79 (Mirko Sandonà)](https://github.com/gulp79) for creating [gulp79/rclone-extra](https://github.com/gulp79/rclone-extra) and the [Round-Sync](https://github.com/gulp79/Round-Sync) Android GUI.
- **Terabox Backend Developer**: [x1arch](https://github.com/x1arch) for the original Terabox backend implementation ([x1arch/rclone](https://github.com/x1arch/rclone)).
- **bclone Backends Developer**: [BenjiThatFoxGuy](https://github.com/BenjiThatFoxGuy) for [bclone](https://github.com/BenjiThatFoxGuy/bclone) extra backend implementations.
- **rclone4mac Maintainer**: [duongbui-drt1](https://github.com/duongbui-drt1) for adding macOS support, fixing Terabox rapid upload, and setting up automated multi-platform release builds.

---

## 📄 License

This project is licensed under the **MIT License** — the same license as [rclone](https://github.com/rclone/rclone/blob/master/COPYING) and [gulp79/rclone-extra](https://github.com/gulp79/rclone-extra).
