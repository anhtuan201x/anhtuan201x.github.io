#!/bin/bash

# ============================================================
# AnhTuan201X Repo Sync
# Repository:
# https://github.com/anhtuan201x/anhtuan201x.github.io
#
# IPA input : debs/*.ipa
# DEB output: debs/*.deb
# IPA plist : ipas/*.plist
# ============================================================

set -u

REPO_URL="https://anhtuan201x.github.io"
DEBS_DIR="debs"
IPAS_DIR="ipas"

mkdir -p "$DEBS_DIR"
mkdir -p "$IPAS_DIR"

echo "=========================================="
echo " AnhTuan201X Repo Sync"
echo "=========================================="

# ============================================================
# 1. FIX CRLF
# ============================================================

if [ -f "Release" ]; then
    sed -i 's/\r$//' Release
fi

# ============================================================
# 2. IPA STORE
# ============================================================

cat > "$IPAS_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="utf-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <title>AnhTuan IPA Store</title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            font-family:
                -apple-system,
                BlinkMacSystemFont,
                "Segoe UI",
                sans-serif;

            background:
                linear-gradient(
                    135deg,
                    #0b001a 0%,
                    #160033 40%,
                    #001133 100%
                );

            margin: 0;
            padding: 20px;

            min-height: 100vh;

            display: flex;
            align-items: center;
            justify-content: center;

            color: #fff;
        }

        .store-card {
            max-width: 520px;
            width: 100%;

            background:
                rgba(20,16,38,0.94);

            border:
                1px solid rgba(255,255,255,0.12);

            border-radius: 22px;

            padding: 30px 16px;

            box-shadow:
                0 15px 35px rgba(0,0,0,0.5);

            text-align: center;

            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }

        h1 {
            background:
                linear-gradient(
                    45deg,
                    #ff416c,
                    #ff4b2b
                );

            -webkit-background-clip: text;
            background-clip: text;

            -webkit-text-fill-color: transparent;

            font-size: 29px;

            margin: 0 0 6px;

            font-weight: 700;
        }

        .sub-title {
            color: #b0aec2;

            font-size: 13.5px;

            line-height: 1.5;

            margin: 0 0 18px;
        }

        .notice {
            background:
                rgba(255,75,43,0.12);

            border:
                1px dashed #ff4b2b;

            color: #ff8065;

            border-radius: 13px;

            padding: 13px;

            font-size: 12.5px;

            line-height: 1.55;

            margin-bottom: 20px;

            text-align: left;
        }

        .game-item {
            display: flex;

            align-items: center;
            justify-content: space-between;

            gap: 10px;

            background:
                rgba(255,255,255,0.055);

            border:
                1px solid rgba(255,255,255,0.1);

            border-radius: 16px;

            padding: 12px;

            margin-bottom: 12px;

            text-align: left;
        }

        .game-info {
            display: flex;

            align-items: center;

            gap: 10px;

            min-width: 0;

            flex: 1;
        }

        .game-icon {
            width: 46px;
            height: 46px;

            min-width: 46px;

            border-radius: 12px;

            display: flex;

            align-items: center;
            justify-content: center;

            font-size: 21px;

            box-shadow:
                0 3px 8px rgba(0,0,0,0.2);
        }

        .game-name {
            color: #fff;

            font-size: 14px;

            font-weight: 600;

            word-break: break-word;
        }

        .game-size {
            color: #8e8e93;

            font-size: 11px;

            margin-top: 3px;
        }

        .btn-group {
            display: flex;

            gap: 6px;

            flex-shrink: 0;
        }

        .btn-download,
        .btn-install {
            color: #fff;

            text-decoration: none;

            padding: 8px 11px;

            border-radius: 15px;

            font-size: 12px;

            font-weight: bold;

            white-space: nowrap;
        }

        .btn-download {
            background:
                linear-gradient(
                    135deg,
                    #0072ff,
                    #00c6ff
                );
        }

        .btn-install {
            background:
                linear-gradient(
                    135deg,
                    #0052d4,
                    #4364f7,
                    #6fb1fc
                );
        }

        .btn-back {
            display: inline-block;

            margin-top: 14px;

            color: #ff6b4a;

            text-decoration: none;

            font-size: 14px;

            font-weight: 500;
        }

        @media (max-width: 420px) {

            .game-item {
                align-items: flex-start;
            }

            .btn-group {
                flex-direction: column;
            }

            .btn-download,
            .btn-install {
                text-align: center;
            }
        }

    </style>
