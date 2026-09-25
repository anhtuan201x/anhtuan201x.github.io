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
# 1. TẠO THƯ MỤC
# ==========================================

mkdir -p debs
mkdir -p ipas
mkdir -p jailbreaks
mkdir -p link
mkdir -p dists/stable/main/binary-iphoneos-arm

# ==========================================
# 2. ĐẾM PACKAGE
# ==========================================

count_deb=$(find debs -maxdepth 1 -type f -name "*.deb" | wc -l)
count_ipa=$(find ipas -maxdepth 1 -type f -name "*.ipa" | wc -l)

total_packages=$((count_deb + count_ipa))

echo "DEB packages : $count_deb"
echo "IPA packages : $count_ipa"
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
tập trung vào tweak, ứng dụng IPA và công cụ
jailbreak legacy.
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

<a href="ipas/" class="btn ipa">
📦 IPA Store
</a>

<a href="jailbreaks/" class="btn jailbreak">
⚔️ Jailbreak Tools
</a>

<a href="link/" class="btn links">
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
# 4. IPA STORE
# ==========================================

cat > ipas/index.html <<EOF
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>AnhTuan IPA Store</title>

<style>
*{box-sizing:border-box}

body{
margin:0;
padding:20px;
min-height:100vh;
font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
background:linear-gradient(135deg,#0b001a,#160033,#001133);
}

.store{
max-width:550px;
margin:auto;
background:#fff;
border-radius:22px;
padding:25px 15px;
box-shadow:0 20px 50px rgba(0,0,0,.5);
}

h1{
text-align:center;
margin-top:0;
color:#1d1d26;
}

.subtitle{
text-align:center;
color:#777;
font-size:13px;
margin-bottom:20px;
}

.game{
display:flex;
align-items:center;
gap:12px;
padding:12px;
margin-bottom:12px;
background:#f7f8fa;
border:1px solid #eee;
border-radius:15px;
}

.icon{
width:48px;
height:48px;
min-width:48px;
border-radius:12px;
display:flex;
align-items:center;
justify-content:center;
font-size:22px;
}

.info{
flex:1;
min-width:0;
}

.name{
font-weight:700;
color:#222;
font-size:14px;
}

.size{
font-size:11px;
color:#888;
margin-top:3px;
}

.buttons{
display:flex;
gap:5px;
}

.btn{
padding:8px 10px;
border-radius:15px;
text-decoration:none;
font-size:11px;
font-weight:700;
color:#fff;
white-space:nowrap;
}

.download{
background:linear-gradient(135deg,#0072ff,#00c6ff);
}

.install{
background:linear-gradient(135deg,#11998e,#38ef7d);
}

.back{
display:block;
text-align:center;
margin-top:20px;
text-decoration:none;
color:#ff4b2b;
font-weight:600;
}
</style>
</head>

<body>

<div class="store">

<h1>📦 AnhTuan IPA Store</h1>

<div class="subtitle">
Ứng dụng IPA dành cho thiết bị iOS legacy
</div>

EOF

# ==========================================
# TỰ TẠO DANH SÁCH IPA
# ==========================================

for ipa in ipas/*.ipa; do

    [ -f "$ipa" ] || continue

    filename=$(basename "$ipa")
    name="${filename%.ipa}"
    size=$(du -h "$ipa" | cut -f1)

    cat >> ipas/index.html <<EOF
<div class="game">

<div class="icon"
style="background:linear-gradient(135deg,#11998e,#38ef7d)">
📦
</div>

<div class="info">
<div class="name">
$name
</div>

<div class="size">
$size
</div>
</div>

<div class="buttons">

<a
class="btn download"
href="$filename"
download
>
Tải IPA
</a>

<a
class="btn install"
href="itms-services://?action=download-manifest&url=https://anhtuan201x.github.io/ipas/$name.plist"
>
Cài đặt
</a>

</div>

</div>
EOF

done

cat >> ipas/index.html <<'EOF'

<a class="back" href="../">
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
content="width=device-width,initial-scale=1"
>

<title>AnhTuan Jailbreaks</title>

<style>

*{
box-sizing:border-box;
}

body{
margin:0;
padding:20px;
min-height:100vh;
display:flex;
align-items:center;
justify-content:center;
font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
background:linear-gradient(135deg,#0b001a,#001133);
}

.card{
width:100%;
max-width:450px;
background:#fff;
border-radius:22px;
padding:30px;
box-shadow:0 20px 50px rgba(0,0,0,.5);
}

h1{
text-align:center;
margin-top:0;
color:#222;
}

.subtitle{
text-align:center;
color:#777;
font-size:13px;
margin-bottom:20px;
}

.tool{
padding:15px;
margin-bottom:12px;
border-radius:15px;
background:#f7f8fa;
border:1px solid #eee;
display:flex;
align-items:center;
justify-content:space-between;
gap:10px;
}

.tool-name{
font-weight:700;
color:#222;
}

.tool-desc{
font-size:11px;
color:#888;
margin-top:3px;
}

.btn{
padding:8px 13px;
border-radius:15px;
background:linear-gradient(135deg,#0072ff,#00c6ff);
color:#fff;
text-decoration:none;
font-size:12px;
font-weight:700;
white-space:nowrap;
}

.back{
display:block;
text-align:center;
margin-top:20px;
text-decoration:none;
color:#ff4b2b;
}

</style>

</head>

<body>

<div class="card">

<h1>⚔️ Jailbreak Tools</h1>

<div class="subtitle">
Công cụ jailbreak cho thiết bị iOS legacy
</div>

<div class="tool">

<div>
<div class="tool-name">
p0sixspwn
</div>

<div class="tool-desc">
Jailbreak iOS 6.1.3 - 6.1.5
</div>
</div>

<a
class="btn"
href="p0sixspwn/"
>
Mở
</a>

</div>

<div class="tool">

<div>
<div class="tool-name">
ESign
</div>

<div class="tool-desc">
Công cụ ký và cài IPA
</div>
</div>

<a
class="btn"
href="../ipas/"
>
IPA
</a>

</div>

<a
class="back"
href="../"
>
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
content="width=device-width,initial-scale=1"
>

<title>AnhTuan Links</title>

<style>

*{
box-sizing:border-box;
}

body{
margin:0;
padding:20px;
min-height:100vh;
display:flex;
align-items:center;
justify-content:center;
font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
background:linear-gradient(135deg,#0b001a,#111);
}

.card{
width:100%;
max-width:420px;
background:#fff;
border-radius:22px;
padding:35px 20px;
text-align:center;
box-shadow:0 20px 50px rgba(0,0,0,.5);
}

.logo{
width:80px;
height:80px;
border-radius:20px;
margin-bottom:10px;
}

h1{
color:#222;
margin:5px 0 25px;
}

.link{
display:block;
width:100%;
padding:13px;
margin-bottom:10px;
border-radius:22px;
background:#f1f3f5;
border:1px solid #e9ecef;
color:#111;
text-decoration:none;
font-weight:700;
transition:.2s;
}

.link:hover{
background:#ff4b2b;
color:#fff;
transform:scale(.98);
}

.back{
display:block;
margin-top:20px;
text-decoration:none;
color:#ff4b2b;
}

</style>

</head>

<body>

<div class="card">

<img
src="../CydiaIcon.png"
class="logo"
alt="AnhTuan"
onerror="this.style.display='none'"
>

<h1>🔗 AnhTuan Link Bio</h1>

<a
class="link"
href="https://github.com/anhtuan201x"
target="_blank"
rel="noopener"
>
🐙 GitHub Profile
</a>

<a
class="link"
href="../"
>
🏠 AnhTuan Repo
</a>

<a
class="link"
href="../ipas/"
>
📦 IPA Store
</a>

<a
class="link"
href="../jailbreaks/"
>
⚔️ Jailbreak Tools
</a>

<a
class="back"
href="../"
>
⬅️ Quay lại
</a>

</div>

</body>

</html>
EOF

# ==========================================
# 7. BUILD CYDIA PACKAGES
# ==========================================

echo ""
echo "=========================================="
echo " Building Cydia Packages"
echo "=========================================="

rm -f Packages
rm -f Packages.bz2

rm -f dists/stable/main/binary-iphoneos-arm/Packages
rm -f dists/stable/main/binary-iphoneos-arm/Packages.bz2

if command -v dpkg-scanpackages >/dev/null 2>&1; then

    dpkg-scanpackages -m debs /dev/null > Packages

else

    echo "WARNING: dpkg-scanpackages chưa được cài."
    echo "Packages sẽ được tạo rỗng."

    : > Packages

fi

# Chuẩn hóa CRLF
sed -i 's/\r$//' Packages

# Copy Packages
cp Packages \
dists/stable/main/binary-iphoneos-arm/Packages

# Packages.bz2
bzip2 -kf Packages

cp Packages.bz2 \
dists/stable/main/binary-iphoneos-arm/Packages.bz2

# ==========================================
# 8. RELEASE
# ==========================================

PACKAGES_MD5=$(md5sum \
dists/stable/main/binary-iphoneos-arm/Packages \
| awk '{print $1}')

PACKAGES_SIZE=$(stat -c%s \
dists/stable/main/binary-iphoneos-arm/Packages)

PACKAGES_BZ2_MD5=$(md5sum \
dists/stable/main/binary-iphoneos-arm/Packages.bz2 \
| awk '{print $1}')

PACKAGES_BZ2_SIZE=$(stat -c%s \
dists/stable/main/binary-iphoneos-arm/Packages.bz2)

cat > Release <<EOF
Origin: AnhTuan201X Repo
Label: AnhTuan201X
Suite: stable
Version: 1.0
Codename: stable
Architectures: iphoneos-arm
Components: main
Description: Kho lưu trữ Tweak và ứng dụng Jailbreak của AnhTuan201X.

MD5Sum:
 $PACKAGES_MD5 $PACKAGES_SIZE main/binary-iphoneos-arm/Packages
 $PACKAGES_BZ2_MD5 $PACKAGES_BZ2_SIZE main/binary-iphoneos-arm/Packages.bz2
EOF

sed -i 's/\r$//' Release

cp Release dists/stable/Release

# ==========================================
# 9. HOÀN TẤT
# ==========================================

echo ""
echo "=========================================="
echo " SYNC HOÀN TẤT"
echo "=========================================="

echo "DEB     : $count_deb"
echo "IPA     : $count_ipa"
echo "TOTAL   : $total_packages"
echo ""
echo "Repo:"
echo "https://anhtuan201x.github.io/"
echo ""
echo "Cydia:"
echo "https://anhtuan201x.github.io/"
echo ""
echo "IPA:"
echo "https://anhtuan201x.github.io/ipas/"
echo ""
echo "Jailbreak:"
echo "https://anhtuan201x.github.io/jailbreaks/"
echo ""
echo "Links:"
echo "https://anhtuan201x.github.io/link/"
echo "=========================================="
