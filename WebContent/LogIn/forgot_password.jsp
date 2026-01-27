<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>パスワード再設定 - Campus Grid</title>
<style>
    body { background-color: #020617; color: white; display: flex; justify-content: center; align-items: center; height: 100vh; font-family: sans-serif; }
    .box { background-color: #151f42; padding: 40px; border-radius: 10px; text-align: center; width: 350px; }
    input { width: 100%; padding: 10px; margin: 10px 0; border-radius: 5px; border: none; box-sizing: border-box;}
    button { width: 100%; padding: 10px; background-color: #ff5252; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; color: white; margin-top: 10px;}
    .back-link { display: block; margin-top: 20px; color: #aaa; text-decoration: none; font-size: 14px; }
    .msg { color: #00ffff; font-size: 14px; margin-bottom: 10px; }
    .err { color: #ff453a; font-size: 14px; margin-bottom: 10px; }
</style>
</head>
<body>
    <div class="box">
        <h3>パスワード再設定</h3>
        <p style="font-size:13px; color:#ccc; text-align:left;">
            登録されているIDとメールアドレスを入力してください。<br>
            一致した場合、パスワードを「<strong>1234</strong>」に初期化します。
        </p>

        <% String msg = (String)request.getAttribute("msg"); %>
        <% if(msg != null) { %><p class="msg"><%= msg %></p><% } %>

        <% String err = (String)request.getAttribute("error"); %>
        <% if(err != null) { %><p class="err"><%= err %></p><% } %>

        <form action="<%= request.getContextPath() %>/ForgotPasswordServlet" method="post">
            <input type="text" name="userId" placeholder="ユーザーID" required>
            <input type="email" name="email" placeholder="登録メールアドレス" required>
            <button type="submit">パスワードを初期化する</button>
        </form>

        <a href="login.jsp" class="back-link">← ログイン画面に戻る</a>
    </div>
</body>
</html>