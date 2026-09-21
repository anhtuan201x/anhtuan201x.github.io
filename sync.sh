#!/bin/bash

set -u

# ==========================================
# AnhTuan201X Repo - sync.sh
# ==========================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR" || exit 1

mkdir -p debs ipas

# Chuẩn hóa line ending
for file in Release Packages Packages.bz2; do
    if [ -f "$file" ]; then
        sed -i 's/\r$//' "$file"
    fi
done

echo "=========================================="
echo " AnhTuan201X Repo Sync"
echo "=========================================="

# ==========================================
# 1. ĐẾM PACKAGE
# ==========================================

count_deb=$(find debs -maxdepth 1 -type f -name "*.deb" | wc -l)
count_ipa=$(find ipas -maxdepth 1 -type f -name "*.ipa" | wc -l)
total_packages=$((count_deb + count_ipa))

if [ "$total_packages" -eq 0 ]; then
    total_packages=24
fi

echo "[INFO] DEB : $count_deb"
echo "[INFO] IPA : $count_ipa"

# ==========================================
# 2. TẠO INDEX.HTML
# ==========================================

cat > index.html <<EOF
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>AnhTuan Repo</title>
    <link rel="icon" type="image/png" href="CydiaIcon.png">

    <style>
        :root {
            --bg-gradient: linear-gradient(135deg, #0b001a 0%, #160033 40%, #001133 100%);
            --card-bg: rgba(255,255,255,0.95);
            --text-main: #1d1d26;
            --text-sub: #444;
            --border: #eee;
            --card-sub: #f8f9fa;
        }

        @media (prefers-color-scheme: dark) {
            :root {
                --bg-gradient: linear-gradient(135deg, #020005 0%, #090014 50%, #00051a 100%);
                --card-bg: rgba(20,16,38,0.92);
                --text-main: #fff;
                --text-sub: #b0aec2;
                --border: rgba(255,255,255,0.1);
                --card-sub: rgba(255,255,255,0.05);
            }
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: var(--bg-gradient);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        #galaxyCanvas {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            pointer-events: none;
        }

        .container {
            max-width: 440px;
            width: 100%;
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 35px 25px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.5);
            text-align: center;
            position: relative;
            z-index: 2;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }

        .logo {
            width: 90px;
            height: 90px;
            border-radius: 22px;
            margin-bottom: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        h1 {
            background: linear-gradient(45deg,#ff416c,#ff4b2b);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 30px;
            margin: 0 0 10px;
            font-weight: 700;
        }

        .old-description {
            color: var(--text-main);
            font-size: 15px;
            font-weight: 600;
            margin: 0 0 20px;
        }

        .story-subtitle {
            color: var(--text-sub);
            font-size: 13.5px;
            line-height: 1.6;
            margin: 0 0 25px;
            text-align: justify;
            border-top: 1px solid var(--border);
            padding-top: 15px;
            max-height: 220px;
            overflow-y: auto;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3,1fr);
            gap: 10px;
            margin-bottom: 25px;
        }

        .stat-card {
            background: var(--card-sub);
            border-radius: 10px;
            padding: 10px 5px;
            border: 1px solid var(--border);
        }

        .stat-num {
            font-weight: bold;
            color: #ff4b2b;
            font-size: 16px;
        }

        .stat-label {
            font-size: 11px;
            color: #8e8e93;
            margin-top: 3px;
        }

        .btn-add,
        .btn-store {
            display: block;
            width: 100%;
            font-weight: bold;
            text-decoration: none;
            padding: 14px 0;
            border-radius: 25px;
            font-size: 16px;
            transition: transform .2s;
            text-align: center;
            margin-bottom: 10px;
        }

        .btn-add {
            background: linear-gradient(135deg,#4cd964,#28c840);
            color: #fff;
            box-shadow: 0 4px 10px rgba(76,217,100,.3);
        }

        .btn-store {
            background: linear-gradient(135deg,#0072ff,#00c6ff);
            color: #fff;
            box-shadow: 0 4px 10px rgba(0,114,255,.3);
        }

        .btn-add:hover,
        .btn-store:hover {
            transform: scale(.95);
        }

        .music-btn {
            position: absolute;
            top: 15px;
            right: 15px;
            background: var(--card-sub);
            border: 1px solid var(--border);
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 12px;
            cursor: pointer;
            color: var(--text-main);
            z-index: 10;
            font-weight: bold;
        }

        .music-menu {
            display: none;
            position: absolute;
            top: 55px;
            right: 15px;
            width: 240px;
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 15px;
            padding: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,.3);
            text-align: left;
            z-index: 100;
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
        }

        .music-menu-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 5px;
        }

        .music-menu-title {
            font-size: 13px;
            font-weight: bold;
            color: var(--text-main);
        }

        .music-close-btn {
            background: none;
            border: none;
            font-size: 16px;
            cursor: pointer;
            color: #ff4b2b;
            font-weight: bold;
        }

        .music-item {
            width: 100%;
            background: var(--card-sub);
            border: 1px solid var(--border);
            padding: 8px 10px;
            margin-bottom: 6px;
            border-radius: 8px;
            font-size: 12px;
            cursor: pointer;
            text-align: left;
            color: var(--text-main);
            font-weight: 500;
            display: block;
        }

        .music-item.active,
        .music-item:hover {
            background: linear-gradient(135deg,#4cd964,#28c840);
            color: #fff;
            border-color: transparent;
        }
    </style>
</head>

<body>

<canvas id="galaxyCanvas"></canvas>

<div class="container">

    <button class="music-btn" id="musicMenuToggle" type="button">
        🎵 BGM: List
    </button>

    <div class="music-menu" id="musicMenu">
        <div class="music-menu-header">
            <span class="music-menu-title">Danh Sách Nhạc BGM</span>
            <button class="music-close-btn" id="musicMenuClose" type="button">✕</button>
        </div>

        <button class="music-item" onclick="playSong(0,this)">
            ▶ SoundHelix Song 1
        </button>

        <button class="music-item" onclick="playSong(1,this)">
            ▶ GIAN_DANG_IU_HONG
        </button>
    </div>

    <img
        src="CydiaIcon.png"
        class="logo"
        alt="Logo"
        onerror="this.style.display='none';"
    >

    <h1>AnhTuan Repo</h1>

    <p class="old-description">
        Kho luu tru Tweak va Ung dung Legacy danh rieng cho iOS 6.
    </p>

    <div class="story-subtitle">
        <strong>[Tieng Viet]</strong><br>
        Trong nam 2026, kho luu tru nay duoc kien tao boi Anh Tuan
        voi niem dam me sau sac doi voi the gioi iOS Legacy va cong dong
        jailbreak. Day la noi luu tru cac tweak, ung dung va tai nguyen
        danh cho cac thiet bi iOS cu.
        <br><br>

        <strong>[English]</strong><br>
        In 2026, this legacy repository was created by Anh Tuan
        with a passion for Legacy iOS and the jailbreak community.
        It provides a place to preserve tweaks, applications and
        resources for older iOS devices.
    </div>

    <div class="stats-grid">

        <div class="stat-card">
            <div class="stat-num" id="pkgCount">
                ${total_packages}
            </div>
            <div class="stat-label">Packages</div>
        </div>

        <div class="stat-card">
            <div class="stat-num">999+</div>
            <div class="stat-label">Downloads</div>
        </div>

        <div class="stat-card">
            <div class="stat-num" style="color:#4cd964;">
                Online
            </div>
            <div class="stat-label">Server Status</div>
        </div>

    </div>

    <a href="cydia://url/https://anhtuan201x.github.io/" class="btn-add">
        Add to Cydia
    </a>

    <a href="ipas/index.html" class="btn-store">
        Mở IPA Store
    </a>

</div>

<audio id="bgm" loop preload="auto"></audio>

<script>
const canvas = document.getElementById("galaxyCanvas");
const ctx = canvas.getContext("2d");

let stars = [];

const mouse = {
    x: null,
    y: null,
    radius: 100
};

function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

window.addEventListener("resize", resize);
resize();

window.addEventListener("mousemove", function(e) {
    mouse.x = e.clientX;
    mouse.y = e.clientY;
});

window.addEventListener("mouseout", function() {
    mouse.x = null;
    mouse.y = null;
});

class Star {

    constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;

        this.vx = (Math.random() - 0.5) * 0.8;
        this.vy = (Math.random() - 0.5) * 0.8;

        this.radius = Math.random() * 2;
        this.alpha = Math.random();
        this.alphaSpeed = Math.random() * 0.02 + 0.01;
    }

    update() {

        this.x += this.vx;
        this.y += this.vy;

        if (this.x < 0 || this.x > canvas.width) {
            this.vx *= -1;
        }

        if (this.y < 0 || this.y > canvas.height) {
            this.vy *= -1;
        }

        this.alpha += this.alphaSpeed;

        if (this.alpha <= 0 || this.alpha >= 1) {
            this.alphaSpeed *= -1;
        }

        if (mouse.x !== null && mouse.y !== null) {

            const dx = this.x - mouse.x;
            const dy = this.y - mouse.y;
            const dist = Math.sqrt(dx * dx + dy * dy);

            if (dist > 0 && dist < mouse.radius) {

                const force =
                    ((mouse.radius - dist) / mouse.radius) * 3;

                this.x += (dx / dist) * force;
                this.y += (dy / dist) * force;
            }
        }
    }

    draw() {

        ctx.beginPath();

        ctx.arc(
            this.x,
            this.y,
            this.radius,
            0,
            Math.PI * 2
        );

        ctx.fillStyle =
            "rgba(255,255,255," +
            Math.abs(this.alpha) +
            ")";

        ctx.fill();
    }
}

for (let i = 0; i < 100; i++) {
    stars.push(new Star());
}

function animate() {

    ctx.clearRect(
        0,
        0,
        canvas.width,
        canvas.height
    );

    stars.forEach(function(star) {
        star.update();
        star.draw();
    });

    requestAnimationFrame(animate);
}

animate();


// ===============================
// MUSIC
// ===============================

const bgm = document.getElementById("bgm");
const musicMenu = document.getElementById("musicMenu");
const musicMenuToggle =
    document.getElementById("musicMenuToggle");
const musicMenuClose =
    document.getElementById("musicMenuClose");

const playlist = [
    "music/song1.mp3",
    "music/gian-dang-iu-hong.mp3"
];

let currentTrack = -1;

musicMenuToggle.addEventListener("click", function() {

    musicMenu.style.display =
        musicMenu.style.display === "block"
            ? "none"
            : "block";
});

musicMenuClose.addEventListener("click", function() {
    musicMenu.style.display = "none";
});

function playSong(index, element) {

    document
        .querySelectorAll(".music-item")
        .forEach(function(item) {
            item.classList.remove("active");
        });

    if (currentTrack === index && !bgm.paused) {

        bgm.pause();

        musicMenuToggle.innerText =
            "🎵 BGM: Paused";

        element.classList.remove("active");

        return;
    }

    if (currentTrack !== index) {

        bgm.src = playlist[index];
        currentTrack = index;
    }

    bgm.play().catch(function(err) {
        console.log("Audio error:", err);
    });

    element.classList.add("active");

    musicMenuToggle.innerText =
        "🎵 BGM: Playing";
}
</script>

</body>
</html>
EOF

# ==========================================
# 3. TẠO IPA STORE
# ==========================================

cat > ipas/index.html <<'EOF'
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <title>AnhTuan IPA Store</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
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
            background: rgba(255,255,255,.96);
            border-radius: 20px;
            padding: 30px 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,.5);
            text-align: center;
        }

        h1 {
            background: linear-gradient(45deg,#ff416c,#ff4b2b);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 28px;
            margin: 0 0 5px;
        }

        .sub-title {
            color: #8e8e93;
            font-size: 13.5px;
            margin: 0 0 15px;
            line-height: 1.5;
        }

        .notice {
            background: rgba(255,75,43,.1);
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
            background: linear-gradient(135deg,#0072ff,#00c6ff);
        }

        .btn-install {
            background: linear-gradient(
                135deg,
                #0052d4,
                #4364f7,
                #6fb1fc
            );
        }

        .btn-back {
            display: inline-block;
            margin-top: 15px;
            color: #ff4b2b;
            text-decoration: none;
            font-size: 14px;
        }

        @media (prefers-color-scheme: dark) {

            .store-card {
                background: rgba(20,16,38,.94);
            }

            .game-item {
                background: rgba(255,255,255,.05);
                border-color: rgba(255,255,255,.1);
            }

            .game-name {
                color: #fff;
            }

            .notice {
                background: rgba(255,75,43,.15);
            }
        }

        @media (max-width:420px) {

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
        Kho tải ứng dụng &amp; game IPA dành cho thiết bị iOS Legacy.
    </p>

    <div class="notice">
        ⚠️ Lưu ý: Thiết bị cần được cài đặt AppSync Unified
        hoặc môi trường tương thích để cài IPA.
    </div>

    <div class="game-item">

        <div class="game-info">

            <div class="game-icon">📦</div>

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
                href="ChatGPT-Legacy.ipa"
                class="btn-download"
                download
            >
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=https://anhtuan201x.github.io/ipas/ChatGPT-Legacy.plist"
                class="btn-install"
            >
                Cài đặt
            </a>

        </div>

    </div>


    <div class="game-item">

        <div class="game-info">

            <div class="game-icon">⚔️</div>

            <div>
                <div class="game-name">
                    OldClash
                </div>

                <div class="game-size">
                    Dung lượng: 87.1 MB
                </div>
            </div>

        </div>

        <div class="btn-group">

            <a
                href="OldClash.ipa"
                class="btn-download"
                download
            >
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=https://anhtuan201x.github.io/ipas/OldClash.plist"
                class="btn-install"
            >
                Cài đặt
            </a>

        </div>

    </div>


    <div class="game-item">

        <div class="game-info">

            <div class="game-icon">💬</div>

            <div>
                <div class="game-name">
                    Discord Classic
                </div>

                <div class="game-size">
                    Dung lượng: 11.1 MB
                </div>
            </div>

        </div>

        <div class="btn-group">

            <a
                href="Discord-Classic.ipa"
                class="btn-download"
                download
            >
                Tải IPA
            </a>

            <a
                href="itms-services://?action=download-manifest&url=https://anhtuan201x.github.io/ipas/Discord-Classic.plist"
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
# 4. IPA -> DEB
# ==========================================

shopt -s nullglob

for ipa in ipas/*.ipa; do

    [ -f "$ipa" ] || continue

    filename="$(basename "$ipa")"
    clean_name="${filename%.ipa}"

    clean_id="$(
        printf '%s' "$clean_name" |
        tr '[:upper:]' '[:lower:]' |
        sed 's/[^a-z0-9._-]/./g' |
        sed 's/^\.*//;s/\.*$//'
    )"

    [ -n "$clean_id" ] || clean_id="package"

    echo "[INFO] Converting IPA: $filename"

    rm -rf debs/tmp_ipa debs/tmp_out

    mkdir -p \
        debs/tmp_ipa \
        debs/tmp_out/DEBIAN \
        debs/tmp_out/Applications

    if ! unzip -q "$ipa" -d debs/tmp_ipa; then
        echo "[WARN] Không thể giải nén $ipa"
        rm -rf debs/tmp_ipa debs/tmp_out
        continue
    fi

    app_folder="$(
        find debs/tmp_ipa/Payload \
            -maxdepth 2 \
            -type d \
            -name "*.app" \
            2>/dev/null |
        head -n 1
    )"

    bid="com.anhtuan201x.$clean_id"
    ver="1.0"
    display_name="$clean_name"

    if [ -n "$app_folder" ] && [ -d "$app_folder" ]; then

        cp -R "$app_folder" debs/tmp_out/Applications/

        app_name="$(basename "$app_folder")"
        infoplist="debs/tmp_out/Applications/$app_name/Info.plist"

        if [ -f "$infoplist" ] && command -v plutil >/dev/null 2>&1; then

            extracted_bid="$(
                plutil -extract CFBundleIdentifier raw \
                "$infoplist" 2>/dev/null || true
            )"

            extracted_ver="$(
                plutil -extract CFBundleShortVersionString raw \
                "$infoplist" 2>/dev/null || true
            )"

            if [ -z "$extracted_ver" ]; then
                extracted_ver="$(
                    plutil -extract CFBundleVersion raw \
                    "$infoplist" 2>/dev/null || true
                )"
            fi

            extracted_name="$(
                plutil -extract CFBundleDisplayName raw \
                "$infoplist" 2>/dev/null || true
            )"

            if [ -z "$extracted_name" ]; then
                extracted_name="$(
                    plutil -extract CFBundleName raw \
                    "$infoplist" 2>/dev/null || true
                )"
            fi

            [ -n "$extracted_bid" ] &&
                bid="$extracted_bid"

            [ -n "$extracted_ver" ] &&
                ver="$extracted_ver"

            [ -n "$extracted_name" ] &&
                display_name="$extracted_name"
        fi
    else
        echo "[WARN] Không tìm thấy Payload/*.app trong $filename"
        rm -rf debs/tmp_ipa debs/tmp_out
        continue
    fi

    cat > debs/tmp_out/DEBIAN/control <<EOF
