<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>
<%
    String username = (String) session.getAttribute("userName");
    String userId = (String) session.getAttribute("userId");

    // 未ログイン時のリダイレクトを有効化
    if (username == null || userId == null) {
        response.sendRedirect("LogIn/login.jsp");
        return;
    }

    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>CAMPUS GRID - Top</title>
<meta name="viewport" content="width=430, initial-scale=1.0">
<style>
/* --- 既存のスタイル --- */
body {
    background-color: #000033;
    color: white;
    font-family: "Meiryo", sans-serif;
    margin: 0;
    padding: 0;
    text-align: center;
}
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
.menu-row {
    display: flex;
    justify-content: center;
    gap: 25px;
    margin-top: 40px;
}
.menu-center {
    display: flex;
    justify-content: center;
    margin-top: 25px;
}
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
.menu-item:active { transform: scale(0.95); }
.icon { font-size: 2.7em; margin-bottom: 8px; }
.green  { background-color: #37c74b; }
.blue   { background-color: #4aaaff; }
.orange { background-color: #ff8c32; }

.notification-box {
    background-color: white;
    color: black;
    padding: 15px;
    border-radius: 10px;
    width: 80%;
    max-width: 450px;
    margin: 40px auto 30px auto; /* 下の余白を少し調整 */
    text-align: left;
}
.notification-header { font-weight: bold; margin-bottom: 6px; }

/* --- 追加：ログアウトボタンのスタイル --- */
.logout-container {
    margin-bottom: 60px; /* 画面最下部との余白 */
}
.logout-btn {
    display: inline-block;
    padding: 10px 30px;
    background-color: transparent;
    color: #ff4444; /* 赤色 */
    border: 1px solid #ff4444;
    border-radius: 25px;
    text-decoration: none;
    font-size: 0.9em;
    transition: 0.3s;
}
.logout-btn:hover {
    background-color: #ff4444;
    color: white;
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
    <a class="menu-item green" href="<%= request.getContextPath() %>/jsp/student_pass.jsp">
        <div class="icon">📖</div>
        出席QRスキャン
    </a>

    <a class="menu-item blue" href="<%= request.getContextPath() %>/ChatServlet?action=list&myId=<%= userId %>">
        <div class="icon">💬</div>
        教員・学生 チャット
    </a>
</div>

<div class="menu-center">
    <a class="menu-item orange" href="<%= request.getContextPath() %>/jsp/cart.jsp">
        <div class="icon">🛒</div>
        商品登録
    </a>
</div>

<div class="notification-box">
    <div class="notification-header">📢 教員からのお知らせ</div>
    <ul>
        <%
            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> item : list) {
                    String category = (String)item.get("CATEGORY");
                    String content  = (String)item.get("Content");
                    String date     = String.valueOf(item.get("Posted_On"));
                    String role     = (String)item.get("Role");

                    if ("teacher".equals(role)) {
        %>
            <li>【<%= category %>】<%= content %>（<%= date %>）</li>
        <%
                    }
                }
            } else {
        %>
            <li>現在、お知らせはありません。</li>
        <%
            }
        %>
    </ul>
</div>

<div class="logout-container">
    <a href="<%= request.getContextPath() %>/LogoutServlet" class="logout-btn">
        ログアウト
    </a>
</div>

</body>
</html>