#!/usr/bin/env bash


# ============================================================
# AnhTuan201X Repo - sync.sh
# GitHub Pages:
# https://anhtuan201x.github.io/
#
# Cấu trúc:
#   debs/                         -> DEB packages
#   ipas/                         -> IPA files
#   ipas/manifests/               -> OTA manifests
#   dists/stable/...              -> Cydia/Sileo/Zebra metadata
# ============================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

REPO_URL="https://anhtuan201x.github.io"
REPO_NAME="AnhTuan201X Repo"
MAINTAINER="AnhTuan201X <anhtuan201x@github.io>"

DEB_DIR="$REPO_DIR/debs"
IPA_DIR="$REPO_DIR/ipas"
MANIFEST_DIR="$IPA_DIR/manifests"

DIST_DIR="$REPO_DIR/dists/stable"
BINARY_DIR="$DIST_DIR/main/binary-iphoneos-arm"

mkdir -p \
    "$DEB_DIR" \
    "$IPA_DIR" \
    "$MANIFEST_DIR" \
    "$BINARY_DIR"

echo "=========================================="
echo " AnhTuan201X Repo Sync"
echo "=========================================="
echo

# ============================================================
# 0. KIỂM TRA TOOL
# ============================================================

need_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[ERROR] Thiếu command: $1"
        echo
        echo "Cài trên Debian/Ubuntu:"
        echo "  sudo apt update"
        echo "  sudo apt install dpkg-dev unzip bzip2 python3"
        exit 1
    fi
}

need_command dpkg-deb
need_command dpkg-scanpackages
need_command bzip2
need_command unzip
need_command python3

# ============================================================
# 1. DỌN FILE TẠM
# ============================================================

rm -rf \
    "$DEB_DIR/.tmp_ipa" \
    "$DEB_DIR/.tmp_icons"

mkdir -p "$MANIFEST_DIR"

# Xóa manifest cũ để tránh còn file IPA đã bị xóa
find "$MANIFEST_DIR" -maxdepth 1 -type f -name "*.plist" -delete

# ============================================================
# 2. HÀM ĐỌC INFO.PLIST
# ============================================================

read_plist_value() {
    local plist="$1"
    local key="$2"

    python3 - "$plist" "$key" <<'PY'
import sys
import plistlib

path = sys.argv[1]
key = sys.argv[2]

try:
    with open(path, "rb") as f:
        data = plistlib.load(f)

    value = data.get(key, "")

    if isinstance(value, bytes):
        value = value.decode("utf-8", errors="ignore")

    print(str(value))
except Exception:
    print("")
PY
}

# ============================================================
# 3. TẠO DEB TỪ IPA
#
# LƯU Ý:
# Đây là kiểu đóng gói App.app vào /Applications.
# Nó KHÔNG chuyển đổi binary ARM/ARM64 bên trong IPA.
# ============================================================

echo "[1/6] Kiểm tra IPA..."

ipa_count=0
deb_created=0

shopt -s nullglob

