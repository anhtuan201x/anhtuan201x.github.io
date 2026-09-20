#!/bin/bash
mkdir -p debs
mkdir -p ipas

if [ -f "Release" ]; then sed -i 's/\r$//' Release; fi

if [ -d "debs/Payload" ]; then
    cd debs
    zip -qyX -r cargame.ipa Payload
    cd ..
    mv debs/cargame.ipa ipas/cargame.ipa
    rm -rf debs/Payload
fi

for ipa in debs/*.ipa; do
    if [ -f "$ipa" ]; then
        filename=$(basename -- "$ipa")
        mv "$ipa" ipas/
    fi
done

rm -rf debs/tmp_icons
mkdir -p debs/tmp_icons/DEBIAN
mkdir -p debs/tmp_icons/usr/share/cydia/sections
if [ -f "CydiaIcon.png" ]; then
    cp CydiaIcon.png debs/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png
fi
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
dpkg-deb --option Uniform-Compression=no -Zgzip --format=2.0 --build debs/tmp_icons debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb
rm -rf debs/tmp_icons

rm -f Packages Packages.bz2
dpkg-scanpackages -m debs /dev/null > Packages
sed -i 's/\r$//' Packages
sed -i '/^Description:/i \Icon: http://anhtuan201x.github.io/CydiaIcon.png' Packages
bzip2 -fk Packages

sed -i '/MD5Sum:/,$d' Release
echo "MD5Sum:" >> Release
echo " $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages" >> Release
echo " $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2" >> Release
sed -i 's/\r$//' Release
