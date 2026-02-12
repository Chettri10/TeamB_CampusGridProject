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

    // ★このページを開いたときは、過去の「スキャン済み」セッション情報を強制クリアする
    // これにより、ホームから戻ってきたときに理由入力画面が出るのを防ぎます
    session.removeAttribute("qr_scanned");
    session.removeAttribute("scanned_user_id");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="mobile-web-app-capable" content="yes">

<title>デジタル学生証</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<style>
    /* デザイン設定 */
    :root { --sat: env(safe-area-inset-top, 50px); }
    html { background-color: #000; height: 100%; }
    body {
        background-color: #020617; color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        text-align: center; padding: 0; user-select: none;
        min-height: 100vh; margin: 0 auto; max-width: 430px;
        position: relative; display: flex; flex-direction: column;
        align-items: center; padding-top: calc(var(--sat) + 20px);
        overscroll-behavior-y: none;
    }

    /* 学生証カード */
    .card {
        background-color: #151f42; padding: 25px; border-radius: 20px;
        display: inline-block; box-shadow: 0 0 30px rgba(0,255,255,0.15);
        position: relative; overflow: hidden; width: 370px; max-width: 90%; margin-top: 10px;
    }
    .animated-border {
        position: absolute; top: 0; left: 0; right: 0; bottom: 0;
        border: 4px solid transparent; border-radius: 20px;
        background: linear-gradient(45deg, #00ffff, #002bff, #7a00ff, #00ffff);
        background-size: 400%; z-index: -1; animation: glowing 10s linear infinite;
    }
    @keyframes glowing { 0% { background-position: 0 0; } 50% { background-position: 400% 0; } 100% { background-position: 0 0; } }
    .card-inner {
        background: #020617; border-radius: 16px; padding: 25px 20px;
        height: 100%; display: flex; flex-direction: column;
        align-items: center; box-sizing: border-box;
    }
    h1 { color: #00ffff; margin: 0; font-size: 26px; font-weight: bold; letter-spacing: 1px; }
    .student-id { font-size: 22px; font-weight: bold; margin: 20px 0 5px 0; color: white; }
    .id-number { font-size: 15px; color: #8892b0; margin-bottom: 25px; }

    /* QRコードエリア */
    #qrcode {
        margin: 10px auto; display: flex; justify-content: center; align-items: center;
        padding: 15px; background: white; border-radius: 12px; width: 240px; height: 240px;
    }
    #qrcode img { display: block; }

    /* プログレスバー */
    .progress-bar { width: 100%; height: 6px; background-color: #1e293b; margin-top: 25px; overflow: hidden; border-radius: 3px; }
    .progress-fill { height: 100%; background-color: #00ffff; width: 100%; animation: countdown 5s linear infinite; }
    @keyframes countdown { from { width: 100%; background-color: #00ffff; } to { width: 0%; background-color: #ff5252; } }

    .home-link {
        display: inline-block; margin-top: 50px; color: #00ffff; text-decoration: none;
        font-weight: bold; border: 1px solid #00ffff; padding: 14px 40px;
        border-radius: 12px; transition: 0.3s; font-size: 16px; cursor: pointer;
    }
    .home-link:active { background: rgba(0, 255, 255, 0.3); transform: scale(0.95); }

    /* セキュリティマスク */
    #mask {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(2, 6, 23, 0.98); color: white;
        z-index: 9999; display: none; flex-direction: column;
        justify-content: center; align-items: center;
    }

    /* 入力モーダル */
    #reasonModal {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.9); z-index: 9998;
        justify-content: center; align-items: center; flex-direction: column;
        backdrop-filter: blur(5px);
    }
    .modal-content {
        background: #151f42; width: 85%; max-width: 400px;
        padding: 30px; border-radius: 20px; border: 2px solid #00ffff;
        box-shadow: 0 0 50px rgba(0,255,255,0.2); text-align: center;
        transition: all 0.3s ease;
    }
    input[type="text"] {
        width: 100%; padding: 15px; margin: 20px 0;
        background: rgba(255,255,255,0.1); border: 1px solid #334155;
        border-radius: 10px; font-size: 16px; color: white; box-sizing: border-box;
    }
    #fileInputContainer {
        display: none; margin-bottom: 20px; padding: 15px;
        border: 2px dashed #00ffff; cursor: pointer; color: #00ffff;
        background: rgba(0, 255, 255, 0.05); border-radius: 10px;
    }
    #certAlert {
        display: none; color: #ff5252; font-size: 14px; font-weight: bold; margin-bottom: 10px;
    }

    .submit-btn {
        background: linear-gradient(135deg, #007bff, #00d4ff);
        color: white; border: none; padding: 15px; width: 100%;
        border-radius: 30px; font-size: 18px; font-weight: bold; cursor: pointer;
        transition: 0.3s;
    }
    .submit-btn:disabled {
        background: #555; color: #aaa; cursor: not-allowed; opacity: 0.6;
    }
    .success-icon { font-size: 50px; color: #00ff9d; margin-bottom: 10px; display: block; }
</style>
</head>
<body>

<div id="mask">
    <div style="font-size: 60px; color: #ff5252; margin-bottom: 20px;">⚠️</div>
    <h2>表示が中断されました</h2>
    <p>セキュリティ保護のため<br>再表示してください。</p>
    <button onclick="location.reload()" style="padding:15px 30px; font-size:18px; background:#00ffff; border:none; border-radius:10px; font-weight:bold; cursor:pointer;">再表示する</button>
</div>

<div id="reasonModal">
    <div class="modal-content" id="modalBody">
        <h2 style="color:#ff5252; margin-top:0;">⚠️ 理由の入力</h2>
        <p style="color:#aab;">スキャンされました。<br>理由を入力してください。</p>

        <input type="text" id="reasonInput" placeholder="理由 (例: 電車遅延、体調不良)" oninput="checkReason()">

        <div id="certAlert">※ 電車遅延の場合は証明書が必要です</div>

        <div id="fileInputContainer" onclick="document.getElementById('certificateInput').click()">
            <span id="fileName">📸 タップして証明書を選択</span>
            <input type="file" id="certificateInput" accept="image/*" style="display:none" onchange="fileSelected(this)">
        </div>

        <button id="submitBtn" class="submit-btn" onclick="submitUpdate()">登録する</button>
    </div>
</div>

<div class="card">
    <div class="animated-border"></div>
    <div class="card-inner">
        <h1>DIGITAL ID</h1>
        <div class="student-id"><%= myName %> 様</div>
        <div class="id-number">ID: <%= myId %></div>
        <div id="qrcode"></div>
        <div class="progress-bar"><div class="progress-fill" id="p-bar"></div></div>
        <p style="font-size:12px; color:#8892b0; margin-top:20px;">
            5秒ごとに自動更新されます<br>
            <span style="color:#ff5252; font-weight:bold;">スクリーンショット無効</span>
        </p>
        <div id="statusText" style="margin-top:5px; font-size:12px; color:#00ff9d;">● Online</div>
    </div>
</div>

<br>
<a href="javascript:void(0)" onclick="goToHome()" class="home-link">ホームへ戻る</a>

<script>
    const userId = "<%= myId %>";
    let qrContainer = document.getElementById("qrcode");
    let isModalOpen = false; // 入力中フラグ
    let isFileRequired = false;

    // ★【修正】1日ロック(localStorage)は廃止し、
    // 「この画面を開いている間、送信が完了したかどうか」だけのフラグにする
    let isSessionDone = false;

    function goToHome() {
        window.location.href = "${pageContext.request.contextPath}/LogIn/student_home.jsp";
    }

    // QRコード生成
    function generateQR() {
        qrContainer.innerHTML = "";
        const now = new Date().getTime();
        const qrData = userId + "," + now;
        new QRCode(qrContainer, { text: qrData, width: 210, height: 210, correctLevel : QRCode.CorrectLevel.H });
        const bar = document.getElementById("p-bar");
        bar.style.animation = 'none'; bar.offsetHeight; bar.style.animation = 'countdown 5s linear infinite';
    }
    generateQR();
    setInterval(generateQR, 5000);

    // ★★★ 修正箇所: ポーリング処理 ★★★
    function startPolling() {
        setInterval(function() {
            // 入力中、マスク中、または「今回すでに送信完了した」場合は何もしない
            if(isModalOpen || document.getElementById("mask").style.display === "flex") return;
            if(isSessionDone) return; // 送信完了後はチェックしない

            const ts = new Date().getTime();

            fetch('${pageContext.request.contextPath}/AttendanceServlet?action=check_status&userId=' + userId + '&t=' + ts)
            .then(res => res.text())
            .then(status => {
                // A. サーバーが「理由入力待ち(SCANNED)」と言ってきたらモーダルを出す
                if (status.includes("SCANNED")) {
                    if (!isModalOpen) {
                        isModalOpen = true;
                        document.getElementById("reasonModal").style.display = "flex";
                        document.getElementById("statusText").innerText = "⚠ 理由入力待ち";
                        document.getElementById("statusText").style.color = "#ff5252";
                    }
                }
                // B. 完了状態なら緑色にする
                else if (status.includes("_DONE")) {
                     let msg = "登録済み";
                     if(status.includes("出席")) msg = "出席 完了";
                     if(status.includes("遅刻")) msg = "遅刻 完了";
                     if(status.includes("早退")) msg = "早退 完了";
                     if(status.includes("下校")) msg = "下校 完了";

                     document.getElementById("statusText").innerText = "✔ " + msg;
                     document.getElementById("statusText").style.color = "#00ff9d";

                     // モーダルが開いていたら閉じる
                     document.getElementById("reasonModal").style.display = "none";
                     isModalOpen = false;
                }
            }).catch(e => {});
        }, 2000);
    }
    // ページ読み込み時にポーリング開始
    startPolling();

    // 理由入力チェック
    function checkReason() {
        const text = document.getElementById("reasonInput").value;
        const box = document.getElementById("fileInputContainer");
        const alertMsg = document.getElementById("certAlert");
        const btn = document.getElementById("submitBtn");
        const fileInput = document.getElementById("certificateInput");

        if (text.includes("遅延") || text.includes("電車") || text.includes("事故") || text.includes("運休")) {
            isFileRequired = true;
            box.style.display = "block";
            alertMsg.style.display = "block";

            if (fileInput.files.length === 0) {
                btn.disabled = true;
                btn.innerText = "証明書を選択してください";
                btn.style.background = "#555";
            } else {
                btn.disabled = false;
                btn.innerText = "登録する";
                btn.style.background = "linear-gradient(135deg, #007bff, #00d4ff)";
            }
        } else {
            isFileRequired = false;
            box.style.display = "none";
            alertMsg.style.display = "none";
            btn.disabled = false;
            btn.innerText = "登録する";
            btn.style.background = "linear-gradient(135deg, #007bff, #00d4ff)";
        }
    }

    // ファイル選択
    function fileSelected(input) {
        if (input.files.length > 0) {
            document.getElementById('fileName').innerText = "✅ " + input.files[0].name;
            checkReason();
        }
    }

    // ★★★ 修正箇所: 送信処理 ★★★
    function submitUpdate() {
        const reason = document.getElementById("reasonInput").value;
        const fileInput = document.getElementById("certificateInput");

        if(!reason) return alert("理由を入力してください");

        if (isFileRequired && fileInput.files.length === 0) {
            alert("この理由の場合は証明書の画像が必要です。");
            return;
        }

        const btn = document.getElementById("submitBtn");
        btn.disabled = true;
        btn.innerText = "送信中...";

        const formData = new FormData();
        formData.append("mode", "update_reason");
        formData.append("userId", userId);
        formData.append("reason", reason);
        if(fileInput.files.length > 0) formData.append("certificateImage", fileInput.files[0]);

        fetch('${pageContext.request.contextPath}/AttendanceServlet', { method: 'POST', body: formData })
        .then(res => res.text())
        .then(text => {
            if(text.includes("SUCCESS")) {
                // ★送信成功したら「今回のセッションは完了」とする
                isSessionDone = true;
                isModalOpen = false;

                const modalBody = document.getElementById("modalBody");
                modalBody.innerHTML = `
                    <div class="success-icon">✔</div>
                    <h2 style="color:#00ff9d;">登録完了</h2>
                    <p>理由を登録しました。</p>
                    <p style="font-size:14px; color:#aaa; margin-top:20px;">5秒後にホームへ戻ります...</p>
                `;

                // ホーム画面のステータス表示も更新
                document.getElementById("statusText").innerText = "✔ 登録完了";
                document.getElementById("statusText").style.color = "#00ff9d";

                setTimeout(() => { goToHome(); }, 5000);
            } else {
                alert("エラーが発生しました。もう一度お試しください。");
                btn.disabled = false;
                btn.innerText = "登録する";
            }
        })
        .catch(err => {
            alert("送信に失敗しました。");
            btn.disabled = false;
            btn.innerText = "登録する";
        });
    }

    // セキュリティマスク (入力中は出さない)
    document.addEventListener("visibilitychange", function() {
        if (isModalOpen) return;
        if (document.hidden) {
            document.getElementById("mask").style.display = "flex";
        }
    });

    window.onblur = function() {
        if (isModalOpen) return;
        document.getElementById("mask").style.display = "flex";
    };
</script>
</body>
</html>