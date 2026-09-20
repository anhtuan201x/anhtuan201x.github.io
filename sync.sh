#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# AnhTuan201X Repository Builder
# GitHub Actions / Ubuntu compatible
# ============================================================

REPO_URL="https://anhtuan201x.github.io"

REPO_NAME="AnhTuan IPA Store"

MAINTAINER_NAME="AnhTuan201X"
MAINTAINER_EMAIL="anhtuan201x@github.io"

DEB_ARCH="iphoneos-arm"

CYDIA_PACKAGES="Packages.bz2"

# ============================================================
# CHECK DEPENDENCIES
# ============================================================

REQUIRED_COMMANDS=(
    bash
    unzip
    dpkg-deb
    dpkg-scanpackages
    md5sum
    stat
    sed
    awk
    find
    python3
    bzip2
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Missing command: $cmd"
        exit 1
    fi
done

# ============================================================
# DIRECTORIES
# ============================================================

mkdir -p ipas
mkdir -p debs

# ============================================================
# CLEAN GENERATED FILES
# ============================================================

rm -f Packages
rm -f Packages.bz2

# Only delete generated manifests in the root of ipas.
# IPA files and subdirectories are preserved.
find ipas \
    -maxdepth 1 \
    -type f \
    -name "*.plist" \
    -delete

# ============================================================
# PLIST READER
# ============================================================

read_plist_value() {

    local plist="$1"
    local key="$2"

    python3 - "$plist" "$key" <<'PY'
import sys
import plistlib

plist_path = sys.argv[1]
key = sys.argv[2]

try:
    with open(plist_path, "rb") as f:
        data = plistlib.load(f)

    value = data.get(key, "")

    if value is None:
        value = ""

    if isinstance(value, bytes):
        value = value.decode("utf-8", errors="replace")

    print(str(value))

except Exception:
    print("")
PY

}

# ============================================================
# URL ENCODER
# ============================================================

url_encode() {

    python3 - "$1" <<'PY'
import sys
from urllib.parse import quote

print(quote(sys.argv[1], safe="/._-"))
PY

}

# ============================================================
# XML ESCAPER
# ============================================================

xml_escape() {

    python3 - "$1" <<'PY'
import sys
import html

print(html.escape(sys.argv[1], quote=True))
PY

}

# ============================================================
# HTML ESCAPER
# ============================================================

html_escape() {

    python3 - "$1" <<'PY'
import sys
import html

print(html.escape(sys.argv[1], quote=True))
PY

}

# ============================================================
# CREATE RELEASE IF MISSING
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

sed -i 's/\r$//' Release

# ============================================================
# CREATE IPA STORE
# ============================================================

cat > ipas/index.html <<EOF
<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="utf-8">

<meta
    name="viewport"
    content="width=device-width, initial-scale=1"
>

<title>${REPO_NAME}</title>

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
            #160033 45%,
            #001133 100%
        );

    margin: 0;

    padding: 20px;

    min-height: 100vh;

    display: flex;

    align-items: center;

    justify-content: center;
}

.store-card {

    width: 100%;

    max-width: 520px;

    background:
        rgba(255,255,255,0.96);

    border-radius: 22px;

    padding: 30px 16px;

    box-shadow:
        0 20px 50px rgba(0,0,0,0.5);

    text-align: center;
}

@media (prefers-color-scheme: dark) {

    .store-card {

        background:
            rgba(20,16,38,0.95);

        border:
            1px solid rgba(255,255,255,0.1);
    }

    .game-name {
        color: #fff !important;
    }

    .game-item {

        background:
            rgba(255,255,255,0.05) !important;

        border-color:
            rgba(255,255,255,0.1) !important;
    }
}

