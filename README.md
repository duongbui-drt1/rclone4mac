# rclone-extra cho macOS

> **rclone-extra** = [rclone](https://rclone.org) chính thức + các backend bổ sung:  
> **Teldrive** (Telegram) · **Terabox** · **Alldebrid** · **Alist**

Repo gốc: [gulp79/rclone-extra](https://github.com/gulp79/rclone-extra)  
Repo chính rclone: [rclone/rclone](https://github.com/rclone/rclone)

---

## Tại sao cần repo này?

Bản gốc gulp79/rclone-extra **không build cho macOS** (chỉ có Linux, Windows, Android).  
Repo này cung cấp:

| File | Mục đích |
|------|----------|
| `build-macos.sh` | Script tự động build trực tiếp trên máy Mac |
| `.github/workflows/build-macos.yml` | GitHub Actions build macOS khi fork |

---

## Cách 1: Build trực tiếp trên Mac (Khuyến nghị)

### Yêu cầu tối thiểu
- macOS 11+ (Big Sur trở lên)
- `git`, `curl`, `tar` — **đều có sẵn** trên macOS, không cần cài thêm
- Kết nối internet (để tải Go SDK ~70MB và source code ~60MB)

### Chạy script

```bash
# Tải script về
curl -fsSL https://raw.githubusercontent.com/YOUR_FORK/rclone-extraformac/main/build-macos.sh -o build-macos.sh

# Cấp quyền và chạy
chmod +x build-macos.sh
bash build-macos.sh
```

Hoặc nếu bạn đã clone repo này:

```bash
bash build-macos.sh
```

### Tùy chọn

```bash
bash build-macos.sh                  # Build cả amd64 + arm64 (mặc định)
bash build-macos.sh --amd64          # Chỉ Intel (Mac mini Late 2014)
bash build-macos.sh --arm64          # Chỉ Apple Silicon (Mac mini M1)
bash build-macos.sh --both --clean   # Build cả hai, xóa file tạm sau
bash build-macos.sh --update-go      # Tải lại Go SDK (nếu cần cập nhật)
```

### Kết quả

Script tạo ra các file trong thư mục `output/`:

```
output/
├── rclone-v1.75.0-extra-darwin-amd64       ← Binary cho Intel Mac
├── rclone-v1.75.0-extra-darwin-amd64.zip   ← Zip cho Intel Mac
├── rclone-v1.75.0-extra-darwin-arm64       ← Binary cho Apple Silicon
└── rclone-v1.75.0-extra-darwin-arm64.zip   ← Zip cho Apple Silicon
```

### Cài vào hệ thống

```bash
# Mac mini M1 (arm64):
xattr -c ./output/rclone-*-darwin-arm64
sudo cp ./output/rclone-*-darwin-arm64 /usr/local/bin/rclone
rclone version

# Mac mini Late 2014 (Intel/amd64):
xattr -c ./output/rclone-*-darwin-amd64
sudo cp ./output/rclone-*-darwin-amd64 /usr/local/bin/rclone
rclone version
```

> **Lưu ý về Gatekeeper:** macOS có thể chặn binary tải từ internet.  
> Lệnh `xattr -c` gỡ bỏ quarantine flag — không cần vào System Preferences.

---

## Cách 2: Dùng GitHub Actions (nếu bạn muốn tự host releases)

### Bước 1: Fork repo gulp79/rclone-extra

Truy cập https://github.com/gulp79/rclone-extra và nhấn **Fork**.

### Bước 2: Thêm workflow vào fork

Copy file `.github/workflows/build-macos.yml` từ repo này vào fork của bạn:

```bash
# Clone fork của bạn
git clone https://github.com/TEN_BAN/rclone-extra.git
cd rclone-extra

# Tạo thư mục workflow (nếu chưa có)
mkdir -p .github/workflows

# Copy workflow file từ repo này vào
cp path/to/build-macos.yml .github/workflows/

# Commit và push
git add .github/workflows/build-macos.yml
git commit -m "Add macOS build workflow"
git push
```

### Bước 3: Kích hoạt build

**Chạy thủ công:**
1. Vào fork của bạn trên GitHub
2. Tab **Actions** → **Build rclone-extra - macOS**
3. Nhấn **Run workflow** → chọn arch → **Run**
4. Sau ~5-10 phút, tải binary từ phần **Artifacts**

**Tự động khi tag:**
```bash
git tag v1.75.0-extra-mac
git push --tags
```
→ Workflow tự chạy và upload vào **Releases**

---

## Tính năng

### Có đầy đủ (Pure Go, không cần cài thêm):
- ✅ `rclone sync` / `rclone copy` / `rclone move`
- ✅ `rclone ls` / `rclone lsd` / `rclone lsl`
- ✅ `rclone serve http/ftp/webdav/dlna`
- ✅ `rclone rcat` / `rclone cat`
- ✅ Teldrive, Terabox, Alldebrid, Alist backends
- ✅ Google Drive, S3, Dropbox, OneDrive, Backblaze B2 và tất cả backends khác

### Không có (do build không CGO):
- ❌ `rclone mount` (cần macFUSE + CGO)

> **Để có `rclone mount`:** Cài [macFUSE](https://osxfuse.github.io/) và sửa script thêm `CGO_ENABLED=1`.  
> Xem phần **Build với CGO** bên dưới.

---

## Build với CGO (tính năng mount)

Nếu bạn muốn `rclone mount` hoạt động trên macOS:

```bash
# 1. Cài macFUSE từ https://osxfuse.github.io/
# 2. Cài Xcode (đầy đủ, không phải chỉ CLI tools):
#    xcode-select --install
# 3. Build với CGO:
CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 \
  go build -tags cmount -trimpath \
  -ldflags "-s -w" \
  -o rclone-darwin-arm64-with-mount \
  .
```

> ⚠️ Build CGO chỉ được cho arch native của máy (không cross-compile được).

---

## Câu hỏi thường gặp

**Q: Script chạy bao lâu?**  
A: Lần đầu ~5-10 phút (tải Go + clone source + build). Lần sau ~2-3 phút (dùng cache).

**Q: Script có cần sudo không?**  
A: Không. Script tự build trong thư mục tạm cạnh nó. Chỉ cần sudo khi copy binary vào `/usr/local/bin`.

**Q: Có tương thích với Homebrew rclone không?**  
A: Hoàn toàn. Bạn có thể dùng song song hoặc thay thế. rclone-extra dùng cùng format config.

**Q: File config ở đâu?**  
A: `~/.config/rclone/rclone.conf` — giống hệt rclone chính thức.

---

## License

MIT — Giống với [rclone](https://github.com/rclone/rclone/blob/master/COPYING) và [rclone-extra](https://github.com/gulp79/rclone-extra).