</head>

<body>

<div class="store-card">

    <h1>AnhTuan IPA Store</h1>

    <p class="sub-title">
        Kho tải ứng dụng & game IPA dành cho thiết bị iOS Legacy.
    </p>

    <div class="notice">
        ⚠️ <strong>Lưu ý:</strong><br>
        Bạn cần cài đặt sẵn
        <strong>AppSync Unified</strong>
        trên thiết bị trước khi cài IPA.
        Nếu ứng dụng cài xong bị văng, hãy kiểm tra lại
        phiên bản iOS và AppSync.
    </div>

    <!-- CHATGPT -->

    <div class="game-item">

        <div class="game-info">

            <div
                class="game-icon"
                style="background:linear-gradient(135deg,#11998e,#38ef7d);">
                💬
            </div>

            <div>

                <div class="game-name">
                    ChatGPT Legacy
                </div>

                <div class="game-size">
                    Dung lượng: 3.4 MB
                </div>

            </div>

        </div>

        <div class="btn-group">

            <a
                href="http://github.com/bag-xml/ChatGPT-for-Legacy-iOS/releases/download/v1.0.2-release/ChatGPT-v1.0.2-openrouter.ipa"
                class="btn-download">
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=http://bag-xml.com/projects/chatgpt/assets/itml/chatgpt/1.0/app.plist"
                class="btn-install">
                Cài đặt
            </a>

        </div>

    </div>

    <!-- OLDCLASH -->

    <div class="game-item">

        <div class="game-info">

            <div
                class="game-icon"
                style="background:linear-gradient(135deg,#f12711,#f5af19);">
                ⚔️
            </div>

            <div>

                <div class="game-name">
                    OldClash (Clash of Clans)
                </div>

                <div class="game-size">
                    Dung lượng: 87.1 MB
                </div>

            </div>

        </div>

        <div class="btn-group">

            <a
                href="http://oldclash.bag-xml.com/apps/ios/itml/6.253/app.ipa"
                class="btn-download">
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=http://oldclash.bag-xml.com/apps/ios/itml/6.253/app.plist"
                class="btn-install">
                Cài đặt
            </a>

        </div>

    </div>

    <!-- DISCORD -->

    <div class="game-item">

        <div class="game-info">

            <div
                class="game-icon"
                style="background:linear-gradient(135deg,#5865F2,#7289da);">
                💬
            </div>

            <div>

                <div class="game-name">
                    Discord Classic
                </div>

                <div class="game-size">
                    Legacy iOS
                </div>

            </div>

        </div>

        <div class="btn-group">

            <a
                href="#"
                class="btn-download"
                onclick="alert('Chưa có file IPA cho Discord Classic trong repo.');return false;">
                Tải IPA
            </a>

        </div>

    </div>

    <a
        href="../index.html"
        class="btn-back">
        ⬅️ Quay lại Trang chủ
    </a>

</div>

</body>
</html>
EOF

# ============================================================
# 3. IPA -> DEB
#
# Đặt file IPA vào:
#
# debs/
#
# Ví dụ:
# debs/ChatGPT-Legacy.ipa
#
# Script sẽ:
# IPA -> .app -> DEB
# ============================================================

