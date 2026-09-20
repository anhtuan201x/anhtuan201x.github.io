#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# CONFIG
# ============================================================

REPO_URL="https://anhtuan201x.github.io"

REPO_NAME="AnhTuan201X IPA Store"

DEB_ARCH="iphoneos-arm"

MAINTAINER_NAME="AnhTuan201X"
MAINTAINER_EMAIL="anhtuan201x@github.io"

CYDIA_PACKAGES="Packages.bz2"

# ============================================================
# CREATE DIRECTORIES
# ============================================================

mkdir -p "ipas"
mkdir -p "debs"

echo "Created:"
echo "  ipas/"
echo "  debs/"

# ============================================================
# CHECK COMMANDS
# ============================================================

REQUIRED_COMMANDS=(
    bash
    unzip
    dpkg-deb
    dpkg-scanpackages
    python3
    bzip2
    md5sum
    stat
    find
    sed
    awk
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do

    if ! command -v "$cmd" >/dev/null 2>&1; then

        echo "ERROR: Missing command: $cmd"

        exit 1

    fi

done

# ============================================================
# CREATE IPA INDEX IMMEDIATELY
# ============================================================

rm -f "ipas/index.html"

cat > "ipas/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

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
            #160033,
            #001133
        );

    display: flex;

    justify-content: center;

    align-items: center;
}

.store {

    width: 100%;

    max-width: 520px;

    padding: 30px 16px;

    border-radius: 22px;

    background:
        rgba(255,255,255,.96);

    box-shadow:
        0 20px 50px rgba(0,0,0,.5);
}

h1 {

    margin: 0;

    text-align: center;

    font-size: 29px;

    font-weight: 800;

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

    margin:
        8px 0 20px;
}

.app {

    display: flex;

    align-items: center;

    justify-content: space-between;

    gap: 10px;

    padding: 12px;

    margin-bottom: 12px;

    border-radius: 16px;

    background: #f7f8fa;

    border: 1px solid #e8e8ec;
}

.info {

    min-width: 0;

    flex: 1;

    display: flex;

    align-items: center;

    gap: 10px;
}

.icon {

    width: 46px;

    height: 46px;

    min-width: 46px;

    border-radius: 12px;

    display: flex;

    align-items: center;

    justify-content: center;

    background:
        linear-gradient(
            135deg,
            #11998e,
            #38ef7d
        );

    font-size: 21px;
}

.name {

    font-size: 14px;

    font-weight: 700;

    word-break: break-word;
}

.version {

    margin-top: 3px;

    color: #8e8e93;

    font-size: 11px;
}

.buttons {

    display: flex;

    gap: 6px;
}

.btn {

    color: #fff;

    text-decoration: none;

    padding: 8px 11px;

    border-radius: 14px;

    font-size: 12px;

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
            #4cd964,
            #28c840
        );
}

.back {

    display: block;

    margin-top: 18px;

    text-align: center;

    color: #ff4b2b;

    text-decoration: none;

    font-size: 14px;

    font-weight: 600;
}

@media (prefers-color-scheme: dark) {

    .store {

        background:
            rgba(20,16,38,.96);
    }

    .app {

        background:
            rgba(255,255,255,.06);

        border-color:
            rgba(255,255,255,.1);
    }

    .name {

        color: #fff;
    }
}

@media(max-width:430px) {

    .app {

        align-items: flex-start;
    }

    .buttons {

        flex-direction: column;
    }
}

</style>

</head>

<body>

<div class="store">

<h1>AnhTuan201X IPA Store</h1>

<div class="subtitle">
IPA applications for iOS.
</div>

EOF

echo "Created: ipas/index.html"

# ============================================================
# FIND ALL IPA FILES
# ============================================================

mapfile -d '' IPA_FILES < <(
    find "ipas" \
        -type f \
        -iname "*.ipa" \
        -print0
)

echo
echo "IPA files found: ${#IPA_FILES[@]}"
echo

# ============================================================
# PROCESS EVERY IPA
# ============================================================

