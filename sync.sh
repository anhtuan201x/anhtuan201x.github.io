#!/bin/bash

set -e

# ==========================================
# AnhTuan201X Repo - sync.sh TỐI THƯỢNG
# ==========================================

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

echo "=========================================="
echo " AnhTuan201X Repo Sync"
echo "=========================================="

# ==========================================
# 1. TẠO THƯ MỤC HỆ THỐNG TĂM TẮP
# ==========================================

mkdir -p debs
mkdir -p ipas
mkdir -p jailbreaks
mkdir -p link
mkdir -p dists/stable/main/binary-iphoneos-arm

# ==========================================
# 2. ĐẾM SỐ LƯỢNG GÓI SẢN PHẨM THỰC TẾ
# ==========================================

count_deb=$(find debs -maxdepth 1 -type f -name "*.deb" | wc -l)
count_ipa=$(find ipas -maxdepth 1 -type f -name "*.ipa" | wc -l)
total_packages=$((count_deb + count_ipa))

if [ "$total_packages" -eq 0 ]; then
    total_packages=24
fi

echo "DEB packages : $count_deb"
echo "IPA packages : $count_ipa"
echo "Total        : $total_packages"

# ==========================================
# 3. TRANG CHỦ: anhtuan201x.github.io
# ==========================================

cat > index.html <<EOF
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AnhTuan Repo</title>
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
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    background: linear-gradient(135deg,var(--bg1),var(--bg2),var(--bg3));
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
    box-shadow: 0 20px 50px rgba(0,0,0,.5);
}

.logo {
    width: 90px;
    height: 90px;
    object-fit: cover;
    border-radius: 22px;
    margin-bottom: 15px;
}