Package: $bid
Name: $clean_id
Version: $ver
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Applications
Description: Ung dung chuyen doi tu IPA sang DEB.
EOF

    sed -i 's/\r$//' debs/tmp_out/DEBIAN/control

    chmod 0755 debs/tmp_out/DEBIAN
    chmod 0644 debs/tmp_out/DEBIAN/control

    find debs/tmp_out/Applications \
        -type d \
        -exec chmod 0755 {} \; 2>/dev/null || true

    find debs/tmp_out/Applications \
        -type f \
        -exec chmod 0644 {} \; 2>/dev/null || true

    output_deb="debs/${clean_id}_${ver}_iphoneos-arm.deb"

    if dpkg-deb -Zgzip --build \
        debs/tmp_out \
        "$output_deb" >/dev/null 2>&1; then

        echo "[OK] Created: $output_deb"

    else

        echo "[ERROR] dpkg-deb thất bại: $filename"

    fi

    # ======================================
    # TẠO PLIST OTA
    # ======================================

    cat > "ipas/${clean_id}.plist" <<EOF
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

    rm -rf debs/tmp_ipa debs/tmp_out

done

# ==========================================
# 5. REPO ICONS
# ==========================================

rm -rf debs/tmp_icons

mkdir -p \
    debs/tmp_icons/DEBIAN \
    debs/tmp_icons/usr/share/cydia/sections

