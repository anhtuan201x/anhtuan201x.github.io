#!/bin/bash
mkdir -p debs
mkdir -p dists/stable/main/binary-iphoneos-arm

if [ -f "Release" ] ; then sed -i 's/\r$//' Release; fi

# ==========================================
# 1. QUÉT VÀ ĐÓNG GÓI FILE IPA THÀNH DEB CHUẨN IPHONEOS-ARM
# ==========================================
for ipa in debs/*.ipa; do
    if [ -f "$ipa" ]; then
        filename=$(basename -- "$ipa")
        clean_name="${filename%.ipa}"
        clean_id=$(echo "$clean_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '.')
        rm -rf debs/tmp_ipa debs/tmp_out
        mkdir -p debs/tmp_ipa debs/tmp_out/DEBIAN debs/tmp_out/Applications
        unzip -q "$ipa" -d debs/tmp_ipa || continue
        app_folder=$(find debs/tmp_ipa/Payload -maxdepth 2 -name "*.app" 2>/dev/null | head -n 1)
        bid="com.anhtuan201x.$clean_id"
        ver="1.0"
        if [ -n "$app_folder" ] && [ -d "$app_folder" ]; then
            cp -r "$app_folder" debs/tmp_out/Applications/
            infoplist="debs/tmp_out/Applications/$(basename "$app_folder")/Info.plist"
            if [ -f "$infoplist" ]; then
                extracted_bid=$(grep -a -A 1 "CFBundleIdentifier" "$infoplist" | grep -a "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | tr -cd '[:alnum:]._-' || true)
                extracted_ver=$(grep -a -A 1 "CFBundleVersion" "$infoplist" | grep -a "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | tr -cd '[:alnum:]._-' || true)
                [ -n "$extracted_bid" ] && bid="$extracted_bid"
                [ -n "$extracted_ver" ] && ver="$extracted_ver"
            fi
            cat <<EOF > debs/tmp_out/DEBIAN/control
Package: $bid
Name: $clean_name
Version: $ver
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Applications
Description: Ứng dụng chuyển đổi tự động sang DEB hệ máy 32-bit cổ.
EOF
            sed -i 's/\r$//' debs/tmp_out/DEBIAN/control
            chmod -R 0755 debs/tmp_out
            chmod 0644 debs/tmp_out/DEBIAN/control
            dpkg-deb -Zgzip --build debs/tmp_out "debs/${clean_id}.deb" || true
        fi
        rm -rf debs/tmp_ipa debs/tmp_out
    fi
done
find debs -maxdepth 1 -type f -name "*.ipa" -delete

# ==========================================
# 2. ĐÓNG GÓI ICON REPO CHUẨN IPHONEOS-ARM
# ==========================================
rm -rf debs/tmp_icons
mkdir -p debs/tmp_icons/DEBIAN debs/tmp_icons/usr/share/cydia/sections
if [ -f "CydiaIcon.png" ]; then cp CydiaIcon.png debs/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png; fi
cat <<EOF > debs/tmp_icons/DEBIAN/control
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Themes
Description: Bộ sưu tập biểu tượng ảnh nhỏ hiển thị cho các gói cài đặt.
EOF
sed -i 's/\r$//' debs/tmp_icons/DEBIAN/control
chmod -R 0755 debs/tmp_icons
chmod 0644 debs/tmp_icons/DEBIAN/control
dpkg-deb -Zgzip --build debs/tmp_icons debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb
rm -rf debs/tmp_icons

# ==========================================
# 3. QUÉT MỤC LỤC PACKAGES GIỮ NGUYÊN IPHONEOS-ARM GỐC
# ==========================================
rm -f Packages Packages.bz2 dists/stable/main/binary-iphoneos-arm/Packages dists/stable/main/binary-iphoneos-arm/Packages.bz2

dpkg-scanpackages -m debs /dev/null > Packages
sed -i 's/\r$//' Packages

if [ -f "CydiaIcon.png" ]; then
    sed -i "s|^Description:.*|&\nIcon: https://github.io|" Packages
fi

cp Packages dists/stable/main/binary-iphoneos-arm/Packages
bzip2 -fk Packages
mv Packages.bz2 dists/stable/main/binary-iphoneos-arm/Packages.bz2
bzip2 -fk Packages

# ==========================================
# 4. TẠO FILE RELEASE KHÓA CHẶT KIẾN TRÚC IPHONEOS-ARM
# ==========================================
cat <<EOF > Release
Origin: AnhTuan201X Repo
Label: AnhTuan201X
Suite: stable
Version: 1.0
Codename: stable
Architectures: iphoneos-arm
Components: main
Description: Kho lưu trữ Tweak và Ứng dụng Jailbreak dành riêng cho thiết bị iOS Legacy 32-bit.
MD5Sum:
 $(md5sum dists/stable/main/binary-iphoneos-arm/Packages | cut -d' ' -f1) $(stat -c%s dists/stable/main/binary-iphoneos-arm/Packages) main/binary-iphoneos-arm/Packages
 $(md5sum dists/stable/main/binary-iphoneos-arm/Packages.bz2 | cut -d' ' -f1) $(stat -c%s dists/stable/main/binary-iphoneos-arm/Packages.bz2) main/binary-iphoneos-arm/Packages.bz2
EOF

sed -i 's/\r$//' Release
cp Release dists/stable/Release