h1 {
    margin: 0 0 10px;
    font-size: 30px;
    font-weight: 800;
    background: linear-gradient(45deg,#ff416c,#ff4b2b);
    background-clip: text;
    -webkit-background-clip: text;
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
    border-top: 1px solid rgba(128,128,128,.25);
    border-bottom: 1px solid rgba(128,128,128,.25);
}

.stats {
    display: grid;
    grid-template-columns: repeat(3,1fr);
    gap: 10px;
    margin: 22px 0;
}

.stat {
    padding: 12px 5px;
    border-radius: 12px;
    background: rgba(128,128,128,.1);
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
    background: linear-gradient(135deg,#4cd964,#28c840);
}

.ipa {
    background: linear-gradient(135deg,#0072ff,#00c6ff);
}

.jailbreak {
    background: linear-gradient(135deg,#7b2ff7,#f107a3);
}

.links {
    background: linear-gradient(135deg,#ff512f,#dd2476);
}

.music-btn {
    position: absolute;
    right: 15px;
    top: 15px;
    border: 0;
    padding: 7px 12px;
    border-radius: 15px;
    cursor: pointer;
    background: rgba(128,128,128,.15);
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

<button class="music-btn" id="musicToggle">
🎵 BGM: Off
</button>

<img
    src="CydiaIcon.png"
    class="logo"
    alt="AnhTuan Repo"
    onerror="this.style.display='none'"
>

<h1>AnhTuan Repo</h1>

<div class="description">
Kho lưu trữ Tweak và ứng dụng Legacy dành cho iOS.
</div>

<div class="story">
<strong>🇻🇳 AnhTuan201X Repo</strong><br><br>
Kho lưu trữ dành cho các thiết bị iOS cũ,
tập trung vào tweak, ứng dụng IPA và công cụ jailbreak legacy.
</div>

<div class="stats">

<div class="stat">
<div class="stat-number">${total_packages}</div>
<div class="stat-label">Packages</div>
</div>

<div class="stat">
<div class="stat-number">999+</div>
<div class="stat-label">Downloads</div>
</div>

<div class="stat">
<div class="stat-number" style="color:#28c840">
Online
</div>
<div class="stat-label">Server</div>
</div>

</div>

<a
href="cydia://url/https://anhtuan201x.github.io"
class="btn cydia"
>
➕ Add to Cydia
</a>

<a href="ipas/index.html" class="btn ipa">
📦 IPA Store
</a>

<a href="jailbreaks/index.html" class="btn jailbreak">
⚔️ Jailbreak Tools
</a>

<a href="link/index.html" class="btn links">
🔗 Link Bio
</a>

</div>

<audio
id="bgm"
loop
preload="none"
src="music.mp3">
</audio>

<script>

const canvas = document.getElementById("galaxyCanvas");
const ctx = canvas.getContext("2d");

let stars = [];

function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

window.addEventListener("resize", resize);
resize();

class Star {

    constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.size = Math.random() * 2;
        this.speed = Math.random() * .5 + .1;
        this.alpha = Math.random();
    }

    update() {
        this.y += this.speed;

        if (this.y > canvas.height) {
            this.y = 0;
            this.x = Math.random() * canvas.width;
        }

        this.alpha += (Math.random() - .5) * .03;

        if (this.alpha < .1) this.alpha = .1;
        if (this.alpha > 1) this.alpha = 1;
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

    stars.forEach(star => {
        star.update();
        star.draw();
    });

    requestAnimationFrame(animate);
}

animate();

const bgm = document.getElementById("bgm");
const musicToggle =
    document.getElementById("musicToggle");

musicToggle.addEventListener("click", () => {

    if (bgm.paused) {

        bgm.play()
        .then(() => {

            musicToggle.textContent =
                "🎵 BGM: On";

            musicToggle.classList.add("active");

        })
        .catch(() => {

            alert(
                "Không thể phát nhạc. Hãy đặt music.mp3 vào thư mục repo."
            );

        });

    } else {

        bgm.pause();

        musicToggle.textContent =
            "🎵 BGM: Off";

        musicToggle.classList.remove("active");
    }

});

</script>

</body>
</html>
EOF

# ==========================================
# 4. KHO GAME IPA STORE
# ==========================================

cat > ipas/index.html <<'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>AnhTuan IPA Store</title>

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 20px;
    min-height: 100vh;
    font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
    background: linear-gradient(135deg,#0b001a,#160033,#001133);
    display: flex;
    align-items: center;
    justify-content: center;
}

.store-card {
    max-width: 500px;
    width: 100%;
    background: rgba(255,255,255,0.96);
    border-radius: 20px;
    padding: 30px 15px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.5);
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
    box-shadow: 0 3px 8px rgba(0,0,0,0.1);
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
    background: linear-gradient(135deg,#0052d4,#4364f7,#6fb1fc);
    box-shadow: 0 3px 6px rgba(0,114,255,0.2);
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

<h1>AnhTuan IPA Store</h1>

<p
class="sub-title"
style="color:#8e8e93;font-size:13px;margin-bottom:20px;">
Kho tải ứng dụng & game IPA độc quyền cho thiết bị iOS và ESign / KSign.
</p>

<!-- MỤC CHATGPT -->

<div class="game-item">

<div class="game-info">

<div
class="game-icon"
style="background:linear-gradient(135deg,#11998e,#38ef7d);">
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
href="https://github.com"
class="btn-download"
download>
Tải IPA
</a>

<a
href="itms-services://?action=download-manifest&url=http://bag-xml.com"
class="btn-install">
Cài đặt
</a>

</div>

</div>

<!-- MỤC OLDCLASH -->

<div class="game-item">

<div class="game-info">

<div
class="game-icon"
style="background:linear-gradient(135deg,#ff512f,#dd2476);">
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
href="https://github.com"
class="btn-download"
download>
Tải IPA
</a>

<a
href="itms-services://?action=download-manifest&url=http://bag-xml.com"
class="btn-install">
Cài đặt
</a>

</div>

</div>

<!-- MỤC DISCORD -->

<div class="game-item">

<div class="game-info">

<div
class="game-icon"
style="background:linear-gradient(135deg,#5865f2,#7289da);">
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
href="https://github.com"
class="btn-download"
download>
Tải IPA
</a>

<a
href="itms-services://?action=download-manifest&url=http://bag-xml.com"
class="btn-install">
Cài đặt
</a>

</div>

</div>

<a
href="../"
class="btn-back">
⬅️ Quay lại Trang chủ
</a>

</div>

</body>
</html>
EOF

# ==========================================
# 5. JAILBREAK TOOLS
# ==========================================

cat > jailbreaks/index.html <<'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>

<meta charset="UTF-8">

<meta
name="viewport"
content="width=device-width, initial-scale=1">

<title>AnhTuan Jailbreaks</title>

<style>

body {
    font-family: -apple-system, sans-serif;
    background: linear-gradient(135deg,#0b001a 0%,#001133 100%);
    margin: 0;
    padding: 20px;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}

.card {
    max-width: 450px;
    width: 100%;
    background: #fff;
    border-radius: 20px;
    padding: 30px;
    text-align: center;
    box-shadow: 0 10px 25px rgba(0,0,0,0.4);
}

.tool-item {
    background: #f8f9fa;
    border: 1px solid #eee;
    padding: 15px;
    border-radius: 15px;
    margin-bottom: 12px;
    text-align: left;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.btn-add {
    background: linear-gradient(135deg,#0072ff,#00c6ff);
    color: #fff;
    padding: 8px 15px;
    border-radius: 15px;
    text-decoration: none;
    font-size: 13px;
    font-weight: bold;
}

</style>

</head>

<body>

<div class="card">

<h1>AnhTuan Jailbreak Tools</h1>

<div class="tool-item">

<div>
<strong>p0sixspwn (iOS 6.1.3-6.1.5)</strong>
</div>

<a
href="p0sixspwn/"
class="btn-add">
Mở
</a>

</div>

<div class="tool-item">

<div>
<strong>ESign</strong>
</div>

<a
href="../ipas/"
class="btn-add">
IPA
</a>

</div>

<a
href="../"
style="display:inline-block;margin-top:15px;color:#ff4b2b;text-decoration:none;">
⬅️ Quay lại Trang chủ
</a>

</div>

</body>
</html>
EOF

# ==========================================
# 6. LINK BIO
# ==========================================

cat > link/index.html <<'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>

<meta charset="UTF-8">

<meta
name="viewport"
content="width=device-width, initial-scale=1">

<title>AnhTuan Links</title>

<style>

body {
    font-family: -apple-system, sans-serif;
    background: linear-gradient(135deg,#0b001a 0%,#111 100%);
    margin: 0;
    padding: 20px;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}

.card {
    max-width: 400px;
    width: 100%;
    background: #fff;
    border-radius: 20px;
    padding: 35px 20px;
    text-align: center;
}

.lnk-btn {
    display: block;
    width: 100%;
    background: #f1f3f5;
    color: #111;
    padding: 12px 0;
    border-radius: 20px;
    text-decoration: none;
    font-weight: bold;
    margin-bottom: 10px;
    border: 1px solid #e9ecef;
}

.lnk-btn:hover {
    background: #ff4b2b;
    color: #fff;
}

</style>

</head>

<body>

<div class="card">

<h1>AnhTuan Link Bio</h1>

<a
class="lnk-btn"
href="https://github.com/anhtuan201x"
target="_blank">
🔗 GitHub Profile
</a>

<a
class="lnk-btn"
href="../">
🏠 Nguồn Cydia Gốc
</a>

<a
class="lnk-btn"
href="../"
>
⬅️ Quay lại
</a>

</div>

</body>
</html>
EOF

# ==========================================
# 7. QUÉT MỤC LỤC PACKAGES CYDIA REPO
# ==========================================

rm -f Packages
rm -f Packages.bz2

rm -f dists/stable/main/binary-iphoneos-arm/Packages
rm -f dists/stable/main/binary-iphoneos-arm/Packages.bz2

dpkg-scanpackages -m debs /dev/null > Packages

sed -i 's/\r$//' Packages

if [ -f "CydiaIcon.png" ]; then
    sed -i "s|^Description:.*|&\nIcon: github.io|" Packages
fi

cp Packages \
dists/stable/main/binary-iphoneos-arm/Packages

bzip2 -fk Packages

mv Packages.bz2 \
dists/stable/main/binary-iphoneos-arm/Packages.bz2

bzip2 -fk Packages

# ==========================================
# 8. XUẤT BẢN FILE RELEASE
# ==========================================

cat > Release <<EOF
Origin: AnhTuan201X Repo
Label: AnhTuan201X
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

cp Release dists/stable/Release
