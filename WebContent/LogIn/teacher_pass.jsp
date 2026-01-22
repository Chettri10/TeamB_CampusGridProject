<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String myId = (String)session.getAttribute("userId");
    if(myId == null || !myId.startsWith("T")) {
        response.sendRedirect("../LogIn/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<title>教員用QRコード</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<style>
    body { background-color: #f3f4f6; color: #333; font-family: sans-serif; text-align: center; padding: 20px; user-select: none; }
    .card {
        background-color: white; padding: 20px; border-radius: 15px;
        display: inline-block; box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        position: relative; overflow: hidden; width: 300px;
    }
    h1 { color: #007acc; margin: 0; font-size: 22px; }
    .teacher-id { font-size: 20px; font-weight: bold; margin: 10px 0; }
    #qrcode { margin: 20px auto; display: flex; justify-content: center; }
    .note { font-size: 12px; color: #888; margin-top: 10px; }
</style>
</head>
<body>

    <div class="card">
        <h1>教員用QRコード</h1>
        <div class="teacher-id"><%= session.getAttribute("userName") %> 先生</div>
        <div>ID: <%= myId %></div>
        <div id="qrcode"></div>
        <p class="note">このQRコードは出席確認用です</p>
    </div>

    <br><br>
    <a href="../teacher_home.jsp">ホームに戻る</a>

    <script>
        const userId = "<%= myId %>";
        const qrContainer = document.getElementById("qrcode");
        const now = new Date().getTime();
        const qrData = "teacher," + userId + "," + now;

        new QRCode(qrContainer, {
            text: qrData,
            width: 180,
            height: 180,
            correctLevel : QRCode.CorrectLevel.H
        });
    </script>
</body>
</html>
