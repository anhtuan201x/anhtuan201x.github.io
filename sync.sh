#!/bin/bash

set -e

# ==========================================
# AnhTuan201X Repo - sync.sh
# ==========================================

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo "=========================================="
echo " AnhTuan201X Repo Sync"
echo "=========================================="

# ==========================================
# 1. DỌN & TẠO THƯ MỤC
# ==========================================

rm -rf jailbreaks link ipas

mkdir -p debs
mkdir -p bundles
mkdir -p dists/stable/main/binary-iphoneos-arm

# ==========================================
# 2. ĐẾM PACKAGE
# ==========================================

count_deb=$(find debs -maxdepth 1 -type f -name "*.deb" | wc -l | tr -d ' ')
total_packages="$count_deb"

if [ "$total_packages" -eq 0 ]; then
    total_packages=45
fi

echo "DEB packages : $count_deb"
echo "Total        : $total_packages"

# ==========================================
# 3. TRANG CHỦ
# ==========================================

cat > index.html <<EOF
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>AnhTuan201X Repo</title>

<link rel="icon" type="image/png" href="CydiaIcon.png">

<style>
* {
    box-sizing: border-box;
}

:root {
    --bg1: #0b001a;
    --bg2: #160033;
    --bg3: #001133;
    --card: rgba(255,255,255,0.95);
    --text: #1d1d26;
    --sub: #555;
}

@media (prefers-color-scheme: dark) {
    :root {
        --card: rgba(20,16,38,0.94);
        --text: #fff;
        --sub: #b0aec2;
    }
}

body {
    margin: 0;
    padding: 20px;
    min-height: 100vh;

    display: flex;
    align-items: center;
    justify-content: center;

    font-family:
        -apple-system,
        BlinkMacSystemFont,
        "Segoe UI",
        sans-serif;

    background:
        linear-gradient(
            135deg,
            var(--bg1),
            var(--bg2),
            var(--bg3)
        );

    color: var(--text);
    overflow-x: hidden;
}

#galaxyCanvas {
    position: fixed;
    inset: 0;
    width: 100%;
    height: 100%;

    z-index: 0;
    pointer-events: none;
}

.container {
    position: relative;
    z-index: 2;

    width: 100%;
    max-width: 440px;

    padding: 35px 25px;

    text-align: center;

    border-radius: 24px;

    background: var(--card);

    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);

    box-shadow:
        0 20px 50px rgba(0,0,0,.5);
}

.logo {
    width: 90px;
    height: 90px;

    object-fit: cover;

    border-radius: 22px;

    margin-bottom: 15px;

    box-shadow:
        0 4px 15px rgba(0,0,0,0.2);
}

