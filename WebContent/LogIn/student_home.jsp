<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>学生ホーム</title>
</head>
<body style="background-color: #e0f7fa; text-align: center; padding: 50px;">
    <h1>学生用ダッシュボード</h1>
    <p>ようこそ、<%= session.getAttribute("userName") %> さん (ID: <%= session.getAttribute("userId") %>)</p>

    <a href="ChatServlet?myId=<%= session.getAttribute("userId") %>&targetId=S00001">先生とチャット</a><br><br>
    <a href="qr_scan.jsp">出席QRスキャン</a>
</body>
</html>