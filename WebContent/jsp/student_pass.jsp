<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String myId = (String)session.getAttribute("userId");
    // ログインしてない場合、LogIn/login.jsp へリダイレクト
    if(myId == null || !myId.startsWith("S")) {
        response.sendRedirect("../LogIn/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>デジタル学生証</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<style>
    /* 全体をチャット画面と同じネイビーブラックに設定 */
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        text-align: center;
        padding: 20px;
        user-select: none;
        min-height: 100vh;
        margin: 0;
    }

    .card {
        background-color: #151f42; /* カード背景を少し明るい紺に */
        padding: 20px;
        border-radius: 15px;
        display: inline-block;
        box-shadow: 0 0 20px rgba(0,255,255,0.2);
        position: relative;
        overflow: hidden;
        width: 300px;
        margin-top: 50px;
    }

    .animated-border {
        position: absolute; top: 0; left: 0; right: 0; bottom: 0;
        border: 4px solid transparent; border-radius: 15px;
        /* サイバー感のあるグラデーション */
        background: linear-gradient(45deg, #00ffff, #002bff, #7a00ff, #00ffff);
        background-size: 400%; z-index: -1; animation: glowing 10s linear infinite;
    }

    @keyframes glowing { 0% { background-position: 0 0; } 50% { background-position: 400% 0; } 100% { background-position: 0 0; } }

    .card-inner {
        background: #020617; /* 内側をメイン背景色と同じに */
        border-radius: 12px;
        padding: 20px;
        height: 100%;
    }

    h1 { color: #00ffff; margin: 0; font-size: 22px; font-weight: bold; }

    .student-id { font-size: 20px; font-weight: bold; margin: 15px 0 5px 0; color: white; }
    .id-number { font-size: 14px; color: #8892b0; margin-bottom: 20px; }

    #qrcode {
        margin: 10px auto;
        display: flex;
        justify-content: center;
        padding: 10px;
        background: white; /* QRコード読み取りのため白背景を維持 */
        border-radius: 10px;
        width: 180px;
    }

    .progress-bar { width: 100%; height: 6px; background-color: #1e293b; margin-top: 20px; overflow: hidden; border-radius: 3px; }
    .progress-fill { height: 100%; background-color: #00ffff; width: 100%; animation: countdown 5s linear infinite; }

    @keyframes countdown {
        from { width: 100%; background-color: #00ffff; }
        to { width: 0%; background-color: #ff5252; }
    }

    .home-link {
        display: inline-block;
        margin-top: 40px;
        color: #00ffff;
        text-decoration: none;
        font-weight: bold;
        border: 1px solid #00ffff;
        padding: 10px 20px;
        border-radius: 8px;
        transition: 0.3s;
    }
    .home-link:hover { background: rgba(0, 255, 255, 0.1); }

    /* マスク画面 */
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
        <div style="font-size: 50px; color: #ff5252; margin-bottom: 20px;">⚠️</div>
        <h2>表示が中断されました</h2>
        <p>セキュリティ保護のため<br>画面を切り替えると無効化されます。</p>
        <button onclick="location.reload()" style="padding:12px 24px; font-size:16px; background:#00ffff; border:none; border-radius:8px; font-weight:bold; cursor:pointer;">再表示する</button>
    </div>

    <div class="card">
        <div class="animated-border"></div>
        <div class="card-inner">
            <h1>DIGITAL ID</h1>
            <div class="student-id"><%= session.getAttribute("userName") %> 様</div>
            <div class="id-number">ID: <%= myId %></div>
            <div id="qrcode"></div>
            <div class="progress-bar"><div class="progress-fill" id="p-bar"></div></div>
            <p style="font-size:11px; color:#8892b0; margin-top:15px;">5秒ごとに自動更新されます<br><span style="color:#ff5252; font-weight:bold;">スクリーンショット無効</span></p>
        </div>
    </div>

    <br>
    <a href="${pageContext.request.contextPath}/LogIn/student_home.jsp" class="home-link">ホームへ戻る</a>

    <script>
        const userId = "<%= myId %>";
        let qrContainer = document.getElementById("qrcode");

        function generateQR() {
            qrContainer.innerHTML = "";
            const now = new Date().getTime();
            const qrData = userId + "," + now;
            // ダークモードに合わせて少しQRを小さめに調整
            new QRCode(qrContainer, { text: qrData, width: 180, height: 180, correctLevel : QRCode.CorrectLevel.H });

            const bar = document.getElementById("p-bar");
            bar.style.animation = 'none'; bar.offsetHeight; bar.style.animation = 'countdown 5s linear infinite';
        }
        generateQR();
        setInterval(generateQR, 5000);

        document.addEventListener("visibilitychange", function() {
            if (document.hidden) document.getElementById("mask").style.display = "flex";
        });
        window.onblur = function() { document.getElementById("mask").style.display = "flex"; };
    </script>
</body>
</html>