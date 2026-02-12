<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>CAMPUS SYSTEM </title>
<script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Chakra+Petch:wght@400;600;700&family=Noto+Sans+JP:wght@400;700&display=swap" rel="stylesheet">
<style>
    /* デザイン設定（変更なし） */
    :root { --bg: #050a10; --panel: rgba(13, 22, 30, 0.95); --cyan: #00f3ff; --green: #00ff9d; --red: #ff0055; --text: #e0f7fa; --border: rgba(0, 243, 255, 0.3); }
    body { margin: 0; padding: 0; background: var(--bg); color: var(--text); font-family: 'Chakra Petch', 'Noto Sans JP', sans-serif; height: 100vh; overflow: hidden; display: flex; flex-direction: column; background-image: linear-gradient(rgba(0, 243, 255, 0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(0, 243, 255, 0.05) 1px, transparent 1px); background-size: 50px 50px; }
    .header { height: 70px; background: rgba(0,0,0,0.8); border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; padding: 0 25px; }
    .brand { font-size: 24px; font-weight: bold; color: var(--cyan); letter-spacing: 2px; text-shadow: 0 0 10px var(--cyan); display: flex; align-items: center; gap: 10px; }
    .sys-badge { border: 1px solid var(--green); color: var(--green); padding: 2px 8px; border-radius: 4px; font-size: 12px; letter-spacing: 1px; }
    .status-group { display: flex; gap: 30px; align-items: center; height: 100%; }
    .clock-container { text-align: right; line-height: 1.2; }
    .date-text { font-size: 14px; color: var(--cyan); font-weight: bold; display: block; letter-spacing: 1px; margin-bottom: -5px; }
    .clock { font-size: 32px; font-weight: bold; text-shadow: 0 0 10px var(--cyan); font-variant-numeric: tabular-nums; letter-spacing: 2px; }
    .weather-box { display: flex; gap: 10px; align-items: center; font-weight: bold; color: #fff; background: rgba(0, 243, 255, 0.1); padding: 5px 15px; border-radius: 30px; border: 1px solid rgba(0, 243, 255, 0.2); }
    .main-grid { flex: 1; display: flex; padding: 20px; gap: 20px; overflow: hidden; }
    .camera-area { flex: 3; position: relative; border: 2px solid var(--border); background: #000; border-radius: 8px; overflow: hidden; box-shadow: 0 0 30px rgba(0, 243, 255, 0.1); }
    canvas { width: 100%; height: 100%; object-fit: cover; }
    .hud-overlay { position: absolute; inset: 0; pointer-events: none; }
    .scan-reticle { position: absolute; top: 50%; left: 50%; width: 60%; aspect-ratio: 1; transform: translate(-50%, -50%); border: 2px solid rgba(255,255,255,0.2); }
    .corner { position: absolute; width: 20px; height: 20px; border: 3px solid var(--cyan); }
    .tl { top: -2px; left: -2px; border-right: none; border-bottom: none; }
    .tr { top: -2px; right: -2px; border-left: none; border-bottom: none; }
    .bl { bottom: -2px; left: -2px; border-right: none; border-top: none; }
    .br { bottom: -2px; right: -2px; border-left: none; border-top: none; }
    .laser-line { position: absolute; width: 100%; height: 2px; background: var(--green); top: 50%; box-shadow: 0 0 15px var(--green); animation: scan 2s ease-in-out infinite; }
    @keyframes scan { 0% { top: 0%; opacity: 0; } 50% { opacity: 1; } 100% { top: 100%; opacity: 0; } }
    .info-area { flex: 2; display: flex; flex-direction: column; gap: 15px; }
    .panel { background: var(--panel); border: 1px solid var(--border); border-radius: 6px; padding: 15px; position: relative; }
    .monitor { flex: 1.5; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; background: radial-gradient(circle, rgba(10,30,50,0.8), rgba(0,0,0,0.9)); border: 1px solid var(--border); transition: 0.3s; }
    .mon-icon { font-size: 70px; color: #445; margin-bottom: 10px; }
    .mon-text { font-size: 32px; font-weight: bold; color: #fff; }
    .mon-sub { font-size: 16px; color: var(--cyan); margin-top: 5px; }
    .res-ok { border-color: var(--green); box-shadow: inset 0 0 50px rgba(0,255,157,0.2); }
    .res-ok .mon-icon { color: var(--green); text-shadow: 0 0 20px var(--green); }
    .res-ng { border-color: var(--red); box-shadow: inset 0 0 50px rgba(255,0,85,0.2); }
    .res-ng .mon-icon { color: var(--red); }
    .footer { height: 35px; background: #000; border-top: 1px solid var(--border); display: flex; align-items: center; font-size: 14px; color: var(--cyan); }
    .news-tag { background: var(--cyan); color: #000; padding: 0 15px; height: 100%; display: flex; align-items: center; font-weight: bold; z-index: 2; }
    .marquee { overflow: hidden; white-space: nowrap; width: 100%; }
    .marquee span { display: inline-block; padding-left: 100%; animation: scroll 30s linear infinite; }
    @keyframes scroll { 0% { transform: translateX(0); } 100% { transform: translateX(-100%); } }
    .timeline-box { flex: 2; display: flex; flex-direction: column; padding: 20px; }
    .timeline-header { border-bottom: 1px solid rgba(0,243,255,0.3); margin-bottom: 15px; padding-bottom: 5px; display: flex; justify-content: space-between; align-items: flex-end; }
    .tl-title { font-size: 18px; font-weight: bold; color: var(--cyan); }
    .tl-status { font-size: 14px; font-weight: bold; color: #fff; background: rgba(0,243,255,0.2); padding: 2px 8px; border-radius: 4px; }
    .current-period-box { text-align: center; margin-bottom: 20px; }
    .cp-label { font-size: 14px; color: #889; letter-spacing: 2px; }
    .cp-name { font-size: 42px; font-weight: bold; color: #fff; text-shadow: 0 0 15px var(--cyan); margin: 5px 0; }
    .cp-time { font-size: 20px; color: var(--cyan); font-family: monospace; }
    .progress-area { margin-top: auto; }
    .pg-label { display: flex; justify-content: space-between; font-size: 12px; color: #aaa; margin-bottom: 5px; }
    .pg-bar-bg { width: 100%; height: 10px; background: #112; border-radius: 5px; overflow: hidden; border: 1px solid #334; }
    .pg-bar-fill { height: 100%; background: linear-gradient(90deg, var(--cyan), var(--green)); width: 0%; transition: width 1s linear; box-shadow: 0 0 10px var(--cyan); }
    .start-overlay { position: fixed; inset: 0; background: rgba(0,5,10,0.95); z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column; backdrop-filter: blur(5px); }
    .start-btn { padding: 15px 40px; border: 2px solid var(--cyan); background: transparent; color: var(--cyan); font-family: 'Chakra Petch', sans-serif; font-size: 24px; font-weight: bold; letter-spacing: 2px; cursor: pointer; transition: 0.3s; clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px); }
    .start-btn:hover { background: var(--cyan); color: #000; box-shadow: 0 0 30px var(--cyan); }
</style>
</head>
<body>
    <audio id="bgm" preload="auto"></audio>

    <div class="start-overlay" id="startOverlay">
        <div style="color:var(--cyan); font-size:20px; margin-bottom:20px;">CAMPUS GRID SYSTEM</div>
        <button class="start-btn" onclick="startSystem()">INITIALIZE SYSTEM</button>
    </div>

    <header class="header">
        <div class="brand">ATTENDANCE SYSTEM<br>CAMPUS GRID <span class="sys-badge">LIVE</span></div>
        <div class="status-group">
            <div class="weather-box" id="weatherBox">
                <span id="wIcon">☀</span> <span id="wLoc">東京 (Default)</span> <span id="wTemp">--°C</span>
            </div>
            <div class="clock-container">
                <span class="date-text" id="dateDisp">----/--/-- (--)</span>
                <div class="clock" id="clock">--:--:--</div>
            </div>
        </div>
    </header>
    <div class="main-grid">
        <div class="camera-area">
            <canvas id="canvas"></canvas>
            <div class="hud-overlay"><div class="scan-reticle"><div class="corner tl"></div><div class="corner tr"></div><div class="corner bl"></div><div class="corner br"></div><div class="laser-line"></div></div></div>
        </div>
        <div class="info-area">
            <div class="panel monitor" id="monitor">
                <div class="mon-icon" id="monIcon">⌖</div>
                <div class="mon-text" id="monMain">STANDBY</div>
                <div class="mon-sub" id="monSub">QRコードをスキャンしてください</div>
            </div>
            <div class="panel timeline-box">
                <div class="timeline-header">
                    <span class="tl-title">CAMPUS TIMELINE</span>
                    <span class="tl-status" id="periodStatus">CHECKING</span>
                </div>
                <div class="current-period-box">
                    <div class="cp-label">CURRENT PERIOD</div>
                    <div class="cp-name" id="cpName">--</div>
                    <div class="cp-time" id="cpTime">--:-- - --:--</div>
                </div>
                <div class="progress-area">
                    <div class="pg-label"><span>REMAINING</span><span id="timeLeft">-- min</span></div>
                    <div class="pg-bar-bg"><div class="pg-bar-fill" id="timeBar"></div></div>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">
        <div class="news-tag">INFORMATION</div>
        <div class="marquee"><span>【お知らせ】現在、システムは正常に稼働しています。 &nbsp;&nbsp;|&nbsp;&nbsp; 遅刻・欠席の連絡はモバイルアプリから行ってください。</span></div>
    </div>

    <script>
        const canvasElement = document.getElementById("canvas");
        const canvas = canvasElement.getContext("2d");
        const monitor = document.getElementById("monitor");
        const monIcon = document.getElementById("monIcon");
        const monMain = document.getElementById("monMain");
        const monSub = document.getElementById("monSub");
        const wIcon = document.getElementById("wIcon");
        const wLoc = document.getElementById("wLoc");
        const wTemp = document.getElementById("wTemp");
        const bgm = document.getElementById("bgm");

        // ★★★ プレイリスト設定（bgmフォルダの4曲） ★★★
        const playlist = [
           //"${pageContext.request.contextPath}/bgm/bgm.m4a",
            //"${pageContext.request.contextPath}/bgm/bgm1.m4a",
           //"${pageContext.request.contextPath}/bgm/bgm2.m4a",
            //"${pageContext.request.contextPath}/bgm/bgm3.m4a",
        	"${pageContext.request.contextPath}/bgm/bgm5.m4a"
        ];
        let currentTrackIndex = 0;

        // ★ 次の曲を再生する関数
        function playNextTrack() {
            // 曲をセット
            bgm.src = playlist[currentTrackIndex];
            bgm.volume = 0.2; // 音量20%

            // 再生開始
            bgm.play().then(() => {
                console.log("Playing: " + playlist[currentTrackIndex]);
            }).catch(e => {
                console.error("Play error:", e);
            });

            // 次のインデックスへ（最後までいったら0に戻る）
            currentTrackIndex++;
            if (currentTrackIndex >= playlist.length) {
                currentTrackIndex = 0;
            }
        }

        // ★ 曲が終わったら自動で次へ行くイベント設定
        bgm.addEventListener('ended', playNextTrack);

        // BGMロードエラー検知
        bgm.addEventListener('error', function(e) {
            console.error("Audio Load Error:", e);
            // エラーが出ても止まらずに次の曲へ行こうとする処理（お好みで）
            // playNextTrack();
        });

        // ★ システム起動処理
        function startSystem() {
            const overlay = document.getElementById("startOverlay");
            overlay.style.opacity = "0";
            setTimeout(() => { overlay.style.display = "none"; }, 500);

            if(audioCtx.state === 'suspended') audioCtx.resume();

            // 最初の曲を再生開始
            playNextTrack();

            startCamera();
        }

        // --- 時計・時間割・天気等の既存処理 ---
        setInterval(() => {
            const now = new Date();
            const dateStr = now.toLocaleDateString('ja-JP', { year: 'numeric', month: '2-digit', day: '2-digit', weekday: 'short' });
            document.getElementById("dateDisp").innerText = dateStr;
            document.getElementById("clock").innerText = now.toLocaleTimeString('ja-JP', { hour12: false });
            updateTimeline(now);
        }, 1000);

        const schedule = [
            { name: "1限", start: "09:20", end: "11:00" },
            { name: "2限", start: "11:10", end: "12:40" },
            { name: "昼休み", start: "12:40", end: "13:40" },
            { name: "3限", start: "13:40", end: "15:10" },
            { name: "4限", start: "15:20", end: "16:50" },
            { name: "放課後", start: "16:50", end: "23:59" }
        ];

        function updateTimeline(now) {
            const currentHm = now.getHours() * 60 + now.getMinutes();
            let activePeriod = null;
            let nextPeriod = null;
            for (let i = 0; i < schedule.length; i++) {
                const p = schedule[i];
                const [sH, sM] = p.start.split(":").map(Number);
                const [eH, eM] = p.end.split(":").map(Number);
                const startMin = sH * 60 + sM;
                const endMin = eH * 60 + eM;
                if (currentHm >= startMin && currentHm < endMin) { activePeriod = { ...p, startMin, endMin }; break; }
                if (currentHm < startMin && !nextPeriod) { nextPeriod = { ...p, startMin, endMin }; }
            }
            if (activePeriod) {
                document.getElementById("periodStatus").innerText = "IN SESSION";
                document.getElementById("periodStatus").style.color = "#00ff9d";
                document.getElementById("cpName").innerText = activePeriod.name;
                document.getElementById("cpTime").innerText = activePeriod.start + " - " + activePeriod.end;
                const totalDuration = activePeriod.endMin - activePeriod.startMin;
                const elapsed = currentHm - activePeriod.startMin;
                const remaining = activePeriod.endMin - currentHm;
                const percent = (elapsed / totalDuration) * 100;
                document.getElementById("timeLeft").innerText = remaining + " min";
                document.getElementById("timeBar").style.width = percent + "%";
            } else if (nextPeriod) {
                document.getElementById("periodStatus").innerText = "BREAK TIME";
                document.getElementById("periodStatus").style.color = "#00f3ff";
                document.getElementById("cpName").innerText = "NEXT: " + nextPeriod.name;
                document.getElementById("cpTime").innerText = "Starts at " + nextPeriod.start;
                const waitTime = nextPeriod.startMin - currentHm;
                document.getElementById("timeLeft").innerText = "Starts in " + waitTime + " min";
                document.getElementById("timeBar").style.width = "0%";
            } else {
                document.getElementById("periodStatus").innerText = "OFFLINE";
                document.getElementById("periodStatus").style.color = "#888";
                document.getElementById("cpName").innerText = "CLOSED";
                document.getElementById("cpTime").innerText = "--:--";
                document.getElementById("timeLeft").innerText = "--";
                document.getElementById("timeBar").style.width = "0%";
            }
        }

        function fetchWeatherAndLocation() {
            if (!navigator.geolocation) return;
            navigator.geolocation.getCurrentPosition(success => {
                const lat = success.coords.latitude;
                const lon = success.coords.longitude;
                Promise.all([
                    fetch("https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current_weather=true").then(r => r.json()),
                    fetch("https://nominatim.openstreetmap.org/reverse?format=json&lat=" + lat + "&lon=" + lon).then(r => r.json())
                ]).then(([weather, geo]) => {
                    if(weather.current_weather) {
                        wTemp.innerText = weather.current_weather.temperature + "°C";
                        const code = weather.current_weather.weathercode;
                        wIcon.innerText = (code <= 3) ? "☀" : (code <= 80) ? "☂" : "⛈";
                    }
                    if(geo.address) { wLoc.innerText = geo.address.city || geo.address.ward || "現在地"; }
                }).catch(e => {});
            }, error => {});
        }
        fetchWeatherAndLocation();
        setInterval(fetchWeatherAndLocation, 300000);

        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

        function speak(text) {
            if ('speechSynthesis' in window) {
                const prevVol = bgm.volume;
                bgm.volume = 0.05;
                const uttr = new SpeechSynthesisUtterance();
                uttr.text = text;
                uttr.lang = "ja-JP";
                uttr.rate = 1.0;
                uttr.pitch = 1.0;
                uttr.onend = function() { bgm.volume = prevVol; };
                window.speechSynthesis.speak(uttr);
            }
        }

        function playSound(type) {
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            const t = audioCtx.currentTime;
            osc.type = type === 'ok' ? 'sine' : 'sawtooth';
            osc.frequency.setValueAtTime(type === 'ok' ? 600 : 150, t);
            if(type==='ok') osc.frequency.exponentialRampToValueAtTime(1200, t + 0.1);
            gain.gain.setValueAtTime(0.2, t);
            gain.gain.exponentialRampToValueAtTime(0.01, t + 0.4);
            osc.start(t);
            osc.stop(t + 0.4);
        }

        function startCamera() {
            const video = document.createElement("video");
            let isScanning = true;

            navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(stream => {
                video.srcObject = stream;
                video.setAttribute("playsinline", true);
                video.play();
                requestAnimationFrame(tick);
            });

            function tick() {
                if (video.readyState === video.HAVE_ENOUGH_DATA) {
                    canvasElement.height = video.videoHeight;
                    canvasElement.width = video.videoWidth;
                    canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);
                    if (isScanning) {
                        var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
                        var code = jsQR(imageData.data, imageData.width, imageData.height, { inversionAttempts: "dontInvert" });
                        if (code && code.data) {
                            isScanning = false;
                            sendAttendance(code.data);
                        }
                    }
                }
                requestAnimationFrame(tick);
            }

            function sendAttendance(qrData) {
                monitor.className = "panel monitor";
                monIcon.style.color = "#445";
                monIcon.innerText = "⏳"; monMain.innerText = "CHECKING..."; monSub.innerText = "照合中";

                const formData = new FormData();
                formData.append("qrData", qrData);

                fetch('${pageContext.request.contextPath}/AttendanceServlet', { method: 'POST', body: formData })
                .then(res => res.text())
                .then(text => {
                    playSound("ok");
                    speak("QRコード読み取り完了しました");
                    monitor.classList.add("res-ok");
                    monIcon.innerText = "✔"; monMain.innerText = "認証完了";
                    monSub.innerText = text.replace("SUCCESS:", "").replace("REQUIRE_REASON:", "【要申請】");

                    setTimeout(() => {
                        monitor.className = "panel monitor";
                        monIcon.innerText = "⌖"; monMain.innerText = "STANDBY"; monSub.innerText = "QRコードをスキャンしてください";
                        isScanning = true;
                    }, 3000);
                })
                .catch(err => {
                    playSound("error");
                    monitor.classList.add("res-ng");
                    monIcon.innerText = "✖"; monMain.innerText = "警告"; monSub.innerText = "通信失敗";

                    setTimeout(() => {
                        monitor.className = "panel monitor";
                        monIcon.innerText = "⌖"; monMain.innerText = "STANDBY"; monSub.innerText = "学生証をスキャンしてください";
                        isScanning = true;
                    }, 3000);
                });
            }
        }
    </script>
</body>
</html>