#!/bin/bash
mkdir -p debs
mkdir -p ipas

if [ -f "Release" ] ; then sed -i 's/\r$//' Release; fi

for ipa in debs/*.ipa; do
    if [ -f "$ipa" ]; then
        filename=$(basename -- "$ipa")
        appname="${filename%.*}"
        clean_name=$(echo "$appname" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
        rm -rf debs/tmp_ipa debs/tmp_out
        mkdir -p debs/tmp_ipa debs/tmp_out/DEBIAN debs/tmp_out/Applications
        unzip -q "$ipa" -d debs/tmp_ipa
        app_folder=$(find debs/tmp_ipa/Payload -maxdepth 2 -name "*.app" | head -n 1)
        if [ -d "$app_folder" ]; then
            cp -r "$app_folder" debs/tmp_out/Applications/
            infoplist="debs/tmp_out/Applications/$(basename "$app_folder")/Info.plist"
            bid="com.anhtuan201x.$clean_name"
            ver="1.0"
            if [ -f "$infoplist" ]; then
                extracted_bid=$(grep -A 1 "CFBundleIdentifier" "$infoplist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | tr -cd '[:alnum:]._-')
                extracted_ver=$(grep -A 1 "CFBundleVersion" "$infoplist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | tr -cd '[:alnum:]._-')
                if [ ! -z "$extracted_bid" ]; then bid="$extracted_bid"; fi
                if [ ! -z "$extracted_ver" ]; then ver="$extracted_ver"; fi
                sed -i '/<dict>/a \    <key>UIPrerenderedIcon<\/key>\n    <true\/>' "$infoplist"
            fi
            cat << 'EOF' > debs/tmp_out/DEBIAN/control
Package: com.anhtuan201x.placeholder
Name: Placeholder
Version: 1.0
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Applications
Description: Cydia Application
EOF
            sed -i "s/^Package:.*/Package: $bid/" debs/tmp_out/DEBIAN/control
            sed -i "s/^Name:.*/Name: $clean_name/" debs/tmp_out/DEBIAN/control
            sed -i "s/^Version:.*/Version: $ver/" debs/tmp_out/DEBIAN/control
            sed -i "s/^Description:.*/Description: Ung dung duoc bien doi tu dong tu file IPA sang DEB boi AnhTuan201X Bot./" debs/tmp_out/DEBIAN/control
            sed -i 's/\r$//' debs/tmp_out/DEBIAN/control
            find debs/tmp_out -type f -exec sed -i 's/\r$//' {} +
            chmod -R 0755 debs/tmp_out
            chmod 0644 debs/tmp_out/DEBIAN/control
            dpkg-deb -Zgzip --build debs/tmp_out "debs/${clean_name}.deb"
        fi
        mv "$ipa" ipas/
        rm -rf debs/tmp_ipa debs/tmp_out
    fi
done

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
sed -i '/^Description:/i \Icon: https:\/\/anhtuan201x.github.io\/CydiaIcon.png' Packages
bzip2 -fk Packages

sed -i '/MD5Sum:/,$d' Release
echo "MD5Sum:" >> Release
echo " $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages" >> Release
echo " $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2" >> Release
sed -i 's/\r$//' Release