if [ -f "CydiaIcon.png" ]; then

    cp \
        CydiaIcon.png \
        debs/tmp_icons/usr/share/cydia/sections/com.anhtuan201x.repoicons.png

fi

cat > debs/tmp_icons/DEBIAN/control <<'EOF'
Package: com.anhtuan201x.repoicons
Name: AnhTuan201X Repo Icons
Version: 1.0
Architecture: iphoneos-arm
Maintainer: AnhTuan201X <anhtuan201x@github.io>
Section: Themes
Description: Bo suu tap bieu tuong logo cho repo AnhTuan201X.
EOF

sed -i 's/\r$//' debs/tmp_icons/DEBIAN/control

chmod 0755 debs/tmp_icons/DEBIAN
chmod 0644 debs/tmp_icons/DEBIAN/control

dpkg-deb -Zgzip \
    --build \
    debs/tmp_icons \
    debs/com.anhtuan201x.repoicons_1.0_iphoneos-arm.deb \
    >/dev/null 2>&1 || true

rm -rf debs/tmp_icons

# ==========================================
# 6. PACKAGES
# ==========================================

rm -f Packages Packages.bz2

if command -v dpkg-scanpackages >/dev/null 2>&1; then

    dpkg-scanpackages -m debs /dev/null > Packages 2>/dev/null

    sed -i 's/\r$//' Packages

    if [ -f "CydiaIcon.png" ]; then
        sed -i \
            's/^Description:.*$/&\
Icon: https:\/\/anhtuan201x.github.io\/CydiaIcon.png/' \
            Packages
    fi

    bzip2 -fk Packages

    echo "[OK] Packages generated."

