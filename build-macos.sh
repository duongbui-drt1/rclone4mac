#!/usr/bin/env bash
# ==============================================================================
# build-macos.sh — Tự động build rclone-extra cho macOS
#
# Dùng được trên:
#   • Mac mini Late 2014  (Intel / amd64)
#   • Mac mini M1 / M2 / M3 / M4  (Apple Silicon / arm64)
#
# Không cần cài gì trước — script tự tải Go và tự build.
# Chỉ cần: curl, git, tar (đều có sẵn trên macOS mặc định)
#
# Cách dùng:
#   bash build-macos.sh              # build cả amd64 và arm64
#   bash build-macos.sh --arm64      # chỉ Apple Silicon
#   bash build-macos.sh --amd64      # chỉ Intel
#   bash build-macos.sh --both --clean
# ==============================================================================

set -euo pipefail

# ── Cấu hình ──────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/gulp79/rclone-extra.git"
REPO_BRANCH="master"
GO_VERSION="1.24.5"            # Go ổn định mới nhất (tương thích rclone v1.75)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/_build_tmp"
GO_DIR="$WORK_DIR/go_sdk"
SRC_DIR="$WORK_DIR/rclone-extra"
OUT_DIR="$SCRIPT_DIR/output"
# ──────────────────────────────────────────────────────────────────────────────

# ── Màu terminal ──────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

info()   { echo -e "${BLUE}[INFO]${RESET}  $*"; }
ok()     { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()   { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
err()    { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }
header() { echo -e "\n${BOLD}${BLUE}━━━ $* ━━━${RESET}"; }
# ──────────────────────────────────────────────────────────────────────────────

# ── Phát hiện architecture của máy hiện tại ───────────────────────────────────
detect_host_arch() {
    case "$(uname -m)" in
        x86_64) echo "amd64" ;;
        arm64)  echo "arm64" ;;
        *)      err "Kiến trúc không hỗ trợ: $(uname -m)" ;;
    esac
}
HOST_ARCH="$(detect_host_arch)"
# ──────────────────────────────────────────────────────────────────────────────

# ── Parse arguments ───────────────────────────────────────────────────────────
BUILD_ARCHS=()
CLEAN_AFTER=false
FORCE_REDOWNLOAD_GO=false

usage() {
    echo ""
    echo -e "${BOLD}build-macos.sh${RESET} — Build rclone-extra cho macOS"
    echo ""
    echo -e "${BOLD}Cách dùng:${RESET}"
    echo "  bash build-macos.sh [options]"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo "  --amd64        Build cho Intel Mac (x86_64)"
    echo "  --arm64        Build cho Apple Silicon (M1/M2/M3/M4)"
    echo "  --both         Build cả hai (mặc định)"
    echo "  --clean        Xóa thư mục tạm sau khi build xong"
    echo "  --update-go    Tải lại Go SDK dù đã có"
    echo "  -h, --help     Hiển thị trợ giúp này"
    echo ""
    echo -e "${BOLD}Ví dụ:${RESET}"
    echo "  bash build-macos.sh                 # build cả hai arch"
    echo "  bash build-macos.sh --arm64 --clean # chỉ M1, dọn tạm sau"
    echo ""
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --amd64)      BUILD_ARCHS=("amd64") ;;
        --arm64)      BUILD_ARCHS=("arm64") ;;
        --both)       BUILD_ARCHS=("amd64" "arm64") ;;
        --clean)      CLEAN_AFTER=true ;;
        --update-go)  FORCE_REDOWNLOAD_GO=true ;;
        -h|--help)    usage ;;
        *)            warn "Bỏ qua tham số không rõ: $arg" ;;
    esac
done