for IPA in "${IPA_FILES[@]}"; do

    [ -f "$IPA" ] || continue

    FILENAME="$(basename "$IPA")"

    ORIGINAL_NAME="${FILENAME%.ipa}"

    echo "============================================================"
    echo "Processing: $IPA"
    echo "============================================================"

    # --------------------------------------------------------
    # SAFE NAME
    # --------------------------------------------------------

    PACKAGE_NAME="$(
        printf '%s' "$ORIGINAL_NAME" |
        tr '[:space:]' '-' |
        tr -cd '[:alnum:]_.+-'
    )"

    if [ -z "$PACKAGE_NAME" ]; then

        PACKAGE_NAME="application"

    fi

    # --------------------------------------------------------
    # TEMP DIRECTORY
    # --------------------------------------------------------

    TMP_DIR="$(
        mktemp -d
    )"

    trap 'rm -rf "$TMP_DIR"' EXIT

    mkdir -p \
        "$TMP_DIR/unzip" \
        "$TMP_DIR/package/DEBIAN" \
        "$TMP_DIR/package/Applications"

    # --------------------------------------------------------
    # EXTRACT IPA
    # --------------------------------------------------------

    if ! unzip -q "$IPA" -d "$TMP_DIR/unzip"; then

        echo "ERROR: Failed to extract:"
        echo "$IPA"

        rm -rf "$TMP_DIR"

        trap - EXIT

        continue

    fi

    # --------------------------------------------------------
    # FIND .APP
    # --------------------------------------------------------

    APP_PATH=""

    while IFS= read -r -d '' APP; do

        APP_PATH="$APP"

        break

    done < <(
        find "$TMP_DIR/unzip" \
            -type d \
            -name "*.app" \
            -print0
    )

    if [ -z "$APP_PATH" ]; then

        echo "ERROR: No .app bundle found:"
        echo "$IPA"

        rm -rf "$TMP_DIR"

        trap - EXIT

        continue

    fi

    APP_NAME="$(basename "$APP_PATH")"

    echo "APP: $APP_NAME"

    # --------------------------------------------------------
    # COPY APP
    # --------------------------------------------------------

    cp -R \
        "$APP_PATH" \
        "$TMP_DIR/package/Applications/"

    INFO_PLIST="$TMP_DIR/package/Applications/$APP_NAME/Info.plist"

    # --------------------------------------------------------
    # DEFAULT INFO
    # --------------------------------------------------------

    BUNDLE_ID="com.anhtuan201x.$PACKAGE_NAME"

    VERSION="1.0"

    DISPLAY_NAME="$ORIGINAL_NAME"

    # --------------------------------------------------------
    # READ INFO.PLIST USING PYTHON
    # --------------------------------------------------------

    if [ -f "$INFO_PLIST" ]; then

        VALUE="$(
            python3 - "$INFO_PLIST" <<'PY'
import sys
import plistlib

try:

    with open(sys.argv[1], "rb") as f:
        data = plistlib.load(f)

    print(data.get("CFBundleIdentifier", ""))

except Exception:

    print("")
PY
        )"

        if [ -n "$VALUE" ]; then
            BUNDLE_ID="$VALUE"
        fi

        VALUE="$(
            python3 - "$INFO_PLIST" <<'PY'
import sys
import plistlib

try:

    with open(sys.argv[1], "rb") as f:
        data = plistlib.load(f)

    value = data.get("CFBundleShortVersionString")

    if not value:
        value = data.get("CFBundleVersion")

    print(value or "")

except Exception:

    print("")
PY
        )"

        if [ -n "$VALUE" ]; then
            VERSION="$VALUE"
        fi

        VALUE="$(
            python3 - "$INFO_PLIST" <<'PY'
import sys
import plistlib

try:

    with open(sys.argv[1], "rb") as f:
        data = plistlib.load(f)

    value = data.get("CFBundleDisplayName")

    if not value:
        value = data.get("CFBundleName")

    print(value or "")

except Exception:

    print("")
PY
        )"

        if [ -n "$VALUE" ]; then
            DISPLAY_NAME="$VALUE"
        fi

    fi

    # --------------------------------------------------------
    # CLEAN METADATA
    # --------------------------------------------------------

    BUNDLE_ID="$(
        printf '%s' "$BUNDLE_ID" |
        tr '[:upper:]' '[:lower:]' |
        tr -cd '[:alnum:]._-'
    )"

    [ -n "$BUNDLE_ID" ] ||
        BUNDLE_ID="com.anhtuan201x.$PACKAGE_NAME"

    VERSION="$(
        printf '%s' "$VERSION" |
        tr -cd '[:alnum:].+_-'
    )"

    [ -n "$VERSION" ] ||
        VERSION="1.0"

    # --------------------------------------------------------
    # CREATE DEBIAN CONTROL
    # --------------------------------------------------------

    cat > "$TMP_DIR/package/DEBIAN/control" <<EOF
