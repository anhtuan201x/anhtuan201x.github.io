#!/bin/bash

mkdir -p debs
mkdir -p ipas

# ==========================================
# CLEAN RELEASE
# ==========================================
if [ -f "Release" ]; then
    sed -i 's/\r$//' Release
fi

# ==========================================
# IPA STORE
# ==========================================
cat << 'EOF' > ipas/index.html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AnhTuan IPA Store</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, sans-serif;
            background: linear-gradient(
                135deg,
                #0b001a 0%,
                #160033 40%,
                #001133 100%
            );
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .store-card {
            max-width: 500px;
            width: 100%;
            background: rgba(255,255,255,0.96);
            border-radius: 20px;
            padding: 30px 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.5);
            text-align: center;
        }

        @media (prefers-color-scheme: dark) {
            .store-card {
                background: rgba(20,16,38,0.94);
                border: 1px solid rgba(255,255,255,0.1);
            }

            .game-name {
                color: #fff !important;
            }

            .game-item {
                background: rgba(255,255,255,0.05) !important;
                border-color: rgba(255,255,255,0.1) !important;
            }
        }

        h1 {
            background: linear-gradient(45deg, #ff416c, #ff4b2b);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 28px;
            margin: 0 0 5px;
            font-weight: 700;
        }

        .sub-title {
            color: #8e8e93;
            font-size: 13.5px;
            margin: 0 0 15px;
            font-weight: 500;
            line-height: 1.5;
        }

        .notice {
            background: rgba(255,75,43,0.1);
            border: 1px dashed #ff4b2b;
            color: #ff4b2b;
            border-radius: 12px;
            padding: 12px;
            font-size: 12.5px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: justify;
            line-height: 1.5;
        }

        .game-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            background: #f8f9fa;
            border: 1px solid #eee;
            border-radius: 15px;
            padding: 12px 10px;
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
            width: 45px;
            height: 45px;
            min-width: 45px;
            border-radius: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.1);
        }

        .game-name {
            font-weight: 600;
            color: #1d1d26;
            font-size: 14px;
            word-break: break-word;
        }

        .game-size {
            font-size: 11px;
            color: #8e8e93;
            margin-top: 2px;
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
            background: linear-gradient(135deg, #0072ff, #00c6ff);
        }

        .btn-install {
            background: linear-gradient(
                135deg,
                #0052d4,
                #4364f7,
                #6fb1fc
            );
            box-shadow: 0 3px 6px rgba(0,114,255,0.2);
        }

        .btn-back {
            display: inline-block;
            margin-top: 15px;
            color: #ff4b2b;
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
        Kho tải ứng dụng & game IPA độc quyền dành cho thiết bị iOS Legacy.
    </p>

    <div class="notice">
        ⚠️ <b>Lưu ý:</b>
        Bạn phải cài đặt sẵn <b>AppSync Unified</b> trên máy.
        Nếu chưa có, bạn có thể thêm nguồn của tôi tại:
        <b>http://anhtuan201x.github.io/</b>
        để tải về cài đặt, tránh ứng dụng cài xong bị văng ra lập tức.
    </div>

    <!-- CHATGPT -->
    <div class="game-item">
        <div class="game-info">
            <div
                class="game-icon"
                style="background: linear-gradient(135deg, #11998e, #38ef7d);"
            >
                💬
            </div>

            <div>
                <div class="game-name">ChatGPT Legacy</div>
                <div class="game-size">Dung lượng: 3.4 MB</div>
            </div>
        </div>

        <div class="btn-group">
            <a
                href="https://github.com/bag-xml/ChatGPT-for-Legacy-iOS/releases/download/v1.0.2-release/ChatGPT-v1.0.2-openrouter.ipa"
                class="btn-download"
                download
            >
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=http://anhtuan201x.github.io/ipas/chatgpt.plist"
                class="btn-install"
            >
                Cài đặt
            </a>
        </div>
    </div>

    <!-- OLDCLASH -->
    <div class="game-item">
        <div class="game-info">
            <div
                class="game-icon"
                style="background: linear-gradient(135deg, #f12711, #f5af19);"
            >
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
                class="btn-download"
                download
            >
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=http://oldclash.bag-xml.com/apps/ios/itml/6.253/app.plist"
                class="btn-install"
            >
                Cài đặt
            </a>
        </div>
    </div>

    <a href="../index.html" class="btn-back">
        ⬅️ Quay lại Trang chủ
    </a>

</div>

</body>
</html>
EOF

# ==========================================
# IPA -> DEB
# CHỈ QUÉT debs/*.ipa
# KHÔNG QUÉT ipas/
# ==========================================

for ipa in debs/*.ipa; do

    if [ -f "$ipa" ]; then

        filename=$(basename -- "$ipa")
        clean_name="${filename%.ipa}"
        clean_id=$(echo "$clean_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')

        echo "=========================================="
        echo "Đang xử lý: $filename"
        echo "=========================================="

        rm -rf debs/tmp_ipa
        rm -rf debs/tmp_out

        mkdir -p debs/tmp_ipa
        mkdir -p debs/tmp_out/DEBIAN
        mkdir -p debs/tmp_out/Applications

        unzip -q "$ipa" -d debs/tmp_ipa || {
            echo "Lỗi giải nén: $filename"
            continue
        }

        app_folder=$(
            find debs/tmp_ipa/Payload \
                -maxdepth 2 \
                -name "*.app" \
                2>/dev/null |
            head -n 1
        )

        if [ -z "$app_folder" ] || [ ! -d "$app_folder" ]; then
            echo "Không tìm thấy .app trong $filename"
            continue
        fi

        bid="com.anhtuan201x.$clean_id"
        ver="1.0"
        display_name="$clean_name"

        cp -r "$app_folder" debs/tmp_out/Applications/

        infoplist="debs/tmp_out/Applications/$(basename "$app_folder")/Info.plist"

        # ==========================================
        # ĐỌC INFO.PLIST
        # ==========================================

        if [ -f "$infoplist" ]; then

            extracted_bid=$(
                grep -a -A 1 "CFBundleIdentifier" "$infoplist" |
                grep -a "<string>" |
                sed 's/.*<string>\(.*\)<\/string>.*/\1/' |
                tr -cd '[:alnum:]._-' || true
            )

            extracted_ver=$(
                grep -a -A 1 "CFBundleVersion" "$infoplist" |
                grep -a "<string>" |
                sed 's/.*<string>\(.*\)<\/string>.*/\1/' |
                tr -cd '[:alnum:]._-' || true
            )

            extracted_name=$(
                grep -a -A 1 "CFBundleDisplayName" "$infoplist" |
                grep -a "<string>" |
                sed 's/.*<string>\(.*\)<\/string>.*/\1/' || true
            )

            if [ -z "$extracted_name" ]; then

                extracted_name=$(
                    grep -a -A 1 "CFBundleName" "$infoplist" |
                    grep -a "<string>" |
                    sed 's/.*<string>\(.*\)<\/string>.*/\1/' || true
                )

            fi

            [ -n "$extracted_bid" ] && bid="$extracted_bid"
            [ -n "$extracted_ver" ] && ver="$extracted_ver"
            [ -n "$extracted_name" ] && display_name="$extracted_name"

        fi

        # ==========================================
        # CONTROL DEB
        # ==========================================

        cat << EOF > debs/tmp_out/DEBIAN/control
Package: $bid
Name: $clean_id
Version: $ver
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Applications
Description: Ung dung chuyen doi tu IPA sang DEB.
EOF

        sed -i 's/\r$//' debs/tmp_out/DEBIAN/control

        chmod -R 0755 debs/tmp_out
        chmod 0644 debs/tmp_out/DEBIAN/control

        # ==========================================
        # BUILD DEB
        # ==========================================

        dpkg-deb -Zgzip \
            --build \
            debs/tmp_out \
            "debs/${clean_id}.deb" || true

        # ==========================================
        # TẠO PLIST
        # DTD APPLE CHUẨN
        # ==========================================

        cat << EOF > "ipas/${clean_id}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
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
                    <string>https://anhtuan201x.github.io/ipas/${filename}</string>
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

        rm -rf debs/tmp_ipa
        rm -rf debs/tmp_out

    fi

done

# ==========================================
# KHÔNG XÓA IPA
# IPA NẰM TRONG debs/
# ==========================================

# ==========================================
# REPO ICON
# ==========================================

rm -rf debs/tmp_icons

mkdir -p debs/tmp_icons/DEBIAN
mkdir -p debs/tmp_icons/usr/share/cydia/sections

if [ -f "CydiaIcon.png" ]; then

    cp \
        CydiaIcon.png \
        debs/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png

fi

cat << EOF > debs/tmp_icons/DEBIAN/control
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Themes
Description: Bo suu tap bieu tuong logo cho repo AnhTuan201X.
EOF

sed -i 's/\r$//' debs/tmp_icons/DEBIAN/control

chmod -R 0755 debs/tmp_icons
chmod 0644 debs/tmp_icons/DEBIAN/control

dpkg-deb \
    -Zgzip \
    --build \
    debs/tmp_icons \
    debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb

rm -rf debs/tmp_icons

# ==========================================
# PACKAGES
# ==========================================

rm -f Packages
rm -f Packages.bz2

dpkg-scanpackages -m debs /dev/null > Packages

sed -i 's/\r$//' Packages

if [ -f "CydiaIcon.png" ]; then

    sed -i \
        "s|^Description:.*|&\nIcon: https://anhtuan201x.github.io/CydiaIcon.png|" \
        Packages

fi

bzip2 -fk Packages

# ==========================================
# RELEASE MD5
# ==========================================

if [ -f "Release" ]; then

    sed -i '/MD5Sum:/,$d' Release

    echo "MD5Sum:" >> Release

    echo " $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages" \
        >> Release

    echo " $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2" \
        >> Release

    sed -i 's/\r$//' Release

fi

echo "=========================================="
echo "SYNC HOÀN TẤT"
echo "IPA INPUT : debs/*.ipa"
echo "DEB OUTPUT: debs/*.deb"
echo "PLIST     : ipas/*.plist"
echo "=========================================="