h1 {

    margin: 0 0 6px;

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

.sub-title {

    color: #8e8e93;

    font-size: 13.5px;

    margin: 0 0 18px;

    line-height: 1.5;
}

.notice {

    padding: 12px;

    margin-bottom: 20px;

    border-radius: 13px;

    border:
        1px dashed #ff4b2b;

    background:
        rgba(255,75,43,0.08);

    color: #ff4b2b;

    font-size: 12px;

    line-height: 1.5;

    text-align: left;
}

.game-item {

    display: flex;

    align-items: center;

    justify-content: space-between;

    gap: 10px;

    padding: 12px;

    margin-bottom: 12px;

    border-radius: 16px;

    background: #f7f8fa;

    border: 1px solid #e8e8ec;

    text-align: left;
}

.game-info {

    min-width: 0;

    flex: 1;

    display: flex;

    align-items: center;

    gap: 10px;
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
        0 4px 10px rgba(0,0,0,0.12);
}

.game-name {

    color: #1d1d26;

    font-size: 14px;

    font-weight: 650;

    word-break: break-word;
}

.game-version {

    color: #8e8e93;

    font-size: 11px;

    margin-top: 3px;
}

.btn-group {

    display: flex;

    gap: 6px;

    flex-shrink: 0;
}

.btn {

    display: inline-flex;

    align-items: center;

    justify-content: center;

    padding: 8px 11px;

    border-radius: 15px;

    color: white;

    text-decoration: none;

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

    box-shadow:
        0 3px 8px rgba(76,217,100,0.25);
}

.back {

    display: inline-block;

    margin-top: 15px;

    color: #ff4b2b;

    text-decoration: none;

    font-size: 14px;

    font-weight: 600;
}

@media (max-width: 430px) {

    .game-item {
        align-items: flex-start;
    }

    .btn-group {
        flex-direction: column;
    }

    .btn {
        min-width: 68px;
    }
}

</style>

</head>

<body>

<div class="store-card">

<h1>${REPO_NAME}</h1>

<p class="sub-title">
IPA applications for legacy iOS devices.
</p>

<div class="notice">
Installation requires a compatible IPA installation environment.
</div>

EOF

# ============================================================
# FIND ALL IPA FILES RECURSIVELY
# ============================================================

mapfile -d '' IPA_FILES < <(
    find ipas \
        -type f \
        -iname "*.ipa" \
        -print0
)

echo
echo "Found ${#IPA_FILES[@]} IPA file(s)."
echo

# ============================================================
# PROCESS IPA FILES
# ============================================================

for IPA in "${IPA_FILES[@]}"; do

    [ -f "$IPA" ] || continue

    FILENAME="$(basename "$IPA")"

    ORIGINAL_NAME="${FILENAME%.*}"

    RELATIVE_IPA="${IPA#ipas/}"

    echo "============================================================"
    echo "Processing: $IPA"
    echo "============================================================"

    # --------------------------------------------------------
    # SAFE PACKAGE NAME
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
    # PREVENT DUPLICATE PACKAGE NAMES
    # --------------------------------------------------------

    BASE_PACKAGE_NAME="$PACKAGE_NAME"

    COUNTER=1

    while [ -f "debs/${PACKAGE_NAME}.deb" ]; do

        PACKAGE_NAME="${BASE_PACKAGE_NAME}-${COUNTER}"

        COUNTER=$((COUNTER + 1))

    done

    # --------------------------------------------------------
    # TEMP DIRECTORY
    # --------------------------------------------------------

    TMP_DIR="$(
        mktemp -d "${TMPDIR:-/tmp}/anhtuan-build.XXXXXX"
    )"

    cleanup() {
        rm -rf "$TMP_DIR"
    }

    trap cleanup EXIT

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

        cleanup
        trap - EXIT

        continue

    fi

    # --------------------------------------------------------
    # FIND APP BUNDLE
    # --------------------------------------------------------

    APP_PATH=""

    while IFS= read -r -d '' APP; do

        APP_PATH="$APP"

        break

    done < <(
        find \
            "$TMP_DIR/unzip/Payload" \
            -maxdepth 1 \
            -type d \
            -name "*.app" \
            -print0 \
            2>/dev/null
    )

    # --------------------------------------------------------
    # FALLBACK SEARCH
    # --------------------------------------------------------

    if [ -z "$APP_PATH" ]; then

        while IFS= read -r -d '' APP; do

            APP_PATH="$APP"

            break

        done < <(
            find \
                "$TMP_DIR/unzip" \
                -type d \
                -name "*.app" \
                -print0 \
                2>/dev/null
        )

    fi

    if [ -z "$APP_PATH" ]; then

        echo "ERROR: No .app bundle found:"
        echo "$IPA"

        cleanup
        trap - EXIT

        continue

    fi

    APP_NAME="$(basename "$APP_PATH")"

    echo "Application: $APP_NAME"

    # --------------------------------------------------------
    # COPY APP
    # --------------------------------------------------------

    cp -R \
        "$APP_PATH" \
        "$TMP_DIR/package/Applications/"

    INFO_PLIST="$TMP_DIR/package/Applications/$APP_NAME/Info.plist"

    # --------------------------------------------------------
    # DEFAULT METADATA
    # --------------------------------------------------------

    BUNDLE_ID="com.anhtuan201x.$PACKAGE_NAME"

    VERSION="1.0"

    DISPLAY_NAME="$ORIGINAL_NAME"

    # --------------------------------------------------------
    # READ INFO.PLIST
    # --------------------------------------------------------

    if [ -f "$INFO_PLIST" ]; then

        VALUE="$(
            read_plist_value \
                "$INFO_PLIST" \
                "CFBundleIdentifier"
        )"

        if [ -n "$VALUE" ]; then
            BUNDLE_ID="$VALUE"
        fi

        VALUE="$(
            read_plist_value \
                "$INFO_PLIST" \
                "CFBundleShortVersionString"
        )"

        if [ -z "$VALUE" ]; then

            VALUE="$(
                read_plist_value \
                    "$INFO_PLIST" \
                    "CFBundleVersion"
            )"

        fi

        if [ -n "$VALUE" ]; then
            VERSION="$VALUE"
        fi

        VALUE="$(
            read_plist_value \
                "$INFO_PLIST" \
                "CFBundleDisplayName"
        )"

        if [ -z "$VALUE" ]; then

            VALUE="$(
                read_plist_value \
                    "$INFO_PLIST" \
                    "CFBundleName"
            )"

        fi

        if [ -n "$VALUE" ]; then
            DISPLAY_NAME="$VALUE"
        fi

    fi

    # --------------------------------------------------------
    # SANITIZE BUNDLE ID
    # --------------------------------------------------------

    BUNDLE_ID="$(
        printf '%s' "$BUNDLE_ID" |
        tr '[:upper:]' '[:lower:]' |
        tr -cd '[:alnum:]._-'
    )"

    if [ -z "$BUNDLE_ID" ]; then
        BUNDLE_ID="com.anhtuan201x.$PACKAGE_NAME"
    fi

    # --------------------------------------------------------
    # SANITIZE VERSION
    # --------------------------------------------------------

    VERSION="$(
        printf '%s' "$VERSION" |
        tr -cd '[:alnum:].+_-'
    )"

    if [ -z "$VERSION" ]; then
        VERSION="1.0"
    fi

    # --------------------------------------------------------
    # CONTROL FILE
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
    # APPLICATION PERMISSIONS
    # --------------------------------------------------------

    chmod -R u+rwX,go+rX \
        "$TMP_DIR/package/Applications"

    EXECUTABLE="$TMP_DIR/package/Applications/$APP_NAME/$APP_NAME"

    if [ -f "$EXECUTABLE" ]; then

        chmod 0755 "$EXECUTABLE"

    fi

    # --------------------------------------------------------
    # BUILD DEB
    # --------------------------------------------------------

    DEB_FILE="debs/${PACKAGE_NAME}.deb"

    if ! dpkg-deb \
        -Zgzip \
        --build \
        "$TMP_DIR/package" \
        "$DEB_FILE" \
        >/dev/null; then

        echo "ERROR: Failed to build DEB:"
        echo "$IPA"

        cleanup
        trap - EXIT

        continue

    fi

    echo "Created: $DEB_FILE"

    # --------------------------------------------------------
    # CREATE MANIFEST NAME
    # --------------------------------------------------------

    PLIST_NAME="${PACKAGE_NAME}.plist"

    # --------------------------------------------------------
    # URL PATH
    # --------------------------------------------------------

    IPA_URL_NAME="$(
        url_encode "$RELATIVE_IPA"
    )"

    PLIST_URL_NAME="$(
        url_encode "$PLIST_NAME"
    )"

    # --------------------------------------------------------
    # XML VALUES
    # --------------------------------------------------------

    XML_BUNDLE_ID="$(
        xml_escape "$BUNDLE_ID"
    )"

    XML_VERSION="$(
        xml_escape "$VERSION"
    )"

    XML_DISPLAY_NAME="$(
        xml_escape "$DISPLAY_NAME"
    )"

    # --------------------------------------------------------
    # OTA MANIFEST
    # --------------------------------------------------------

    cat > "ipas/$PLIST_NAME" <<EOF
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

                    <string>${REPO_URL}/ipas/${IPA_URL_NAME}</string>

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

                <string>${XML_DISPLAY_NAME}</string>

            </dict>

        </dict>

    </array>

