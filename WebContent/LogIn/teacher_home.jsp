<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>先生ホーム</title>
</head>
<body style="background-color: #fff3e0; text-align: center; padding: 50px;">
    <h1>教員用管理画面</h1>
    <p>ようこそ、<%= session.getAttribute("userName") %> 先生</p>

    <a href="UserListServlet?myId=<%= session.getAttribute("userId") %>">チャット一覧</a><br><br>
    <a href="qr_generator.jsp">出席QRコード表示</a>
</body>
</html>