for ipa in "$DEBS_DIR"/*.ipa; do

    [ -f "$ipa" ] || continue

    filename=$(basename "$ipa")
    clean_name="${filename%.ipa}"

    clean_id=$(
        echo "$clean_name" |
        tr '[:upper:]' '[:lower:]' |
        sed 's/[^a-z0-9._-]/./g' |
        sed 's/\.\{2,\}/./g'
    )

    echo
    echo "=========================================="
    echo "Đang xử lý IPA: $filename"
    echo "Package ID   : $clean_id"
    echo "=========================================="

    rm -rf \
        "$DEBS_DIR/tmp_ipa" \
        "$DEBS_DIR/tmp_out"

    mkdir -p \
        "$DEBS_DIR/tmp_ipa" \
        "$DEBS_DIR/tmp_out/DEBIAN" \
        "$DEBS_DIR/tmp_out/Applications"

    # --------------------------------------------------------
    # UNZIP
    # --------------------------------------------------------

    if ! unzip -q "$ipa" -d "$DEBS_DIR/tmp_ipa"; then

        echo "❌ Không thể giải nén: $filename"

        rm -rf \
            "$DEBS_DIR/tmp_ipa" \
            "$DEBS_DIR/tmp_out"

        continue

    fi

    # --------------------------------------------------------
    # FIND .APP
    # --------------------------------------------------------

    app_folder=$(
        find "$DEBS_DIR/tmp_ipa/Payload" \
            -maxdepth 2 \
            -type d \
            -name "*.app" \
            2>/dev/null |
        head -n 1
    )

    if [ -z "$app_folder" ] ||
       [ ! -d "$app_folder" ]; then

        echo "❌ Không tìm thấy Payload/*.app"

        rm -rf \
            "$DEBS_DIR/tmp_ipa" \
            "$DEBS_DIR/tmp_out"

        continue
    fi

    echo "✓ APP: $(basename "$app_folder")"

    # --------------------------------------------------------
    # COPY APP
    # --------------------------------------------------------

    cp -R \
        "$app_folder" \
        "$DEBS_DIR/tmp_out/Applications/"

    app_name=$(basename "$app_folder")

    infoplist="$DEBS_DIR/tmp_out/Applications/$app_name/Info.plist"

    bid="com.anhtuan201x.$clean_id"
    ver="1.0"
    display_name="$clean_name"

    # --------------------------------------------------------
    # ĐỌC INFO.PLIST
    # --------------------------------------------------------

    if [ -f "$infoplist" ]; then

        # Nếu máy có PlistBuddy
        if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then

            extracted_bid=$(
                /usr/libexec/PlistBuddy \
                    -c "Print :CFBundleIdentifier" \
                    "$infoplist" \
                    2>/dev/null || true
            )

            extracted_ver=$(
                /usr/libexec/PlistBuddy \
                    -c "Print :CFBundleVersion" \
                    "$infoplist" \
                    2>/dev/null || true
            )

            extracted_name=$(
                /usr/libexec/PlistBuddy \
                    -c "Print :CFBundleDisplayName" \
                    "$infoplist" \
                    2>/dev/null || true
            )

            if [ -z "$extracted_name" ]; then

                extracted_name=$(
                    /usr/libexec/PlistBuddy \
                        -c "Print :CFBundleName" \
                        "$infoplist" \
                        2>/dev/null || true
                )

            fi

        else

            # Fallback cho XML plist
            extracted_bid=$(
                grep -a -A 1 "CFBundleIdentifier" "$infoplist" |
                grep -a "<string>" |
                sed 's/.*<string>\(.*\)<\/string>.*/\1/' |
                head -n 1
            )

            extracted_ver=$(
                grep -a -A 1 "CFBundleVersion" "$infoplist" |
                grep -a "<string>" |
                sed 's/.*<string>\(.*\)<\/string>.*/\1/' |
                head -n 1
            )

            extracted_name=$(
                grep -a -A 1 "CFBundleDisplayName" "$infoplist" |
                grep -a "<string>" |
                sed 's/.*<string>\(.*\)<\/string>.*/\1/' |
                head -n 1
            )

        fi

        [ -n "${extracted_bid:-}" ] &&
            bid="$extracted_bid"

        [ -n "${extracted_ver:-}" ] &&
            ver="$extracted_ver"

        [ -n "${extracted_name:-}" ] &&
            display_name="$extracted_name"

    fi

    echo "Bundle ID: $bid"
    echo "Version : $ver"
    echo "Name    : $display_name"

    # --------------------------------------------------------
    # CONTROL
    # --------------------------------------------------------

    cat > "$DEBS_DIR/tmp_out/DEBIAN/control" <<EOF