ipa_files=( "$IPA_DIR"/*.ipa )

for ipa in "${ipa_files[@]}"; do

    [ -f "$ipa" ] || continue

    ipa_count=$((ipa_count + 1))

    filename="$(basename "$ipa")"
    clean_name="${filename%.ipa}"

    # Tên package an toàn
    clean_id="$(
        printf '%s' "$clean_name" |
        tr '[:upper:]' '[:lower:]' |
        sed 's/[^a-z0-9._-]/./g' |
        sed 's/^\.*//' |
        sed 's/\.*$//'
    )"

    [ -n "$clean_id" ] || clean_id="app"

    echo "  -> $filename"

    TMP_DIR="$DEB_DIR/.tmp_ipa"
    OUT_DIR="$DEB_DIR/.tmp_out"

    rm -rf "$TMP_DIR" "$OUT_DIR"

    mkdir -p \
        "$TMP_DIR" \
        "$OUT_DIR/DEBIAN" \
        "$OUT_DIR/Applications"

    if ! unzip -q "$ipa" -d "$TMP_DIR"; then
        echo "     [WARN] Không giải nén được: $filename"
        rm -rf "$TMP_DIR" "$OUT_DIR"
        continue
    fi

    # Tìm App.app
    app_folder="$(
        find "$TMP_DIR/Payload" \
            -maxdepth 2 \
            -type d \
            -name "*.app" \
            2>/dev/null |
        head -n 1
    )"

    if [ -z "$app_folder" ] || [ ! -d "$app_folder" ]; then
        echo "     [WARN] Không tìm thấy Payload/*.app"
        rm -rf "$TMP_DIR" "$OUT_DIR"
        continue
    fi

    app_name="$(basename "$app_folder")"

    cp -R "$app_folder" "$OUT_DIR/Applications/"

    INFO_PLIST="$OUT_DIR/Applications/$app_name/Info.plist"

    bundle_id=""
    bundle_version=""
    short_version=""
    display_name=""

    if [ -f "$INFO_PLIST" ]; then

        bundle_id="$(
            read_plist_value "$INFO_PLIST" "CFBundleIdentifier"
        )"

        bundle_version="$(
            read_plist_value "$INFO_PLIST" "CFBundleVersion"
        )"

        short_version="$(
            read_plist_value "$INFO_PLIST" "CFBundleShortVersionString"
        )"

        display_name="$(
            read_plist_value "$INFO_PLIST" "CFBundleDisplayName"
        )"

        [ -n "$display_name" ] || \
            display_name="$(
                read_plist_value "$INFO_PLIST" "CFBundleName"
            )"
    fi

    # Fallback
    if [ -z "$bundle_id" ]; then
        bundle_id="com.anhtuan201x.$clean_id"
    fi

    if [ -z "$display_name" ]; then
        display_name="$clean_name"
    fi

    if [ -z "$bundle_version" ]; then
        bundle_version="$short_version"
    fi

    if [ -z "$bundle_version" ]; then
        bundle_version="1.0"
    fi

    # Debian version không được có khoảng trắng
    bundle_version="$(
        printf '%s' "$bundle_version" |
        tr ' ' '.' |
        sed 's/[^0-9A-Za-z.+:~-]/./g'
    )"

    # Package name phải lowercase/không có ký tự lạ
    package_name="$(
        printf '%s' "$bundle_id" |
        tr '[:upper:]' '[:lower:]' |
        sed 's/[^a-z0-9.+-]/./g'
    )"

    [ -n "$package_name" ] || \
        package_name="com.anhtuan201x.$clean_id"

    # --------------------------------------------------------
    # Xác định kiến trúc binary
    #
    # Không có lệnh lipo trên Linux thì mặc định iphoneos-arm.
    # Nếu binary chứa arm64 thì ghi iphoneos-arm64.
    # --------------------------------------------------------

    architecture="iphoneos-arm"

    executable="$(
        read_plist_value "$INFO_PLIST" "CFBundleExecutable" 2>/dev/null || true
    )"

    if [ -n "$executable" ] &&
       [ -f "$OUT_DIR/Applications/$app_name/$executable" ]; then

        binary_file="$OUT_DIR/Applications/$app_name/$executable"

        if command -v file >/dev/null 2>&1; then
            binary_info="$(file "$binary_file" 2>/dev/null || true)"

            case "$binary_info" in
                *"arm64"*|*"aarch64"*)
                    architecture="iphoneos-arm64"
                    ;;
                *"arm"*)
                    architecture="iphoneos-arm"
                    ;;
            esac
        fi
    fi

    # --------------------------------------------------------
    # DEBIAN/control
    # --------------------------------------------------------

    cat > "$OUT_DIR/DEBIAN/control" <<EOF
Package: $package_name
Name: $display_name
Version: $bundle_version
Architecture: $architecture
Maintainer: $MAINTAINER
Section: Applications
Priority: optional
Description: $display_name packaged for AnhTuan201X Repo.
EOF

    # Không cần chmod toàn bộ app thành 755.
    # Chỉ đảm bảo executable chính có quyền chạy.
    if [ -n "$executable" ] &&
       [ -f "$OUT_DIR/Applications/$app_name/$executable" ]; then
        chmod 0755 \
            "$OUT_DIR/Applications/$app_name/$executable" \
            || true
    fi

    chmod 0644 "$OUT_DIR/DEBIAN/control"

    output_deb="$DEB_DIR/${package_name}_${bundle_version}_${architecture}.deb"

    rm -f "$output_deb"

    if dpkg-deb --build "$OUT_DIR" "$output_deb" >/dev/null; then
        echo "     [OK] $(
            basename "$output_deb"
        )"
        deb_created=$((deb_created + 1))
    else
        echo "     [WARN] Không build được DEB: $filename"
    fi

    rm -rf "$TMP_DIR" "$OUT_DIR"

done

# ============================================================
# 4. TẠO ICON PACKAGE
# ============================================================

echo
echo "[2/6] Tạo Repo Icon package..."

