#!/bin/bash
mkdir -p debs
dpkg-scanpackages -m debs /dev/null > Packages
sed -i 's/\r$//' Packages
bzip2 -fk Packages