Package: $BUNDLE_ID
Name: $DISPLAY_NAME
Version: $VERSION
Architecture: $DEB_ARCH
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Section: Applications
Description: $DISPLAY_NAME
 IPA application package.
EOF

    chmod 0755 \
        "$TMP_DIR/package/DEBIAN"

    chmod 0644 \
        "$TMP_DIR/package/DEBIAN/control"

    # --------------------------------------------------------
    # PERMISSIONS
    # --------------------------------------------------------

    chmod -R u+rwX,go+rX \
        "$TMP_DIR/package/Applications"

    EXECUTABLE="$TMP_DIR/package/Applications/$APP_NAME/$APP_NAME"

    if [ -f "$EXECUTABLE" ]; then

        chmod 0755 "$EXECUTABLE"

    fi

    # --------------------------------------------------------
    # CREATE DEB
    # --------------------------------------------------------

    DEB_FILE="debs/${PACKAGE_NAME}.deb"

    rm -f "$DEB_FILE"

    if ! dpkg-deb \
        -Zgzip \
        --build \
        "$TMP_DIR/package" \
        "$DEB_FILE" \
        >/dev/null; then

        echo "ERROR: Failed to create DEB:"
        echo "$IPA"

        rm -rf "$TMP_DIR"

        trap - EXIT

        continue

    fi

    echo "Created DEB:"
    echo "$DEB_FILE"

    # --------------------------------------------------------
    # CREATE PLIST
    # --------------------------------------------------------

    PLIST_NAME="${PACKAGE_NAME}.plist"

    PLIST_FILE="ipas/${PLIST_NAME}"

    RELATIVE_IPA="${IPA#ipas/}"

    IPA_URL="$(
        python3 - "$RELATIVE_IPA" <<'PY'
import sys
from urllib.parse import quote

print(
    quote(
        sys.argv[1],
        safe="/._-"
    )
)
PY
    )"

    XML_BUNDLE_ID="$(
        python3 - "$BUNDLE_ID" <<'PY'
import sys
import html

print(html.escape(sys.argv[1], quote=True))
PY
    )"

    XML_VERSION="$(
        python3 - "$VERSION" <<'PY'
import sys
import html

print(html.escape(sys.argv[1], quote=True))
PY
    )"

    XML_NAME="$(
        python3 - "$DISPLAY_NAME" <<'PY'
import sys
import html

print(html.escape(sys.argv[1], quote=True))
PY
    )"

    cat > "$PLIST_FILE" <<EOF
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

                    <string>${REPO_URL}/ipas/${IPA_URL}</string>

                </dict>

            </array>

            <key>metadata</key>

            <dict>

                <key>bundle-identifier</key>

                <string>${XML_BUNDLE_ID}</string>

                <key>bundle-version</key>

                <string>${XML_VERSION}</string>

                <key>kind</key>

                <string>software</string>

                <key>title</key>

                <string>${XML_NAME}</string>

            </dict>

        </dict>

    </array>

</dict>

</plist>
EOF

    # --------------------------------------------------------
    # CREATE INSTALL LINK
    # --------------------------------------------------------

    MANIFEST_URL="${REPO_URL}/ipas/${PLIST_NAME}"

    ENCODED_MANIFEST="$(
        python3 - "$MANIFEST_URL" <<'PY'
import sys
from urllib.parse import quote

print(
    quote(
        sys.argv[1],
        safe=""
    )
)
PY
    )"

    HTML_NAME="$(
        python3 - "$DISPLAY_NAME" <<'PY'
import sys
import html

print(
    html.escape(
        sys.argv[1],
        quote=True
    )
)
PY
    )"

    HTML_IPA="$(
        python3 - "$RELATIVE_IPA" <<'PY'
import sys
import html

print(
    html.escape(
        sys.argv[1],
        quote=True
    )
)
PY
    )"

    # --------------------------------------------------------
    # ADD APP TO INDEX
    # --------------------------------------------------------

    cat >> "ipas/index.html" <<EOF