ICON_TMP="$DEB_DIR/.tmp_icons"

rm -rf "$ICON_TMP"

mkdir -p \
    "$ICON_TMP/DEBIAN" \
    "$ICON_TMP/usr/share/cydia/sections"

if [ -f "$REPO_DIR/CydiaIcon.png" ]; then

    cp \
        "$REPO_DIR/CydiaIcon.png" \
        "$ICON_TMP/usr/share/cydia/sections/com.anhtuan201x.repoicons.png"

    cat > "$ICON_TMP/DEBIAN/control" <<EOF
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: all
Maintainer: $MAINTAINER
Section: Themes
Priority: optional
Description: AnhTuan201X Repo icon package.
EOF

    chmod 0644 "$ICON_TMP/DEBIAN/control"

    rm -f "$DEB_DIR/com.anhtuan201x.repoicons_1.0_all.deb"

    dpkg-deb \
        --build \
        "$ICON_TMP" \
        "$DEB_DIR/com.anhtuan201x.repoicons_1.0_all.deb" \
        >/dev/null || true

else

    echo "  [INFO] Không có CydiaIcon.png -> bỏ qua icon package."

fi

rm -rf "$ICON_TMP"

# ============================================================
# 5. TẠO IPA OTA MANIFEST
# ============================================================

echo
echo "[3/6] Tạo OTA manifest cho IPA..."

manifest_count=0

