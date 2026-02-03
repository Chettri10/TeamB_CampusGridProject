<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>ログイン - Campus Grid</title>
<style>
    /* bodyの基本設定は維持しつつ、余白をリセット */
    body {
        background-color: #020617;
        color: white;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0; /* モバイル用に追加 */
        font-family: sans-serif;
    }

    .login-box {
        background-color: #151f42;
        padding: 40px 30px; /* 横のパディングを少し調整 */
        border-radius: 10px;
        text-align: center;

        /* iPhone 14 Pro Max (幅430px) に合わせたサイズ調整 */
        width: 380px;
        max-width: 90%; /* 小さい画面でもはみ出さないように設定 */
        box-sizing: border-box; /* パディングを含めた幅計算にする */
    }

    input {
        width: 100%;
        padding: 15px 10px; /* タップしやすいように高さを少し拡張 */
        margin: 10px 0;
        border-radius: 5px;
        border: none;
        box-sizing: border-box; /* 枠線計算の調整 */

        /* iPhoneで入力時にズームしないためのサイズ調整 */
        font-size: 16px;
    }

    button {
        width: 100%;
        padding: 15px 10px; /* タップしやすいように高さを少し拡張 */
        background-color: #00ffff;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-weight: bold;
        margin-bottom: 15px;
        font-size: 16px; /* ボタン文字サイズも少し大きく */
    }

    .error { color: #ff453a; font-size: 14px; margin-bottom: 10px; }
    .msg { color: #00ff00; font-size: 14px; margin-bottom: 10px; }

    /* 追加：ID形式のガイドメッセージ用スタイル */
    .id-guide {
        font-size: 13px; /* モバイルで見やすいように微増 */
        color: #94a3b8;
        background: rgba(255, 255, 255, 0.05);
        padding: 10px;
        border-radius: 5px;
        margin-top: 5px;
    }
    .id-guide span { color: #00ffff; font-weight: bold; }

    /* リンクのスタイル */
    .link-area { margin-top: 25px; font-size: 15px; line-height: 1.8; }
    a { color: #00ffff; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .sub-link { color: #aaa; font-size: 13px; display: block; margin-top: 10px;}
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
                パスワードを変更する<br>(忘れた方もこちら)
            </a>
        </div>
    </div>
</body>
</html>