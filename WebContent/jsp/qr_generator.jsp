<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>出席QRコード</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<style>
    body { background-color: #020617; color: white; font-family: sans-serif; text-align: center; padding: 40px; }
    #qrcode { background-color: white; padding: 20px; display: inline-block; border-radius: 10px; margin: 20px; }
    .timer { font-size: 32px; color: #ff453a; font-weight: bold; }
    button { padding: 15px 30px; font-size: 18px; background-color: #00ffff; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; }
    .hidden { display: none; }
    .desc { color: #8892b0; font-size: 14px; }
</style>
</head>
<body>
    <h1>出席登録</h1>
    <p class="desc">学生はスマホで読み取ってください (30秒更新)</p>

    <div id="qr-container">
        <div id="qrcode"></div>
        <p>有効期限: <span id="timer" class="timer">30</span> 秒</p>
    </div>

    <div id="expired-msg" class="hidden">
        <h2 style="color:#aaa;">QRコードが無効になりました</h2>
        <button onclick="generateQR()">再表示する</button>
    </div>

    <script>
        let interval;

        function generateQR() {
            document.getElementById("qr-container").classList.remove("hidden");
            document.getElementById("expired-msg").classList.add("hidden");
            document.getElementById("qrcode").innerHTML = "";

            const now = new Date().getTime();

            // ★重要: スマホで読み取るなら localhost ではなく PCのIPアドレスに書き換えてください
            // 例: http://192.168.1.10:8080/...
            const url = "http://localhost:8080/CampusGrid/AttendanceServlet?ts=" + now;

            new QRCode(document.getElementById("qrcode"), {
                text: url,
                width: 250, height: 250
            });

            let timeLeft = 30;
            document.getElementById("timer").innerText = timeLeft;

            if(interval) clearInterval(interval);

            interval = setInterval(function() {
                timeLeft--;
                document.getElementById("timer").innerText = timeLeft;
                if(timeLeft <= 0) {
                    clearInterval(interval);
                    document.getElementById("qr-container").classList.add("hidden");
                    document.getElementById("expired-msg").classList.remove("hidden");
                }
            }, 1000);
        }

        generateQR();
    </script>
</body>
</html>