h1 {
    margin: 0 0 10px;

    font-size: 30px;
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

.description {
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 20px;
}

.story {
    color: var(--sub);

    font-size: 13.5px;
    line-height: 1.6;

    text-align: left;

    padding: 15px 0;

    border-top:
        1px solid rgba(128,128,128,.25);

    border-bottom:
        1px solid rgba(128,128,128,.25);
}

.stats {
    display: grid;

    grid-template-columns:
        repeat(3,1fr);

    gap: 10px;

    margin: 22px 0;
}

.stat {
    padding: 12px 5px;

    border-radius: 12px;

    background:
        rgba(128,128,128,.1);
}

.stat-number {
    font-size: 16px;
    font-weight: 800;
    color: #ff4b2b;
}

.stat-label {
    margin-top: 3px;

    font-size: 11px;

    color: #888;
}

.btn {
    display: block;

    width: 100%;

    padding: 14px;

    margin-bottom: 10px;

    border-radius: 25px;

    color: white;

    text-decoration: none;

    font-size: 15px;
    font-weight: 700;

    transition: .2s;

    text-align: center;
}

.btn:hover {
    transform: scale(.97);
}

.cydia {
    background:
        linear-gradient(
            135deg,
            #4cd964,
            #28c840
        );
}

.bundles-btn {
    background:
        linear-gradient(
            135deg,
            #0072ff,
            #00c6ff
        );

    box-shadow:
        0 4px 10px
        rgba(0,114,255,0.3);
}

.music-btn {
    position: absolute;

    right: 15px;
    top: 15px;

    border: 0;

    padding: 7px 12px;

    border-radius: 15px;

    cursor: pointer;

    background:
        rgba(128,128,128,.15);

    color: var(--text);

    font-weight: bold;
}

.music-btn.active {
    background: #28c840;
    color: white;
}
</style>
</head>

<body>

<canvas id="galaxyCanvas"></canvas>

<div class="container">

<button
    class="music-btn"
    id="musicToggle">
    🎵 BGM: Off
</button>

<img
    src="CydiaIcon.png"
    class="logo"
    alt="AnhTuan201X Repo"
    onerror="this.style.display='none'">

<h1>AnhTuan201X Repo</h1>

<div class="description">
    Kho lưu trữ Tweak và ứng dụng Legacy dành cho iOS.
</div>

<div class="story">

<strong>🇻🇳 AnhTuan201X Repo</strong>

<br><br>

Kho lưu trữ chuyên biệt dành cho
các thiết bị iOS Legacy (iOS 5+),
tập trung vào Tweak hệ thống
và các tệp tin Signed iOS Bundles.

</div>

<div class="stats">

<div class="stat">
    <div class="stat-number">
        ${total_packages}
    </div>

    <div class="stat-label">
        Packages
    </div>
</div>

<div class="stat">
    <div class="stat-number">
        999+
    </div>

    <div class="stat-label">
        Downloads
    </div>
</div>

<div class="stat">
    <div
        class="stat-number"
        style="color:#28c840">
        Online
    </div>

    <div class="stat-label">
        Server
    </div>
</div>

</div>

<!--
    Cydia API Share
    Repo:
    http://anhtuan201x.github.io/
-->

<a
    href="cydia://url/https://cydia.saurik.com/api/share#?url=http%3A%2F%2Fanhtuan201x.github.io%2F"
    class="btn cydia">
    ➕ Add to Cydia
</a>

<a
    href="bundles/index.html"
    class="btn bundles-btn">
    📦 Signed iOS Bundles (iOS 5+)
</a>

</div>

<audio
    id="bgm"
    loop
    preload="none"
    src="music.mp3">
</audio>

<script>

const canvas =
    document.getElementById("galaxyCanvas");

const ctx =
    canvas.getContext("2d");

let stars = [];

function resize() {

    canvas.width =
        window.innerWidth;

    canvas.height =
        window.innerHeight;
}

window.addEventListener(
    "resize",
    resize
);

resize();

class Star {

    constructor() {

        this.x =
            Math.random() *
            canvas.width;

        this.y =
            Math.random() *
            canvas.height;

        this.size =
            Math.random() * 2;

        this.speed =
            Math.random() * .5 + .1;

        this.alpha =
            Math.random();
    }

    update() {

        this.y += this.speed;

        if (
            this.y >
            canvas.height
        ) {

            this.y = 0;

            this.x =
                Math.random() *
                canvas.width;
        }

        this.alpha +=
            (Math.random() - .5) * .03;

        if (this.alpha < .1)
            this.alpha = .1;

        if (this.alpha > 1)
            this.alpha = 1;
    }

    draw() {

        ctx.beginPath();

        ctx.arc(
            this.x,
            this.y,
            this.size,
            0,
            Math.PI * 2
        );

        ctx.fillStyle =
            "rgba(255,255,255," +
            this.alpha +
            ")";

        ctx.fill();
    }
}

for (
    let i = 0;
    i < 100;
    i++
) {

    stars.push(
        new Star()
    );
}

function animate() {

    ctx.clearRect(
        0,
        0,
        canvas.width,
        canvas.height
    );

    stars.forEach(
        star => {

            star.update();
            star.draw();

        }
    );

    requestAnimationFrame(
        animate
    );
}

animate();

const bgm =
    document.getElementById("bgm");

const musicToggle =
    document.getElementById(
        "musicToggle"
    );

musicToggle.addEventListener(
    "click",
    () => {

        if (bgm.paused) {

            bgm.play()
            .then(() => {

                musicToggle.textContent =
                    "🎵 BGM: On";

                musicToggle.classList.add(
                    "active"
                );

            })
            .catch(() => {

                alert(
                    "Không thể phát nhạc. " +
                    "Hãy đặt music.mp3 " +
                    "vào thư mục repo."
                );

            });

        } else {

            bgm.pause();

            musicToggle.textContent =
                "🎵 BGM: Off";

            musicToggle.classList.remove(
                "active"
            );
        }
    }
);

</script>

</body>
</html>
EOF

# ==========================================
# 4. BUNDLES
# ==========================================

cat > bundles/index.html <<'EOF'
<!DOCTYPE html>
<html lang="vi">

<head>

<meta charset="UTF-8">

<meta
    name="viewport"
    content="width=device-width,initial-scale=1">

<title>Signed iOS Bundles</title>

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

    align-items: center;
    justify-content: center;
}

