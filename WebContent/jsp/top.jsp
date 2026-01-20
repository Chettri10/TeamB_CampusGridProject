<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // セッションからユーザー名とIDを取得
    String username = (String) session.getAttribute("userName");
    String userId = (String) session.getAttribute("userId");

    // セッションが空の場合（未ログイン）の処理
    if (username == null || userId == null) {
        // 本番環境では login.jsp へリダイレクト
        // response.sendRedirect("login.jsp");
        // return;

         }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>CAMPUS GRID - Top</title>

<meta name="viewport" content="width=430, initial-scale=1.0">

<style>
/* 全体 */
body {
    background-color: #000033;
    color: white;
    font-family: "Meiryo", sans-serif;
    margin: 0;
    padding: 0;
    text-align: center;
}

/* ヘッダー */
.header {
    margin-top: 40px;
    margin-bottom: 25px;
}

.logo {
    font-size: 2.4em;
    font-weight: bold;
    color: #00ffff;
}

.greeting {
    margin-top: 8px;
    font-size: 1.3em;
}

.user-id {
    font-size: 0.9em;
    color: #cccccc;
    margin-top: 4px;
}

/* 上段の2つボタン */
.menu-row {
    display: flex;
    justify-content: center;
    gap: 25px;
    margin-top: 40px;
}

/* 下段1つボタン */
.menu-center {
    display: flex;
    justify-content: center;
    margin-top: 25px;
}

/* ボタン共通 */
.menu-item {
    width: 200px;
    height: 130px;
    border-radius: 20px;
    font-size: 1.1em;
    font-weight: bold;
    color: white;
    text-decoration: none;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    box-shadow: 0 4px 8px rgba(0,0,0,0.4);
    transition: transform 0.2s;
}

.menu-item:active {
    transform: scale(0.95);
}

/* アイコン */
.icon {
    font-size: 2.7em;
    margin-bottom: 8px;
}

/* 色 */
.green  { background-color: #37c74b; }
.blue   { background-color: #4aaaff; }
.orange { background-color: #ff8c32; }

/* お知らせ */
.notification-box {
    background-color: white;
    color: black;
    padding: 15px;
    border-radius: 10px;
    width: 80%;
    max-width: 450px;
    margin: 40px auto 50px auto;
    text-align: left;
}

.notification-header {
    font-weight: bold;
    margin-bottom: 6px;
}
</style>
</head>
<body>

    <div class="header">
        <div class="logo">CAMPUS GRID</div>
        <div class="greeting">こんにちは、<%= username %> さん</div>
        <div class="user-id">(ID: <%= userId %>)</div>
    </div>

    <div class="menu-row">
        <a class="menu-item green" href="student_pass.jsp">
            <div class="icon">📖</div>
            出席QRスキャン
        </a>

        <a class="menu-item blue" href="chat.jsp">
            <div class="icon">💬</div>
            教員・学生 チャット
        </a>
    </div>

    <div class="menu-center">
        <a class="menu-item orange" href="cart.jsp">
            <div class="icon">🛒</div>
            商品登録
        </a>
    </div>

    <div class="notification-box">
        <div class="notification-header">【重要】就職活動について（2024/07/15）</div>
        <ul>
            <li>・説明会の日程を確認してください。</li>
        </ul>
    </div>

</body>
</html>