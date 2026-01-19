<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String myId = (String)session.getAttribute("userId");
    if(myId == null || !myId.startsWith("S")) {
        response.sendRedirect("login.jsp");
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
    body { background-color: #e0f7fa; color: #333; font-family: sans-serif; text-align: center; padding: 20px; user-select: none; }
    .card {
        background-color: white; padding: 20px; border-radius: 15px;
        display: inline-block; box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        position: relative; overflow: hidden; width: 300px;
    }
    /* キラキラ枠アニメーション */
    .animated-border {
        position: absolute; top: 0; left: 0; right: 0; bottom: 0;
        border: 5px solid transparent; border-radius: 15px;
        background: linear-gradient(45deg, #ff0000, #ff7300, #fffb00, #48ff00, #00ffd5, #002bff, #7a00ff, #ff00c8, #ff0000);
        background-size: 400%; z-index: -1; animation: glowing 20s linear infinite;
    }
    @keyframes glowing {
        0% { background-position: 0 0; } 50% { background-position: 400% 0; } 100% { background-position: 0 0; }
    }
    .card-inner { background: white; border-radius: 12px; padding: 20px; height: 100%; }
    h1 { color: #00bcd4; margin: 0; font-size: 22px; }
    .student-id { font-size: 20px; font-weight: bold; margin: 10px 0; }
    #qrcode { margin: 20px auto; display: flex; justify-content: center; }

    /* 秒読みバー */
    .progress-bar { width: 100%; height: 5px; background-color: #eee; margin-top: 15px; overflow: hidden; border-radius: 3px; }
    .progress-fill { height: 100%; background-color: #00bcd4; width: 100%; animation: countdown 5s linear infinite; }
    @keyframes countdown { from { width: 100%; background-color: #00bcd4; } to { width: 0%; background-color: #ff5252; } }

    /* 隠す時のマスク */
    #mask {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.95); color: white; z-index: 9999;
        display: none; flex-direction: column; justify-content: center; align-items: center;
    }
    .warning-icon { font-size: 50px; color: #ff5252; margin-bottom: 20px; }
</style>
</head>
<body>
    <div id="mask">
        <div class="warning-icon">⚠️</div>
        <h2>表示が中断されました</h2>
        <p>画面を切り替えたり閉じたりすると<br>QRコードは無効になります。</p>
        <button onclick="location.reload()" style="padding:10px 20px; font-size:18px;">再表示</button>
    </div>

    <div class="card">
        <div class="animated-border"></div>
        <div class="card-inner">
            <h1>デジタル学生証</h1>
            <div class="student-id"><%= session.getAttribute("userName") %> 様</div>
            <div>ID: <%= myId %></div>
            <div id="qrcode"></div>
            <div class="progress-bar"><div class="progress-fill" id="p-bar"></div></div>
            <p style="font-size:12px; color:#888; margin-top:10px;">5秒ごとに自動更新されます<br><span style="color:#ff5252;">スクショは無効です</span></p>
        </div>
    </div>
    <br><br><a href="student_home.jsp">ホームに戻る</a>

    <script>
        const userId = "<%= myId %>";
        let qrContainer = document.getElementById("qrcode");

        function generateQR() {
            qrContainer.innerHTML = "";
            const now = new Date().getTime();
            const qrData = userId + "," + now;
            new QRCode(qrContainer, { text: qrData, width: 180, height: 180, correctLevel : QRCode.CorrectLevel.H });

            const bar = document.getElementById("p-bar");
            bar.style.animation = 'none'; bar.offsetHeight; bar.style.animation = 'countdown 5s linear infinite';
        }
        generateQR();
        setInterval(generateQR, 5000); // 5秒更新

        document.addEventListener("visibilitychange", function() {
            if (document.hidden) document.getElementById("mask").style.display = "flex";
        });
        window.onblur = function() { document.getElementById("mask").style.display = "flex"; };
    </script>
</body>
</html>