</dict>

</plist>
EOF

    # --------------------------------------------------------
    # INSTALL URL
    # --------------------------------------------------------

    MANIFEST_URL="${REPO_URL}/ipas/${PLIST_URL_NAME}"

    ENCODED_MANIFEST_URL="$(
        python3 - "$MANIFEST_URL" <<'PY'
import sys
from urllib.parse import quote

print(quote(sys.argv[1], safe=""))
PY
    )"

    HTML_NAME="$(
        html_escape "$DISPLAY_NAME"
    )"

    HTML_IPA="$(
        html_escape "$IPA_URL_NAME"
    )"

    # --------------------------------------------------------
    # ADD APP TO INDEX
    # --------------------------------------------------------

    cat >> ipas/index.html <<EOF

<div class="game-item">

    <div class="game-info">

        <div
            class="game-icon"
            style="
                background:
                linear-gradient(
                    135deg,
                    #11998e,
                    #38ef7d
                );
            "
        >
            📦
        </div>

        <div>

            <div class="game-name">
                ${HTML_NAME}
            </div>

            <div class="game-version">
                Version ${VERSION}
            </div>

        </div>

    </div>

    <div class="btn-group">

        <a
            class="btn download"
            href="${HTML_IPA}"
            download
        >
            Download
        </a>

        <a
            class="btn install"
            href="itms-services://?action=download-manifest&amp;url=${ENCODED_MANIFEST_URL}"
        >
            Install
        </a>

    </div>