# Mặc định: build cả hai
if [[ ${#BUILD_ARCHS[@]} -eq 0 ]]; then
    BUILD_ARCHS=("amd64" "arm64")
fi
# ──────────────────────────────────────────────────────────────────────────────

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${BLUE}║     rclone-extra macOS Builder                   ║${RESET}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════╝${RESET}"
echo -e "  Máy hiện tại  : ${BOLD}darwin/${HOST_ARCH}${RESET}"
echo -e "  Target build  : ${BOLD}darwin/${BUILD_ARCHS[*]}${RESET}"
echo -e "  Output        : ${BOLD}${OUT_DIR}${RESET}"
echo -e "  Go version    : ${BOLD}${GO_VERSION}${RESET}"
echo ""
# ──────────────────────────────────────────────────────────────────────────────

# ── Kiểm tra công cụ tối thiểu ────────────────────────────────────────────────
header "Bước 1: Kiểm tra công cụ cơ bản"

check_cmd() {
    if command -v "$1" &>/dev/null; then
        ok "$1  →  $(command -v "$1")"
    else
        err "Thiếu công cụ: '$1'
       Chạy lệnh sau để cài Xcode CLI tools:
         xcode-select --install"
    fi
}
check_cmd curl
check_cmd git
check_cmd tar
# ──────────────────────────────────────────────────────────────────────────────

# ── Tải & cài Go SDK (vào thư mục tạm, không ảnh hưởng hệ thống) ─────────────
header "Bước 2: Chuẩn bị Go ${GO_VERSION}"

GO_TARBALL="go${GO_VERSION}.darwin-${HOST_ARCH}.tar.gz"
GO_DOWNLOAD_URL="https://dl.google.com/go/${GO_TARBALL}"
GO_INSTALL_DIR="$GO_DIR/go${GO_VERSION}"
GOBIN_PATH="$GO_INSTALL_DIR/bin/go"

mkdir -p "$GO_DIR"

if [[ -x "$GOBIN_PATH" && "$FORCE_REDOWNLOAD_GO" == "false" ]]; then
    ok "Go đã có: $("$GOBIN_PATH" version)"
else
    info "Tải Go ${GO_VERSION} cho darwin/${HOST_ARCH} ..."
    info "→ $GO_DOWNLOAD_URL"

    TARBALL_PATH="$GO_DIR/$GO_TARBALL"
    curl -fL --progress-bar -o "$TARBALL_PATH" "$GO_DOWNLOAD_URL" \
        || err "Tải thất bại. Kiểm tra kết nối mạng."

    info "Giải nén ..."
    rm -rf "$GO_INSTALL_DIR"
    mkdir -p "$GO_INSTALL_DIR"
    tar -xzf "$TARBALL_PATH" -C "$GO_INSTALL_DIR" --strip-components=1
    rm -f "$TARBALL_PATH"

    ok "Go đã cài: $("$GOBIN_PATH" version)"
fi

export GOROOT="$GO_INSTALL_DIR"
export GOPATH="$WORK_DIR/gopath"
export GOPROXY="https://proxy.golang.org,direct"
export GONOSUMCHECK="*"
export PATH="$GO_INSTALL_DIR/bin:$PATH"
mkdir -p "$GOPATH"
# ──────────────────────────────────────────────────────────────────────────────

# ── Clone / Update source code ─────────────────────────────────────────────────
header "Bước 3: Lấy source code rclone-extra"

if [[ -d "$SRC_DIR/.git" ]]; then
    info "Source đã có, cập nhật lên commit mới nhất ..."
    git -C "$SRC_DIR" fetch --quiet origin
    git -C "$SRC_DIR" reset --hard "origin/${REPO_BRANCH}" --quiet
    ok "Source đã cập nhật"
else
    info "Clone từ GitHub ..."
    info "→ $REPO_URL  (branch: $REPO_BRANCH)"
    git clone --depth=50 --branch "$REPO_BRANCH" "$REPO_URL" "$SRC_DIR"
    ok "Clone hoàn tất"
fi

# Lấy version metadata
cd "$SRC_DIR"
RCLONE_VERSION="$(git describe --tags --abbrev=0 2>/dev/null || echo 'dev')"
GIT_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
info "Version: ${RCLONE_VERSION}  |  Commit: ${GIT_COMMIT}"
# ──────────────────────────────────────────────────────────────────────────────

# ── Tải Go dependencies ────────────────────────────────────────────────────────
header "Bước 4: Tải Go modules"
info "go mod download ..."
go mod download -x 2>&1 | tail -5 || true
ok "Modules đã tải"
# ──────────────────────────────────────────────────────────────────────────────

# ── Hàm build cho một architecture ────────────────────────────────────────────
build_rclone() {
    local ARCH="$1"
    local OUT_NAME="rclone-${RCLONE_VERSION}-darwin-${ARCH}"
    local BIN_PATH="$OUT_DIR/${OUT_NAME}"

    header "Bước BUILD: darwin/${ARCH}"
    mkdir -p "$OUT_DIR"

    info "Biên dịch ... (có thể mất 2-5 phút)"

    # CGO_ENABLED=0 → Pure Go, không cần macFUSE, chạy trên mọi macOS
    # Tính năng bị bỏ: mount (rclone mount)
    # Tất cả tính năng khác đều đầy đủ: sync, copy, ls, serve, etc.
    CGO_ENABLED=0 \
    GOOS=darwin \
    GOARCH="${ARCH}" \
    go build \
        -trimpath \
        -ldflags "-s -w \
            -X github.com/rclone/rclone/fs.Version=${RCLONE_VERSION} \
            -X main.GitCommit=${GIT_COMMIT} \
            -X main.BuildDate=${BUILD_DATE}" \
        -o "${BIN_PATH}" \
        . \
    || err "Build thất bại cho darwin/${ARCH}"

    chmod +x "${BIN_PATH}"

    # Đóng gói zip (cùng format với releases chính thức)
    local ZIP_DIR="$OUT_DIR/_zip_tmp_${ARCH}"
    local ZIP_PATH="$OUT_DIR/${OUT_NAME}.zip"
    rm -rf "$ZIP_DIR"
    mkdir -p "$ZIP_DIR/rclone-${RCLONE_VERSION}-darwin-${ARCH}"
    cp "${BIN_PATH}" "$ZIP_DIR/rclone-${RCLONE_VERSION}-darwin-${ARCH}/rclone"
    (
        cd "$ZIP_DIR"
        zip -qr "${ZIP_PATH}" "rclone-${RCLONE_VERSION}-darwin-${ARCH}/"
    )
    rm -rf "$ZIP_DIR"

    local BIN_SIZE ZIP_SIZE
    BIN_SIZE=$(du -sh "${BIN_PATH}" | cut -f1)
    ZIP_SIZE=$(du -sh "${ZIP_PATH}" | cut -f1)

    ok "  Binary : ${BIN_PATH}  (${BIN_SIZE})"
    ok "  Zip    : ${ZIP_PATH}  (${ZIP_SIZE})"

    # Kiểm tra chạy được nếu cùng arch với máy host
    if [[ "${ARCH}" == "${HOST_ARCH}" ]]; then
        echo ""
        info "Kiểm tra binary ..."
        # Gỡ Gatekeeper quarantine (nếu có)
        xattr -c "${BIN_PATH}" 2>/dev/null || true
        if "${BIN_PATH}" version 2>/dev/null; then
            ok "Binary chạy OK!"
        else
            warn "Binary tạo ra nhưng không chạy được."
            warn "Thử: xattr -c ${BIN_PATH}"
        fi
    else
        info "Cross-compiled ${ARCH} → sẽ chạy được trên máy ${ARCH} tương ứng"
    fi
}
# ──────────────────────────────────────────────────────────────────────────────

# ── Thực hiện build từng architecture ─────────────────────────────────────────
for ARCH in "${BUILD_ARCHS[@]}"; do
    build_rclone "${ARCH}"
done
# ──────────────────────────────────────────────────────────────────────────────

# ── Tóm tắt kết quả cuối ──────────────────────────────────────────────────────
header "HOÀN TẤT"
echo ""
echo -e "${BOLD}  Files đã tạo trong: ${OUT_DIR}/${RESET}"
echo ""
ls -lh "$OUT_DIR/" | grep -v '^total' | awk '{printf "    %-50s %s\n", $NF, $5}'
echo ""
echo -e "${BOLD}  Cách cài vào hệ thống:${RESET}"
echo ""

for ARCH in "${BUILD_ARCHS[@]}"; do
    BIN="$OUT_DIR/rclone-${RCLONE_VERSION}-darwin-${ARCH}"
    echo -e "  ${YELLOW}# Trên Mac ${ARCH}:${RESET}"
    echo    "  xattr -c \"${BIN}\""
    echo    "  sudo cp \"${BIN}\" /usr/local/bin/rclone"
    echo    "  rclone version"
    echo ""
done

echo -e "  ${YELLOW}# Nếu muốn thêm vào PATH mà không copy:${RESET}"
echo    "  export PATH=\"${OUT_DIR}:\$PATH\""
echo ""
# ──────────────────────────────────────────────────────────────────────────────

# ── Dọn thư mục tạm nếu --clean ───────────────────────────────────────────────
if [[ "$CLEAN_AFTER" == "true" ]]; then
    header "Dọn dẹp"
    info "Xóa: $WORK_DIR"
    rm -rf "$WORK_DIR"
    ok "Đã xóa thư mục tạm"
else
    info "Thư mục tạm giữ lại tại: $WORK_DIR"
    info "Lần build sau sẽ nhanh hơn (không cần tải lại Go/source)"
    info "Chạy với --clean để tự xóa sau build"
fi

echo ""
echo -e "${GREEN}${BOLD}✓ rclone-extra ${RCLONE_VERSION} đã build thành công cho macOS!${RESET}"
echo ""