ipa_files=( "$IPA_DIR"/*.ipa )

for ipa in "${ipa_files[@]}"; do

    [ -f "$ipa" ] || continue

    filename="$(basename "$ipa")"
    base="${filename%.ipa}"

    TMP_MANIFEST="$IPA_DIR/.manifest_tmp"

    rm -rf "$TMP_MANIFEST"
    mkdir -p "$TMP_MANIFEST"

    unzip -q "$ipa" -d "$TMP_MANIFEST" || {
        rm -rf "$TMP_MANIFEST"
        continue
    }

    app_folder="$(
        find "$TMP_MANIFEST/Payload" \
            -maxdepth 2 \
            -type d \
            -name "*.app" \
            2>/dev/null |
        head -n 1
    )"

    if [ -z "$app_folder" ]; then
        rm -rf "$TMP_MANIFEST"
        continue
    fi

    info="$app_folder/Info.plist"

    bundle_id=""
    bundle_version=""
    short_version=""
    display_name=""

    if [ -f "$info" ]; then

        bundle_id="$(read_plist_value "$info" "CFBundleIdentifier")"
        bundle_version="$(read_plist_value "$info" "CFBundleVersion")"
        short_version="$(read_plist_value "$info" "CFBundleShortVersionString")"
        display_name="$(read_plist_value "$info" "CFBundleDisplayName")"

        [ -n "$display_name" ] || \
            display_name="$(read_plist_value "$info" "CFBundleName")"
    fi

    [ -n "$bundle_id" ] || \
        bundle_id="com.anhtuan201x.$(
            printf '%s' "$base" |
            tr '[:upper:]' '[:lower:]' |
            sed 's/[^a-z0-9]/./g'
        )"

    [ -n "$bundle_version" ] || \
        bundle_version="$short_version"

    [ -n "$bundle_version" ] || \
        bundle_version="1.0"

    [ -n "$display_name" ] || \
        display_name="$base"

    ipa_url="$REPO_URL/ipas/$filename"

    manifest_file="$MANIFEST_DIR/${base}.plist"

    cat > "$manifest_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>$ipa_url</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>$bundle_id</string>
                <key>bundle-version</key>
                <string>$bundle_version</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>$display_name</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

    manifest_count=$((manifest_count + 1))

    rm -rf "$TMP_MANIFEST"

done

# ============================================================
# 6. TẠO PACKAGES
# ============================================================

echo
echo "[4/6] Tạo Packages..."

rm -f \
    "$REPO_DIR/Packages" \
    "$REPO_DIR/Packages.bz2" \
    "$BINARY_DIR/Packages" \
    "$BINARY_DIR/Packages.bz2"

if ! dpkg-scanpackages \
    -m \
    "$DEB_DIR" \
    /dev/null \
    > "$REPO_DIR/Packages"; then

    echo "[ERROR] dpkg-scanpackages thất bại."
    exit 1
fi

# Đảm bảo Packages dùng LF
sed -i 's/\r$//' "$REPO_DIR/Packages"

# Sửa path do dpkg-scanpackages có thể tạo "debs/package.deb".
# Repo Cydia cần path tương đối từ root repo.
sed -i 's#^Filename: debs/#Filename: debs/#' "$REPO_DIR/Packages"

# Icon repo
if [ -f "$REPO_DIR/CydiaIcon.png" ]; then
    sed -i \
        "s|^Description:.*|&\nIcon: $REPO_URL/CydiaIcon.png|" \
        "$REPO_DIR/Packages"
fi

cp \
    "$REPO_DIR/Packages" \
    "$BINARY_DIR/Packages"

bzip2 -9 -c \
    "$REPO_DIR/Packages" \
    > "$REPO_DIR/Packages.bz2"

cp \
    "$REPO_DIR/Packages.bz2" \
    "$BINARY_DIR/Packages.bz2"

# ============================================================
# 7. TẠO RELEASE
# ============================================================

echo
echo "[5/6] Tạo Release..."

PACKAGES_PATH="$BINARY_DIR/Packages"
PACKAGES_BZ2_PATH="$BINARY_DIR/Packages.bz2"

PACKAGES_MD5="$(md5sum "$PACKAGES_PATH" | awk '{print $1}')"
PACKAGES_SIZE="$(wc -c < "$PACKAGES_PATH")"

PACKAGES_BZ2_MD5="$(md5sum "$PACKAGES_BZ2_PATH" | awk '{print $1}')"
PACKAGES_BZ2_SIZE="$(wc -c < "$PACKAGES_BZ2_PATH")"

cat > "$REPO_DIR/Release" <<EOF
Origin: AnhTuan201X Repo
Label: AnhTuan201X
Suite: stable
Version: 1.0
Codename: stable
Architectures: iphoneos-arm iphoneos-arm64
Components: main
Description: Kho lưu trữ Tweak và Ứng dụng Jailbreak của AnhTuan201X.

MD5Sum:
 $PACKAGES_MD5 $PACKAGES_SIZE main/binary-iphoneos-arm/Packages
 $PACKAGES_BZ2_MD5 $PACKAGES_BZ2_SIZE main/binary-iphoneos-arm/Packages.bz2
EOF

cp \
    "$REPO_DIR/Release" \
    "$DIST_DIR/Release"

# ============================================================
# 8. TẠO INDEX.HTML
# ============================================================

echo
echo "[6/6] Tạo trang chủ..."

count_deb="$(find "$DEB_DIR" -maxdepth 1 -type f -name "*.deb" | wc -l)"
count_ipa="$(find "$IPA_DIR" -maxdepth 1 -type f -name "*.ipa" | wc -l)"

total_packages=$((count_deb + count_ipa))

cat > "$REPO_DIR/index.html" <<EOF
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>AnhTuan201X Repo</title>

<link rel="icon" type="image/png" href="CydiaIcon.png">

<style>

:root {
    --bg: linear-gradient(
        135deg,
        #0b001a 0%,
        #160033 40%,
        #001133 100%
    );

    --card: rgba(255,255,255,.95);
    --text: #1d1d26;
    --sub: #555;
    --border: #eee;
}

@media (prefers-color-scheme: dark) {

    :root {
        --card: rgba(20,16,38,.94);
        --text: #fff;
        --sub: #b0aec2;
        --border: rgba(255,255,255,.1);
    }

}

* {
    box-sizing: border-box;
}

body {

    margin: 0;
    padding: 20px;

    min-height: 100vh;

    display: flex;
    align-items: center;
    justify-content: center;

    font-family:
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;

    background: var(--bg);

}

.container {

    width: 100%;
    max-width: 440px;

    padding: 30px 22px;

    text-align: center;

    border-radius: 22px;

    background: var(--card);

    border: 1px solid var(--border);

    box-shadow:
        0 20px 50px rgba(0,0,0,.45);

}

.logo {

    width: 90px;
    height: 90px;

    border-radius: 22px;

    object-fit: cover;

    margin-bottom: 15px;

}

h1 {

    margin: 0 0 10px;

    font-size: 30px;

    background:
        linear-gradient(45deg,#ff416c,#ff4b2b);

    -webkit-background-clip: text;
    background-clip: text;

    -webkit-text-fill-color: transparent;

}

.description {

    color: var(--text);

    font-size: 15px;

    font-weight: 600;

    line-height: 1.5;

}

.story {

    color: var(--sub);

    font-size: 13px;

    line-height: 1.6;

    text-align: left;

    border-top: 1px solid var(--border);

    padding-top: 15px;

    margin-top: 20px;

}

.stats {

    display: grid;

    grid-template-columns:
        repeat(3,1fr);

    gap: 10px;

    margin: 25px 0;

}

.stat {

    padding: 12px 5px;

    border-radius: 12px;

    border: 1px solid var(--border);

}

.number {

    color: #ff4b2b;

    font-weight: 700;

    font-size: 17px;

}

.label {

    color: #8e8e93;

    font-size: 11px;

    margin-top: 4px;

}

.btn {

    display: block;

    width: 100%;

    padding: 14px 0;

    margin-top: 10px;

    border-radius: 25px;

    color: white;

    text-decoration: none;

    font-weight: 700;

    font-size: 16px;

}

.cydia {

    background:
        linear-gradient(135deg,#4cd964,#28c840);

}

.store {

    background:
        linear-gradient(135deg,#0072ff,#00c6ff);

}

</style>

</head>

<body>

<div class="container">

    <img
        src="CydiaIcon.png"
        class="logo"
        alt="AnhTuan201X Repo"
        onerror="this.style.display='none'"
    >

    <h1>AnhTuan201X Repo</h1>

    <div class="description">
        Kho lưu trữ Tweak và ứng dụng Legacy iOS.
    </div>

    <div class="story">

        <strong>[Tiếng Việt]</strong><br>

        Repo được xây dựng để lưu trữ và bảo tồn
        các tweak, ứng dụng và tài nguyên dành cho
        những thiết bị iOS cũ.

        <br><br>

        <strong>[English]</strong><br>

        A repository dedicated to preserving
        tweaks, applications and resources
        for Legacy iOS devices.

    </div>

    <div class="stats">

        <div class="stat">

            <div class="number">
                $count_deb
            </div>

            <div class="label">
                DEB
            </div>

        </div>

        <div class="stat">

            <div class="number">
                $count_ipa
            </div>

            <div class="label">
                IPA
            </div>

        </div>

        <div class="stat">

            <div
                class="number"
                style="color:#4cd964"
            >
                Online
            </div>

            <div class="label">
                Status
            </div>

        </div>

    </div>

    <a
        href="cydia://url/https://anhtuan201x.github.io/"
        class="btn cydia"
    >
        Add to Cydia
    </a>

    <a
        href="ipas/index.html"
        class="btn store"
    >
        Mở IPA Store
    </a>

</div>

</body>
</html>
EOF

# ============================================================
# 9. TẠO IPA STORE TỰ ĐỘNG
# ============================================================

cat > "$IPA_DIR/index.html" <<EOF
<!DOCTYPE html>
<html lang="vi">

<head>

<meta charset="utf-8">

<meta
    name="viewport"
    content="width=device-width,initial-scale=1"
>

<title>AnhTuan201X IPA Store</title>

<style>

* {
    box-sizing: border-box;
}

body {

    margin: 0;
    padding: 20px;

    min-height: 100vh;

    font-family:
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;

    background:
        linear-gradient(
            135deg,
            #0b001a,
            #160033 40%,
            #001133
        );

}

.store {

    max-width: 520px;

    margin:
        30px auto;

    padding: 25px 15px;

    background:
        rgba(255,255,255,.96);

    border-radius: 22px;

    box-shadow:
        0 20px 50px rgba(0,0,0,.5);

}

@media (prefers-color-scheme: dark) {

    .store {

        background:
            rgba(20,16,38,.95);

    }

    .app {

        background:
            rgba(255,255,255,.05) !important;

        border-color:
            rgba(255,255,255,.1) !important;

    }

    .name {

        color: white !important;

    }

}

h1 {

    text-align: center;

    margin: 0 0 5px;

    font-size: 28px;

    background:
        linear-gradient(
            45deg,
            #ff416c,
            #ff4b2b
        );

    -webkit-background-clip: text;
    background-clip: text;

    -webkit-text-fill-color: transparent;

}

.subtitle {

    text-align: center;

    color: #8e8e93;

    font-size: 13px;

    margin-bottom: 20px;

}

.notice {

    padding: 12px;

    margin-bottom: 20px;

    border-radius: 12px;

    color: #ff4b2b;

    background:
        rgba(255,75,43,.1);

    border:
        1px dashed #ff4b2b;

    font-size: 12px;

    line-height: 1.5;

}

.app {

    display: flex;

    align-items: center;

    justify-content: space-between;

    gap: 10px;

    padding: 12px;

    margin-bottom: 12px;

    border-radius: 15px;

    background: #f8f9fa;

    border: 1px solid #eee;

}

.info {

    min-width: 0;

    flex: 1;

}

.name {

    color: #1d1d26;

    font-size: 14px;

    font-weight: 700;

    word-break: break-word;

}

.file {

    color: #8e8e93;

    font-size: 11px;

    margin-top: 3px;

    word-break: break-all;

}

.buttons {

    display: flex;

    gap: 6px;

    flex-shrink: 0;

}

.btn {

    padding: 8px 10px;

    border-radius: 15px;

    color: white;

    text-decoration: none;

    font-size: 11px;

    font-weight: 700;

    white-space: nowrap;

}

.download {

    background:
        linear-gradient(
            135deg,
            #0072ff,
            #00c6ff
        );

}

.install {

    background:
        linear-gradient(
            135deg,
            #0052d4,
            #4364f7
        );

}

.back {

    display: block;

    text-align: center;

    margin-top: 20px;

    color: #ff4b2b;

    text-decoration: none;

    font-size: 14px;

    font-weight: 600;

}

@media (max-width:420px) {

    .app {

        align-items: flex-start;

    }

    .buttons {

        flex-direction: column;

    }

    .btn {

        text-align: center;

    }

}

</style>

</head>

<body>

<div class="store">

<h1>AnhTuan201X IPA Store</h1>

<div class="subtitle">
    IPA Store cho thiết bị iOS Legacy
</div>

<div class="notice">
    ⚠️ Cài đặt OTA yêu cầu môi trường iOS
    tương thích. Với thiết bị jailbreak,
    có thể sử dụng AppSync Unified hoặc
    phương thức sideload phù hợp.
</div>

EOF

# ============================================================
# 10. THÊM IPA VÀO STORE
# ============================================================

ipa_files=( "$IPA_DIR"/*.ipa )

if [ "${#ipa_files[@]}" -eq 0 ]; then

    cat >> "$IPA_DIR/index.html" <<'EOF'

<div style="
    text-align:center;
    color:#8e8e93;
    padding:25px 5px;
">
    Chưa có file IPA.
</div>

EOF

else

    for ipa in "${ipa_files[@]}"; do

        [ -f "$ipa" ] || continue

        filename="$(basename "$ipa")"
        base="${filename%.ipa}"

        manifest="manifests/${base}.plist"

        # HTML escape đơn giản
        safe_name="$(
            printf '%s' "$base" |
            sed \
                -e 's/&/\&amp;/g' \
                -e 's/</\&lt;/g' \
                -e 's/>/\&gt;/g' \
                -e 's/"/\&quot;/g'
        )"

        cat >> "$IPA_DIR/index.html" <<EOF

<div class="app">

    <div class="info">

        <div class="name">
            $safe_name
        </div>

        <div class="file">
            $filename
        </div>

    </div>

    <div class="buttons">

        <a
            href="$filename"
            class="btn download"
            download
        >
            Tải IPA
        </a>

        <a
            href="itms-services://?action=download-manifest&url=$REPO_URL/ipas/$manifest"
            class="btn install"
        >
            Cài đặt
        </a>

    </div>

</div>

EOF

    done

fi

cat >> "$IPA_DIR/index.html" <<'EOF'

<a href="../index.html" class="back">
    ← Quay lại trang chủ
</a>

</div>

</body>
</html>
EOF

# ============================================================
# 11. DỌN FILE TẠM / CHUẨN HÓA
# ============================================================

rm -rf \
    "$DEB_DIR/.tmp_ipa" \
    "$DEB_DIR/.tmp_out" \
    "$DEB_DIR/.tmp_icons" \
    "$IPA_DIR/.manifest_tmp"

find "$REPO_DIR" \
    -type f \
    \( \
        -name "Packages" \
        -o -name "Release" \
        -o -name "*.plist" \
        -o -name "*.html" \
    \) \
    -exec sed -i 's/\r$//' {} \;

# ============================================================
# 12. SUMMARY
# ============================================================

echo
echo "=========================================="
echo " HOÀN TẤT"
echo "=========================================="
echo
echo "DEB packages : $count_deb"
echo "IPA files    : $count_ipa"
echo "Manifests    : $manifest_count"
echo "DEB mới      : $deb_created"
echo
echo "Repo:"
echo "  $REPO_URL/"
echo
echo "IPA Store:"
echo "  $REPO_URL/ipas/"
echo
echo "Cydia/Sileo/Zebra:"
echo "  $REPO_URL/"
echo
echo "=========================================="
