#!/bin/bash
mkdir -p debs

if [ -f "Release" ]; then sed -i 's/\r$//' Release; fi

dpkg-scanpackages -m debs /dev/null > Packages
sed -i 's/\r$//' Packages

sed -i '/^Filename:/i \Icon: http://anhtuan201x.github.io/icon.png' Packages

bzip2 -fk Packages

sed -i '/MD5Sum:/,$d' Release
echo "MD5Sum:" >> Release
echo " $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages" >> Release
echo " $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2" >> Release
sed -i 's/\r$//' Release
