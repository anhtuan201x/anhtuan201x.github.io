#!/bin/bash
mkdir -p debs
mkdir -p ipas

if [ -f "Release" ] ; then sed -i 's/\r$//' Release; fi

cat << 'EOF' > ipas/index.html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AnhTuan IPA Store</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: -apple-system, sans-serif; background: linear-gradient(135deg, #0b001a 0%, #160033 40%, #001133 100%); margin: 0; padding: 20px; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        .store-card { max-width: 500px; width: 100%; background: rgba(255,255,255,0.96); border-radius: 20px; padding: 30px 15px; box-shadow: 0 15px 35px rgba(0,0,0,0.5); text-align: center; }
        @media (prefers-color-scheme: dark) {
            .store-card { background: rgba(20,16,38,0.94); border: 1px solid rgba(255,255,255,0.1); }
            .game-name { color: #fff !important; }
            .game-item { background: rgba(255,255,255,0.05) !important; border-color: rgba(255,255,255,0.1) !important; }
        }
        h1 { background: linear-gradient(45deg, #ff416c, #ff4b2b); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; font-size: 28px; margin: 0 0 5px; font-weight: 700; }
        .sub-title { color: #8e8e93; font-size: 13.5px; margin: 0 0 15px; font-weight: 500; line-height: 1.5; }
        .notice { background: rgba(255,75,43,0.1); border: 1px dashed #ff4b2b; color: #ff4b2b; border-radius: 12px; padding: 12px; font-size: 12.5px; font-weight: 600; margin-bottom: 20px; text-align: justify; line-height: 1.5; }
        @media (prefers-color-scheme: dark) { .notice { background: rgba(255,75,43,0.15); color: #ff6b4a; } }
        .game-item { display: flex; align-items: center; justify-content: space-between; gap: 10px; background: #f8f9fa; border: 1px solid #eee; border-radius: 15px; padding: 12px 10px; margin-bottom: 12px; text-align: left; }
        .game-info { display: flex; align-items: center; gap: 10px; min-width: 0; flex: 1; }
        .game-icon { width: 45px; height: 45px; min-width: 45px; border-radius: 11px; display: flex; align-items: center; justify-content: center; font-size: 20px; box-shadow: 0 3px 8px rgba(0,0,0,0.1); }
        .game-name { font-weight: 600; color: #1d1d26; font-size: 14px; word-break: break-word; }
        .game-size { font-size: 11px; color: #8e8e93; margin-top: 2px; }
        .btn-group { display: flex; gap: 6px; flex-shrink: 0; }
        .btn-download, .btn-install { color: #fff; text-decoration: none; padding: 8px 11px; border-radius: 15px; font-size: 12px; font-weight: bold; white-space: nowrap; }
        .btn-download { background: linear-gradient(135deg, #0072ff, #00c6ff); }
        .btn-install { background: linear-gradient(135deg, #4cd964, #28c840); box-shadow: 0 3px 6px rgba(76,217,100,0.2); }
        .btn-back { display: inline-block; margin-top: 15px; color: #ff4b2b; text-decoration: none; font-size: 14px; font-weight: 500; }
        @media (max-width: 420px) { .game-item { align-items: flex-start; } .btn-group { flex-direction: column; } .btn-download, .btn-install { text-align: center; } }
    </style>
</head>
<body>
<div class="store-card">
    <h1>AnhTuan IPA Store</h1>
    <p class="sub-title">Kho tải ứng dụng & game IPA độc quyền dành cho thiết bị iOS Legacy.</p>
    <div class="notice">⚠️ <b>Lưu ý:</b> Bạn phải cài đặt sẵn <b>AppSync Unified</b> trên máy. Nếu chưa có, bạn có thể thêm nguồn của tôi tại địa chỉ <b>http://github.io</b> để tải về cài đặt, tránh ứng dụng cài xong bị văng ra lập tức.</div>
EOF

for ipa in ipas/*.ipa; do
    if [ -f "$ipa" ]; then
        filename=$(basename -- "$ipa")
        clean_name="${filename%.*}"
        
        rm -rf ipas/tmp_ipa ipas/tmp_out
        mkdir -p ipas/tmp_ipa ipas/tmp_out/DEBIAN ipas/tmp_out/Applications
        
        unzip -q "$ipa" -d ipas/tmp_ipa || true
        app_folder=$(find ipas/tmp_ipa/Payload -maxdepth 2 -name "*.app" 2>/dev/null | head -n 1 || echo "")
        
        bid="com.anhtuan201x.$clean_name"
        ver="1.0"
        display_name="$clean_name"
        
        if [ ! -z "$app_folder" ] && [ -d "$app_folder" ]; then
            cp -r "$app_folder" ipas/tmp_out/Applications/
            infoplist="ipas/tmp_out/Applications/$(basename "$app_folder")/Info.plist"
            if [ -f "$infoplist" ]; then
                extracted_bid=$(grep -A 1 "CFBundleIdentifier" "$infoplist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | tr -cd '[:alnum:]._-' || echo "")
                extracted_ver=$(grep -A 1 "CFBundleVersion" "$infoplist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | tr -cd '[:alnum:]._-' || echo "")
                extracted_name=$(grep -A 1 "CFBundleDisplayName" "$infoplist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' || echo "")
                if [ -z "$extracted_name" ]; then extracted_name=$(grep -A 1 "CFBundleName" "$infoplist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' || echo ""); fi
                [ ! -z "$extracted_bid" ] && bid="$extracted_bid"
                [ ! -z "$extracted_ver" ] && ver="$extracted_ver"
                [ ! -z "$extracted_name" ] && display_name="$extracted_name"
                sed -i '/<dict>/a \    <key>UIPrerenderedIcon<\/key>\n    <true\/>' "$infoplist"
            fi
            
            cat <<EOF > ipas/tmp_out/DEBIAN/control
Package: $bid
Name: $clean_name
Version: $ver
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Applications
Description: Ứng dụng biến đổi tự động từ IPA sang DEB bởi AnhTuan201X Bot.
EOF
            sed -i 's/\r$//' ipas/tmp_out/DEBIAN/control
            find ipas/tmp_out -type f -exec sed -i 's/\r$//' {} +
            chmod -R 0755 ipas/tmp_out
            chmod 0644 ipas/tmp_out/DEBIAN/control
            
            if [ ! -f "debs/${clean_name}.deb" ]; then
                dpkg-deb -Zgzip --build ipas/tmp_out "debs/${clean_name}.deb" || true
            fi
        fi
        
        cat << EOF > "ipas/${clean_name}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://apple.com">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<key>software-package</key>
					<url>https://github.io{filename}</url>
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
        cat << EOF >> ipas/index.html
    <div class="game-item">
        <div class="game-info">
            <div class="game-icon" style="background: linear-gradient(135deg, #11998e, #38ef7d);">📦</div>
            <div><div class="game-name">${display_name}</div><div class="game-size">AnhTuan App Store</div></div>
        </div>
        <div class="btn-group">
            <a href="${filename}" class="btn-download" download>Tải IPA</a>
            <a href="itms-services://?action=download-manifest&url=https://github.io{clean_name}.plist" class="btn-install">Cài đặt</a>
        </div>
    </div>
EOF
        rm -rf ipas/tmp_ipa ipas/tmp_out
    fi
done

cat << 'EOF' >> ipas/index.html
    <a href="../index.html" class="btn-back">⬅️ Quay lai Trang chu</a>
</div>
</body>
</html>
EOF

rm -rf debs/tmp_icons
mkdir -p debs/tmp_icons/DEBIAN debs/tmp_icons/usr/share/cydia/sections
if [ -f "CydiaIcon.png" ]; then cp CydiaIcon.png debs/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png; fi
cat << 'EOF' > debs/tmp_icons/DEBIAN/control
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Themes
Description: Bo suu tap bieu tuong logo doc quyen giup hien thi anh nho cho toan bo tweak trong nguon cua Anh Tuan.
EOF
sed -i 's/\r$//' debs/tmp_icons/DEBIAN/control
find debs/tmp_icons -type f -exec sed -i 's/\r$//' {} +
chmod -R 0755 debs/tmp_icons
chmod 0644 debs/tmp_icons/DEBIAN/control
dpkg-deb -Zgzip --build debs/tmp_icons debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb
rm -rf debs/tmp_icons

rm -f Packages Packages.bz2
dpkg-scanpackages -m debs /dev/null > Packages
sed -i 's/\r$//' Packages

sed -i "s|^Description:.*|&\nIcon: https://github.io|" Packages

bzip2 -fk Packages

sed -i '/MD5Sum:/,$d' Release
echo "MD5Sum:" >> Release
echo " $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages" >> Release
echo " $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2" >> Release
sed -i 's/\r$//' Release