</div>

EOF

    echo "Bundle ID: $BUNDLE_ID"
    echo "Version  : $VERSION"
    echo "Name     : $DISPLAY_NAME"
    echo "Manifest : ipas/$PLIST_NAME"
    echo

    cleanup
    trap - EXIT

done

# ============================================================
# CLOSE HTML
# ============================================================

cat >> ipas/index.html <<'EOF'

<a
    href="../index.html"
    class="back"
>
    Back to Home
</a>

</div>

</body>

</html>
EOF

# ============================================================
# REPOSITORY ICON PACKAGE
# ============================================================

rm -rf debs/tmp_icons

mkdir -p \
    debs/tmp_icons/DEBIAN \
    debs/tmp_icons/usr/share/cydia/sections

if [ -f CydiaIcon.png ]; then

    cp \
        CydiaIcon.png \
        debs/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png

fi

cat > debs/tmp_icons/DEBIAN/control <<EOF
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: $DEB_ARCH
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Section: Themes
Description: AnhTuan201X Repository Icons
 Repository icon package.
EOF

chmod 0755 \
    debs/tmp_icons/DEBIAN

chmod 0644 \
    debs/tmp_icons/DEBIAN/control

dpkg-deb \
    -Zgzip \
    --build \
    debs/tmp_icons \
    debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb \
    >/dev/null

rm -rf debs/tmp_icons

# ============================================================
# GENERATE PACKAGES
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
# ADD REPOSITORY ICON
# ============================================================

if [ -f CydiaIcon.png ]; then

    awk \
        -v icon="$REPO_URL/CydiaIcon.png" \
        '
        BEGIN {
            RS=""
            ORS="\n\n"
        }

        {
            if ($0 !~ /(^|\n)Icon:/) {
                print $0 "\nIcon: " icon
            }
            else {
                print
            }
        }
        ' \
        Packages \
        > Packages.tmp

    mv Packages.tmp Packages

fi

# ============================================================
# CREATE PACKAGES.BZ2
# ============================================================

bzip2 \
    -9 \
    -fk \
    Packages

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

if [ ! -s Packages ]; then

    echo "ERROR: Packages is empty."

    exit 1

fi

if [ ! -s Packages.bz2 ]; then

    echo "ERROR: Packages.bz2 was not created."

    exit 1

fi

if [ ! -s Release ]; then

    echo "ERROR: Release is empty."

    exit 1

fi

# ============================================================
# SUMMARY
# ============================================================

echo
echo "============================================================"
echo "BUILD SUCCESSFUL"
echo "============================================================"

echo
echo "Repository:"
echo "$REPO_URL"

echo
echo "CYDIA_PACKAGES:"
echo "$CYDIA_PACKAGES"

echo
echo "Packages:"
echo "$REPO_URL/Packages"

echo
echo "Packages.bz2:"
echo "$REPO_URL/Packages.bz2"

echo
echo "Release:"
echo "$REPO_URL/Release"

echo
echo "IPA Store:"
echo "$REPO_URL/ipas/"

echo
echo "IPA files found:"
find ipas \
    -type f \
    -iname "*.ipa" \
    -print \
    2>/dev/null || true

echo
echo "DEB files:"
find debs \
    -maxdepth 1 \
    -type f \
    -name "*.deb" \
    -print \
    2>/dev/null || true

echo
echo "Manifest files:"
find ipas \
    -maxdepth 1 \
    -type f \
    -name "*.plist" \
    -print \
    2>/dev/null || true

echo
echo "============================================================"
echo "DONE"
echo "============================================================"