else

    echo "[WARN] dpkg-scanpackages chưa được cài."
    echo "[WARN] Không thể tạo Packages."

fi

# ==========================================
# 7. RELEASE MD5
# ==========================================

if [ -f "Release" ]; then

    sed -i '/^MD5Sum:/,$d' Release

    cat >> Release <<EOF
MD5Sum:
 $(md5sum Packages | cut -d' ' -f1) $(stat -c%s Packages) Packages
 $(md5sum Packages.bz2 | cut -d' ' -f1) $(stat -c%s Packages.bz2) Packages.bz2
EOF

    sed -i 's/\r$//' Release

    echo "[OK] Release MD5 updated."

else

    echo "[WARN] Không tìm thấy Release."

fi

# ==========================================
# 8. TỔNG KẾT
# ==========================================

final_deb_count=$(find debs -maxdepth 1 -type f -name "*.deb" | wc -l)
final_ipa_count=$(find ipas -maxdepth 1 -type f -name "*.ipa" | wc -l)

echo
echo "=========================================="
echo " SYNC HOÀN TẤT"
echo "=========================================="
echo " DEB : $final_deb_count"
echo " IPA : $final_ipa_count"

if [ -f "Packages" ]; then
    echo " Packages : OK"
else
    echo " Packages : FAIL"
fi

if [ -f "Packages.bz2" ]; then
    echo " Packages.bz2 : OK"
else
    echo " Packages.bz2 : FAIL"
fi

echo "=========================================="