Package: $bid
Name: $clean_id
Version: $ver
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Applications
Description: Legacy iOS application converted from IPA.
EOF

    sed -i 's/\r$//' \
        "$DEBS_DIR/tmp_out/DEBIAN/control"

    chmod 0755 \
        "$DEBS_DIR/tmp_out/DEBIAN"

    chmod 0644 \
        "$DEBS_DIR/tmp_out/DEBIAN/control"

    chmod -R 0755 \
        "$DEBS_DIR/tmp_out/Applications"

    # --------------------------------------------------------
    # BUILD DEB
    # --------------------------------------------------------

    if command -v dpkg-deb >/dev/null 2>&1; then

        if dpkg-deb \
            -Zgzip \
            --build \
            "$DEBS_DIR/tmp_out" \
            "$DEBS_DIR/${clean_id}.deb"; then

            echo "✓ DEB: $DEBS_DIR/${clean_id}.deb"

        else

            echo "❌ Build DEB thất bại."

        fi

    else

        echo "❌ Không tìm thấy dpkg-deb."

    fi

    # --------------------------------------------------------
    # OTA INSTALL PLIST
    # --------------------------------------------------------

    cat > "$IPAS_DIR/${clean_id}.plist" <<EOF
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
                    <string>${REPO_URL}/ipas/${filename}</string>

                </dict>

            </array>

            <key>metadata</key>

            <dict>

                <key>bundle-identifier</key>
                <string>${bid}</string>

                <key>bundle-version</key>
                <string>${ver}</string>

                <key>kind</key>
                <string>software</string>

                <key>title</key>
                <string>${display_name}</string>

            </dict>

        </dict>

    </array>

</dict>

</plist>
EOF

    rm -rf \
        "$DEBS_DIR/tmp_ipa" \
        "$DEBS_DIR/tmp_out"

done

# ============================================================
# 4. XÓA IPA KHÔNG ĐÚNG VỊ TRÍ
# ============================================================

find "$DEBS_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.ipa" \
    -delete

# ============================================================
# 5. REPO ICON
# ============================================================

rm -rf "$DEBS_DIR/tmp_icons"

mkdir -p \
    "$DEBS_DIR/tmp_icons/DEBIAN" \
    "$DEBS_DIR/tmp_icons/usr/share/cydia/sections"

if [ -f "CydiaIcon.png" ]; then

    cp \
        "CydiaIcon.png" \
        "$DEBS_DIR/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png"

fi

cat > "$DEBS_DIR/tmp_icons/DEBIAN/control" <<'EOF'
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Themes
Description: AnhTuan201X Repo Icons.
EOF

chmod 0755 \
    "$DEBS_DIR/tmp_icons/DEBIAN"

chmod 0644 \
    "$DEBS_DIR/tmp_icons/DEBIAN/control"

if command -v dpkg-deb >/dev/null 2>&1; then

    dpkg-deb \
        -Zgzip \
        --build \
        "$DEBS_DIR/tmp_icons" \
        "$DEBS_DIR/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb"

fi

rm -rf "$DEBS_DIR/tmp_icons"

# ============================================================
# 6. PACKAGES
# ============================================================

rm -f \
    Packages \
    Packages.bz2

if command -v dpkg-scanpackages >/dev/null 2>&1; then

    dpkg-scanpackages \
        -m \
        "$DEBS_DIR" \
        /dev/null > Packages

else

    echo "❌ Không tìm thấy dpkg-scanpackages."
    exit 1

fi

sed -i 's/\r$//' Packages

# ------------------------------------------------------------
# Repo Icon
# ------------------------------------------------------------

if [ -f "CydiaIcon.png" ]; then

    sed -i \
        "s|^Description:.*|&\nIcon: ${REPO_URL}/CydiaIcon.png|" \
        Packages

fi

bzip2 -fk Packages

# ============================================================
# 7. RELEASE
# ============================================================

if [ -f "Release" ]; then

    sed -i '/^MD5Sum:/,$d' Release

    cat >> Release <<EOF
MD5Sum:
 $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages
 $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2
EOF

    sed -i 's/\r$//' Release

fi

# ============================================================
# 8. THỐNG KÊ
# ============================================================

deb_count=$(
    find "$DEBS_DIR" \
        -maxdepth 1 \
        -type f \
        -name "*.deb" |
    wc -l
)

plist_count=$(
    find "$IPAS_DIR" \
        -maxdepth 1 \
        -type f \
        -name "*.plist" |
    wc -l
)

echo
echo "=========================================="
echo " SYNC HOÀN TẤT"
echo "=========================================="
echo "DEB     : $deb_count"
echo "PLIST   : $plist_count"
echo "PACKAGES: $([ -f Packages ] && echo YES || echo NO)"
echo "BZIP2   : $([ -f Packages.bz2 ] && echo YES || echo NO)"
echo "REPO    : $REPO_URL"
echo "=========================================="
