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
    button { width: 100%; padding: 10px; background-color: #00ffff; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; margin-bottom: 15px; }
    .error { color: #ff453a; font-size: 14px; margin-bottom: 10px; }
    .msg { color: #00ff00; font-size: 14px; margin-bottom: 10px; }

    /* 追加：ID形式のガイドメッセージ用スタイル */
    .id-guide {
        font-size: 12px;
        color: #94a3b8;
        background: rgba(255, 255, 255, 0.05);
        padding: 8px;
        border-radius: 5px;
        margin-top: 5px;
    }
    .id-guide span { color: #00ffff; font-weight: bold; }

    /* リンクのスタイル */
    .link-area { margin-top: 20px; font-size: 14px; line-height: 1.8; }
    a { color: #00ffff; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .sub-link { color: #aaa; font-size: 12px; display: block; margin-top: 10px;}
</style>
</head>
<body>
    <div class="login-box">
        <h2>Campus Grid Login</h2>

        <% String error = (String)request.getAttribute("errorMsg"); %>
        <% if(error != null) { %>
            <p class="error"><%= error %></p>
        <% } %>

        <% String msg = (String)request.getAttribute("msg"); %>
        <% if(msg != null) { %>
            <p class="msg"><%= msg %></p>
        <% } %>

        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
            <input type="text" name="userId" placeholder="ユーザーID (例: S00001)" required>
            <input type="password" name="password" placeholder="パスワード" required>
            <button type="submit">ログイン</button>
        </form>

        <div class="id-guide">
            <span>T</span>...先生 / <span>S</span>...学生 / <span>P</span>...保護者
        </div>

        <div class="link-area">
            <a href="password_reset.jsp">
                <i class="fas fa-key"></i> パスワードを変更する<br>(忘れた方もこちら)
            </a>
        </div>
    </div>
</body>
</html>