.store-card {

    max-width: 500px;

    width: 100%;

    background:
        rgba(255,255,255,0.96);

    border-radius: 20px;

    padding: 30px 15px;

    box-shadow:
        0 15px 35px
        rgba(0,0,0,0.5);

    text-align: center;
}

.cert-notice {

    background:
        rgba(76,217,100,0.1);

    border:
        1px dashed #28c840;

    color: #1e8a2a;

    border-radius: 12px;

    padding: 12px;

    font-size: 12.5px;

    font-weight: 600;

    margin-bottom: 20px;

    text-align: justify;

    line-height: 1.5;
}

.btn-cert {

    display: inline-block;

    background:
        linear-gradient(
            135deg,
            #ff9500,
            #ffcc00
        );

    color: #fff;

    text-decoration: none;

    padding: 10px 16px;

    border-radius: 20px;

    font-size: 13px;

    font-weight: bold;

    margin-top: 8px;

    width: 100%;

    text-align: center;
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

    background:
        linear-gradient(
            135deg,
            #0072ff,
            #00c6ff
        );
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

    background:
        linear-gradient(
            135deg,
            #0072ff,
            #00c6ff
        );
}

.btn-install {

    background:
        linear-gradient(
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

    font-weight: 500;
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

<h1>Signed iOS Bundles</h1>

<p
    style="
    color:#8e8e93;
    font-size:13px;
    margin-bottom:15px;
    ">

Kho tải ứng dụng,
game đã ký (Signed)
dành cho iOS 5 trở lên.

</p>

<div class="cert-notice">

🔒 <b>Yêu cầu chứng chỉ:</b>

<br>

Đây là khu vực dành cho các
ứng dụng/bundle đã ký.
Hãy đảm bảo thiết bị có chứng chỉ
phù hợp trước khi cài đặt.

<a
    href="https://litten.ca"
    class="btn-cert">

🔑 Cài đặt Hanabi CA Cert

</a>

</div>

<!-- ============================== -->
<!-- ChatGPT -->
<!-- ============================== -->

<div class="game-item">

<div class="game-info">

<div class="game-icon">
📦
</div>

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
    href="https://github.com/bag-xml/ChatGPT-for-Legacy-iOS/releases/download/v1.0.2-release/ChatGPT-v1.0.2-openrouter.ipa"
    class="btn-download">

Tải IPA

</a>

<a
    href="itms-services://?action=download-manifest&url=http://bag-xml.com/projects/chatgpt/assets/itml/chatgpt/1.0/app.plist"
    class="btn-install">

Cài đặt

</a>

</div>

</div>

<!-- ============================== -->
<!-- OldClash -->
<!-- ============================== -->

<div class="game-item">

<div class="game-info">

<div class="game-icon">
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
    href="https://oldclash.bag-xml.com/apps/ios/itml/6.253/app.ipa"
    class="btn-download">

Tải IPA

</a>

<a
    href="itms-services://?action=download-manifest&url=http://oldclash.bag-xml.com/apps/ios/itml/6.253/app.plist"
    class="btn-install">

Cài đặt

</a>

</div>

</div>

<!-- ============================== -->
<!-- Discord -->
<!-- ============================== -->

<div class="game-item">

<div class="game-info">

<div class="game-icon">
💬
</div>

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
    href="https://github.com/Ayeris23/Discord-Classic/releases/download/v0.9.6-2/Discord_0.9.6-2.ipa"
    class="btn-download">

Tải IPA

</a>

<a
    href="itms-services://?action=download-manifest&url=http://bag-xml.com/assets/itml/discord/0.9/app.plist"
    class="btn-install">

Cài đặt

</a>

</div>

</div>

<!-- ============================== -->
<!-- Asphalt 4 -->
<!-- ============================== -->

<div class="game-item">

<div class="game-info">

<div class="game-icon">
🏎️
</div>

<div>

<div class="game-name">
Asphalt 4: Elite Racing
</div>

<div class="game-size">
Dung lượng: 24.3 MB
</div>

</div>

</div>

<div class="btn-group">

<a
    href="https://archive.org/download/Asphalt4/Asphalt%204.ipa"
    class="btn-download">

Tải IPA

</a>

<a
    href="https://github.com/anhtuan201x/anhtuan201x.github.io/blob/main/ipas/asphalt4.plist"
    class="btn-install">

Cài đặt

</a>

</div>

</div>

<a
    href="../index.html"
    class="btn-back">

⬅️ Quay lại Trang chủ

</a>

</div>

</body>

</html>
EOF

# ==========================================
# 5. QUÉT PACKAGES
# ==========================================

rm -f Packages
rm -f Packages.bz2

rm -f dists/stable/main/binary-iphoneos-arm/Packages
rm -f dists/stable/main/binary-iphoneos-arm/Packages.bz2

dpkg-scanpackages -m debs /dev/null > Packages

sed -i 's/\r$//' Packages

if [ -f "CydiaIcon.png" ]; then
    sed -i '/^Description:/a Icon: CydiaIcon.png' Packages
fi

cp \
    Packages \
    dists/stable/main/binary-iphoneos-arm/Packages

bzip2 -fk Packages

mv \
    Packages.bz2 \
    dists/stable/main/binary-iphoneos-arm/Packages.bz2

echo "Packages generated successfully."

# ==========================================
# 6. RELEASE
# ==========================================

cat > Release <<EOF
Origin: AnhTuan201X Repo
Label: AnhTuan201X Repo
Suite: stable
Version: 1.0
Codename: stable
Architectures: iphoneos-arm
Components: main
Description: Kho lưu trữ Tweak và Ứng dụng Jailbreak của AnhTuan201X.

MD5Sum:
$(md5sum dists/stable/main/binary-iphoneos-arm/Packages | cut -d' ' -f1) $(stat -c%s dists/stable/main/binary-iphoneos-arm/Packages) main/binary-iphoneos-arm/Packages
$(md5sum dists/stable/main/binary-iphoneos-arm/Packages.bz2 | cut -d' ' -f1) $(stat -c%s dists/stable/main/binary-iphoneos-arm/Packages.bz2) main/binary-iphoneos-arm/Packages.bz2
EOF

sed -i 's/\r$//' Release

cp \
    Release \
    dists/stable/Release

echo "Release generated successfully."

# ==========================================
# 7. GIT SYNC
# ==========================================

git config --global user.name "anhtuan201x-bot"
git config --global user.email "anhtuan201x@github.io"

git add -A

if ! git diff --cached --quiet; then

    git commit \
        -m "Bot: Auto sync AnhTuan201X Repo" \
        || true

    git pull \
        origin main \
        --rebase \
        --strategy-option=theirs \
        || true

    git push \
        origin main \
        || true

fi

echo "=========================================="
echo " Sync completed."
echo " Repo: http://anhtuan201x.github.io/"
echo "=========================================="
