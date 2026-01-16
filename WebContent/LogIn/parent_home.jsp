<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>保護者ホーム</title>
</head>
<body style="background-color: #f3e5f5; text-align: center; padding: 50px;">
    <h1>保護者専用ページ</h1>
    <p>ようこそ、<%= session.getAttribute("userName") %> 様</p>

    <p>お子様の出席状況やお知らせを確認できます。</p>
    </body>
</html>