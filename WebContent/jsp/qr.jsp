<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Servlet.QRCodeTimer" %>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>キャンパスグリッド - QRコード表示</title>
<meta name="viewport" content="width=430, initial-scale=1.0">

<style>
    body {
        background-color: #00144a;
        color: white;
        font-family: "Meiryo", sans-serif;
        text-align: center;
        margin: 0;
        padding: 0;
    }
    .container {
        max-width: 380px;
        margin: 0 auto;
        padding-top: 30px;
    }
    h1 { font-size: 26px; font-weight: bold; margin-bottom: 10px; }
    h2 { font-size: 20px; margin-bottom: 25px; color: #a8f5ff; }
    .qr-image { width: 220px; height: 220px; margin: 0 auto 20px; background-color: white; border-radius: 12px; padding: 10px; }
    .countdown { font-size: 18px; color: #aeeaff; margin-bottom: 20px; }
    .expired-message { font-size: 18px; color: #ffaaaa; margin-top: 10px; display: none; }
    .btn {
        background-color: #7eeaff;
        color: black;
        font-size: 18px;
        font-weight: bold;
        padding: 12px 20px;
        border-radius: 12px;
        text-decoration: none;
        display: inline-block;
        margin: 10px;
        cursor: pointer;
    }
</style>

<script>
    let timeLeft = 30;
    let timer;

    function updateCountdown() {
        const countdownEl = document.getElementById("countdown");
        const qrEl = document.getElementById("qr-code");
        const expiredEl = document.getElementById("expired-msg");

        if (timeLeft > 0) {
            countdownEl.textContent = "有効時間: " + timeLeft + "秒";
            timeLeft--;
        } else {
            qrEl.style.display = "none";
            expiredEl.style.display = "block";
            countdownEl.style.display = "none";
            clearInterval(timer);
        }
    }

    function startTimer() {
        timeLeft = 30;
        document.getElementById("qr-code").style.display = "block";
        document.getElementById("expired-msg").style.display = "none";
        document.getElementById("countdown").style.display = "block";
        updateCountdown();
        timer = setInterval(updateCountdown, 1000);
    }

    window.onload = function() {
        startTimer();
    };
</script>
</head>
<body>

<div class="container">

    <h1>キャンパス グリッド</h1>
    <h2>QRコードを表示</h2>

    <!-- カウントダウン表示 -->
    <div class="countdown" id="countdown"></div>

    <!-- QRコード画像 -->
    <div class="qr-image" id="qr-code">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=student-attendance"
             alt="QRコード" width="200" height="200">
    </div>

    <!-- 有効期限切れメッセージ -->
    <div class="expired-message" id="expired-msg">
        ※このQRコードは有効期限が切れました
    </div>

    <!-- 再表示ボタン -->
    <button class="btn" onclick="startTimer()">再表示</button>

    <!-- 戻るボタン -->
    <a href="index.jsp" class="btn">戻る</a>

</div>

</body>
</html>
