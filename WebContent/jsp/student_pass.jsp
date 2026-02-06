<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String myId = (String)session.getAttribute("userId");
    // ログインチェック
    if(myId == null || !myId.startsWith("S")) {
        response.sendRedirect("../LogIn/login.jsp");
        return;
    }
    String myName = (String)session.getAttribute("userName");
    if(myName == null) myName = "学生";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<title>デジタル学生証</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<style>
    :root {
        --sat: env(safe-area-inset-top, 50px);
    }

    /* 基本設定（ダークテーマ） */
    html { background-color: #000; height: 100%; }
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        text-align: center;
        padding: 0;
        margin: 0 auto;
        user-select: none;
        min-height: 100vh;
        max-width: 430px; /* スマホサイズ固定 */
        display: flex;
        flex-direction: column;
        align-items: center;
        padding-top: calc(var(--sat) + 20px);
        position: relative;
    }

    /* --- 学生証カードデザイン --- */
    .card {
        background-color: #151f42;
        padding: 25px;
        border-radius: 20px;
        display: inline-block;
        box-shadow: 0 0 30px rgba(0,255,255,0.15);
        position: relative;
        overflow: hidden;
        width: 370px;
        max-width: 90%;
        margin-top: 10px;
        z-index: 10;
    }

    /* 光る枠線のアニメーション */
    .animated-border {
        position: absolute; top: 0; left: 0; right: 0; bottom: 0;
        border: 4px solid transparent; border-radius: 20px;
        background: linear-gradient(45deg, #00ffff, #002bff, #7a00ff, #00ffff);
        background-size: 400%; z-index: -1; animation: glowing 10s linear infinite;
    }
    @keyframes glowing { 0% { background-position: 0 0; } 50% { background-position: 400% 0; } 100% { background-position: 0 0; } }

    .card-inner {
        background: #020617;
        border-radius: 16px;
        padding: 25px 20px;
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    h1 { color: #00ffff; margin: 0; font-size: 26px; font-weight: bold; letter-spacing: 1px; }
    .student-id { font-size: 22px; font-weight: bold; margin: 20px 0 5px 0; color: white; }
    .id-number { font-size: 15px; color: #8892b0; margin-bottom: 25px; }

    /* QRコードエリア */
    #qrcode {
        margin: 10px auto;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 15px;
        background: white;
        border-radius: 12px;
        width: 210px;
        height: 210px;
    }
    #qrcode img { display: block; }

    /* プログレスバー（残り時間） */
    .progress-bar { width: 100%; height: 6px; background-color: #1e293b; margin-top: 25px; overflow: hidden; border-radius: 3px; }
    .progress-fill { height: 100%; background-color: #00ffff; width: 100%; animation: countdown 5s linear infinite; }
    @keyframes countdown { from { width: 100%; background-color: #00ffff; } to { width: 0%; background-color: #ff5252; } }

    /* ステータスメッセージ */
    #statusMsg { margin-top: 15px; font-weight: bold; color: #00ffff; min-height: 24px; animation: pulse 2s infinite; }
    @keyframes pulse { 0% { opacity: 0.6; } 50% { opacity: 1; } 100% { opacity: 0.6; } }

    /* ホームへ戻るリンク */
    .home-link {
        display: inline-block; margin-top: 40px; color: #8892b0;
        text-decoration: none; font-size: 14px; border: 1px solid #334155;
        padding: 10px 20px; border-radius: 20px;
    }

    /* --- 入力モーダル（かっこいいデザイン） --- */
    #reasonModal {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(2, 6, 23, 0.95); z-index: 1000;
        justify-content: center; align-items: center; flex-direction: column;
        backdrop-filter: blur(5px);
    }
    .modal-content {
        background: #151f42; width: 85%; max-width: 400px;
        border-radius: 20px; padding: 30px; border: 1px solid #00ffff;
        box-shadow: 0 0 50px rgba(0, 255, 255, 0.2);
        text-align: center;
        animation: popUp 0.3s ease-out;
    }
    @keyframes popUp { from { transform: scale(0.8); opacity: 0; } to { transform: scale(1); opacity: 1; } }

    .modal-title { font-size: 22px; color: #ff5252; margin-bottom: 20px; font-weight: bold; }

    input[type="text"] {
        width: 100%; padding: 15px; background: #020617; border: 1px solid #334155;
        color: white; border-radius: 12px; font-size: 16px; margin-bottom: 20px;
        box-sizing: border-box; outline: none; transition: 0.3s;
    }
    input[type="text"]:focus { border-color: #00ffff; box-shadow: 0 0 10px rgba(0,255,255,0.3); }

    /* 画像アップロード */
    #fileInputContainer { display: none; margin-bottom: 20px; }
    .file-box {
        border: 2px dashed #00ffff; padding: 20px; border-radius: 12px;
        background: rgba(0, 255, 255, 0.05); cursor: pointer;
    }
    .file-label { display: block; color: #00ffff; font-size: 14px; margin-bottom: 5px; }

    /* 送信ボタン */
    .submit-btn {
        background: linear-gradient(90deg, #00c6ff, #0072ff);
        color: white; border: none; padding: 15px; width: 100%;
        border-radius: 30px; font-size: 18px; font-weight: bold; cursor: pointer;
        box-shadow: 0 5px 20px rgba(0, 114, 255, 0.4);
    }
    .submit-btn:active { transform: scale(0.98); }

    /* マスク（スクショ防止） */
    #mask {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(2, 6, 23, 0.98); color: white;
        z-index: 9999; display: none; flex-direction: column;
        justify-content: center; align-items: center;
    }
</style>
</head>
<body>

    <div id="mask">
        <div style="font-size: 60px; color: #ff5252; margin-bottom: 20px;">⚠️</div>
        <h2>表示が中断されました</h2>
        <button onclick="location.reload()" style="padding:15px 30px; font-size:18px; background:#00ffff; border:none; border-radius:10px; font-weight:bold;">再表示</button>
    </div>

    <div class="card">
        <div class="animated-border"></div>
        <div class="card-inner">
            <h1>DIGITAL ID</h1>
            <div class="student-id"><%= myName %> 様</div>
            <div class="id-number">ID: <%= myId %></div>
            <div id="qrcode"></div>
            <div class="progress-bar"><div class="progress-fill" id="p-bar"></div></div>
            <div id="statusMsg">スキャン待機中...</div>
        </div>
    </div>

    <a href="${pageContext.request.contextPath}/LogIn/student_home.jsp" class="home-link">ホームへ戻る</a>

    <div id="reasonModal">
        <div class="modal-content">
            <div class="modal-title">⚠️ 遅刻・早退の申請</div>
            <p style="color:#ccc; font-size:14px; margin-bottom:20px;">スキャンを確認しました。<br>理由を入力してください。</p>

            <input type="text" id="reasonInput" placeholder="理由 (例: 電車遅延、体調不良)" oninput="checkReason()">

            <div id="fileInputContainer">
                <span class="file-label">📸 証明書画像 (必須)</span>
                <div class="file-box" onclick="document.getElementById('certificateInput').click()">
                    <span id="fileName">タップして写真を選択</span>
                    <input type="file" id="certificateInput" accept="image/*" style="display:none" onchange="document.getElementById('fileName').innerText=this.files[0].name">
                </div>
            </div>

            <button class="submit-btn" onclick="submitUpdate()">登録する</button>
        </div>
    </div>

    <script>
        const userId = "<%= myId %>";
        let isScanned = false; // 二重表示防止フラグ

        // --- 1. QRコード生成 (デザイン重視) ---
        function generateQR() {
            const container = document.getElementById("qrcode");
            container.innerHTML = "";
            const now = new Date().getTime();
            const qrData = userId + "," + now;
            new QRCode(container, { text: qrData, width: 210, height: 210 });

            // プログレスバーのアニメーションをリセットして同期させる
            const bar = document.getElementById("p-bar");
            bar.style.animation = 'none';
            bar.offsetHeight; /* trigger reflow */
            bar.style.animation = 'countdown 5s linear infinite';
        }
        generateQR();
        setInterval(generateQR, 5000);

        // --- 2. サーバー監視 (スキャンされたかチェック) ---
        setInterval(checkStatus, 2000); // 2秒ごとに確認

        function checkStatus() {
            if(isScanned) return; // すでに画面が出ていればチェックしない

            // Servletに「自分はスキャンされましたか？」と聞く
            fetch('${pageContext.request.contextPath}/AttendanceServlet?action=check_status&userId=' + userId)
            .then(res => res.text())
            .then(status => {
                if (status.trim().includes("SCANNED")) {
                    // スキャン済みなら入力画面を出す
                    isScanned = true;
                    document.getElementById("statusMsg").innerText = "スキャン完了！入力してください";
                    openModal();
                }
            })
            .catch(e => console.log("通信待機中..."));
        }

        // --- 3. 入力制御 (電車遅延なら画像欄を出す) ---
        function checkReason() {
            const text = document.getElementById("reasonInput").value;
            const box = document.getElementById("fileInputContainer");
            // キーワード判定
            if (text.includes("遅延") || text.includes("電車") || text.includes("事故") || text.includes("バス") || text.includes("遅れ")) {
                box.style.display = "block";
            } else {
                box.style.display = "none";
            }
        }

        function openModal() { document.getElementById("reasonModal").style.display = "flex"; }
        function closeModal() { document.getElementById("reasonModal").style.display = "none"; }

        // --- 4. 送信処理 ---
        function submitUpdate() {
            const reason = document.getElementById("reasonInput").value;
            const fileInput = document.getElementById("certificateInput");

            if(!reason) { alert("理由を入力してください"); return; }

            const btn = document.querySelector(".submit-btn");
            btn.innerText = "送信中...";
            btn.disabled = true;

            const formData = new FormData();
            formData.append("mode", "update_reason"); // 更新モードを指定
            formData.append("userId", userId);
            formData.append("reason", reason);
            if(fileInput.files.length > 0) {
                formData.append("certificateImage", fileInput.files[0]);
            }

            fetch('${pageContext.request.contextPath}/AttendanceServlet', {
                method: 'POST',
                body: formData
            }).then(res => res.text()).then(text => {
                if(text.includes("SUCCESS")) {
                    alert("登録が完了しました！");
                    closeModal();
                    document.getElementById("statusMsg").innerText = "出席完了";
                    document.getElementById("statusMsg").style.color = "#28a745";
                } else {
                    alert("エラーが発生しました: " + text);
                    btn.disabled = false;
                    btn.innerText = "登録する";
                }
            });
        }

        // セキュリティ (タブ切り替えで隠す)
        document.addEventListener("visibilitychange", function() {
            if (document.hidden) document.getElementById("mask").style.display = "flex";
        });
    </script>
</body>
</html>