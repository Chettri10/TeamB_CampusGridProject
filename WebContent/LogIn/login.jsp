<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ログイン - Campus Grid</title>
<style>
    body { background-color: #020617; color: white; display: flex; justify-content: center; align-items: center; height: 100vh; font-family: sans-serif; }
    .login-box { background-color: #151f42; padding: 40px; border-radius: 10px; text-align: center; width: 300px; }
    input { width: 100%; padding: 10px; margin: 10px 0; border-radius: 5px; border: none; }
    button { width: 100%; padding: 10px; background-color: #00ffff; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; }
    .error { color: #ff453a; font-size: 14px; }
</style>
</head>
<body>
    <div class="login-box">
        <h2>Campus Grid Login</h2>

        <% String error = (String)request.getAttribute("errorMsg"); %>
        <% if(error != null) { %>
            <p class="error"><%= error %></p>
        <% } %>

        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
            <input type="text" name="userId" placeholder="ユーザーID (例: G00001)" required>
            <input type="password" name="password" placeholder="パスワード" required>
            <button type="submit">ログイン</button>
        </form>

        <p style="font-size:12px; color:#aaa; margin-top:20px;">
            S...学生 / T...先生 / P...保護者
        </p>
    </div>
</body>
</html>