<div class="app">

    <div class="info">

        <div class="icon">
            📦
        </div>

        <div>

            <div class="name">
                ${HTML_NAME}
            </div>

            <div class="version">
                Version ${VERSION}
            </div>

        </div>

    </div>

    <div class="buttons">

        <a
            class="btn download"
            href="${HTML_IPA}"
            download
        >
            Download
        </a>

        <a
            class="btn install"
            href="itms-services://?action=download-manifest&amp;url=${ENCODED_MANIFEST}"
        >
            Install
        </a>

    </div>

</div>

EOF

    echo "Created PLIST:"
    echo "$PLIST_FILE"

    # --------------------------------------------------------
    # CLEAN TEMP
    # --------------------------------------------------------

    rm -rf "$TMP_DIR"

    trap - EXIT

done

# ============================================================
# CLOSE INDEX.HTML
# ============================================================

cat >> "ipas/index.html" <<'EOF'

<a
    class="back"
    href="../index.html"
>
    Back to Home
</a>

</div>

</body>

</html>
EOF

echo
echo "Created: ipas/index.html"

# ============================================================
# CREATE REPOSITORY ICON DEB
# ============================================================

ICON_TMP="$(mktemp -d)"

mkdir -p \
    "$ICON_TMP/DEBIAN" \
    "$ICON_TMP/usr/share/cydia/sections"

if [ -f "CydiaIcon.png" ]; then

    cp \
        "CydiaIcon.png" \
        "$ICON_TMP/usr/share/cydia/sections/com.anhtuan201x.repoicons.png"

fi

cat > "$ICON_TMP/DEBIAN/control" <<EOF
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: $DEB_ARCH
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Section: Themes
Description: AnhTuan201X Repository Icons
 Repository icon package.
EOF

chmod 0755 "$ICON_TMP/DEBIAN"
chmod 0644 "$ICON_TMP/DEBIAN/control"

dpkg-deb \
    -Zgzip \
    --build \
    "$ICON_TMP" \
    "debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb" \
    >/dev/null

rm -rf "$ICON_TMP"

echo "Created repository icon DEB."

# ============================================================
# CREATE PACKAGES
# ============================================================

rm -f Packages
rm -f Packages.bz2

dpkg-scanpackages \
    -m \
    debs \
    /dev/null \
    > Packages

sed -i 's/\r$//' Packages

# ============================================================
# CREATE PACKAGES.BZ2
# ============================================================

bzip2 \
    -9 \
    -fk \
    Packages

# ============================================================
# CREATE RELEASE IF NEEDED
# ============================================================

if [ ! -f Release ]; then

cat > Release <<EOF
Origin: AnhTuan201X
Label: AnhTuan201X
Suite: stable
Version: 1.0
Codename: stable
Architectures: iphoneos-arm
Components: main
Description: AnhTuan201X Cydia Repository
EOF

fi

# ============================================================
# UPDATE RELEASE
# ============================================================

sed -i \
    '/^MD5Sum:/,$d' \
    Release \
    2>/dev/null || true

cat >> Release <<EOF

MD5Sum:
 $(md5sum Packages | awk '{print $1}') $(stat -c%s Packages) Packages
 $(md5sum Packages.bz2 | awk '{print $1}') $(stat -c%s Packages.bz2) Packages.bz2
EOF

sed -i 's/\r$//' Release

# ============================================================
# VALIDATE
# ============================================================

test -f "ipas/index.html"
test -f "Packages"
test -f "Packages.bz2"
test -f "Release"

echo
echo "============================================================"
echo "BUILD SUCCESSFUL"
echo "============================================================"

echo
echo "Directories:"
echo "  ipas/"
echo "  debs/"

echo
echo "IPA Store:"
echo "  ${REPO_URL}/ipas/"

echo
echo "Cydia Packages:"
echo "  Packages.bz2"

echo
echo "Repository:"
echo "  ${REPO_URL}"

echo
echo "IPA files:"
find "ipas" \
    -type f \
    -iname "*.ipa" \
    -print

echo
echo "DEB files:"
find "debs" \
    -maxdepth 1 \
    -type f \
    -name "*.deb" \
    -print

echo
echo "Generated manifests:"
find "ipas" \
    -maxdepth 1 \
    -type f \
    -name "*.plist" \
    -print

echo
echo "============================================================"
echo "DONE"
echo "============================================================"
