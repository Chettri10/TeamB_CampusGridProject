<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><title>Error</title></head>
<body style="background:#020617; color:white; text-align:center; padding-top:50px;">
    <h2>エラーが発生しました</h2>
    <p style="color:red;"><%= request.getAttribute("error") %></p>
    <a href="cart.jsp" style="color:#00ffff;">戻る</a>
</body>
</html>