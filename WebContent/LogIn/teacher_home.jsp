<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }

    // ★ ダミーデータ（本来は DB から取得）
    class NoticeData {
        int id;
        String date;
        String category;
        String message;

        public NoticeData(int id, String date, String category, String message) {
            this.id = id;
            this.date = date;
            this.category = category;
            this.message = message;
        }
    }

    List<NoticeData> list = new ArrayList<>();
    list.add(new NoticeData(1, "2025/12/01", "重要", "【休講連絡】 12月5日(金) 3限目の「Java基礎」は休講となります。"));
    list.add(new NoticeData(2, "2025/11/28", "連絡", "進路希望調査票の提出期限は明日までです。"));
    list.add(new NoticeData(3, "2025/11/25", "イベント", "来週の金曜日は学園祭の準備日です。"));
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>教員ホーム</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
    body {
        background-color: #030820;
        color: #FFFFFF;
        font-family: 'Noto Sans JP', sans-serif;
        margin: 0;
        padding: 20px;
    }

    .top-area {
        text-align: center;
        margin-bottom: 40px;
        background: #fff3e0;
        color: #333;
        padding: 30px 10px;
        border-radius: 12px;
    }

    .top-area h1 {
        margin: 0;
        font-size: 26px;
    }

    .top-area a {
        display: block;
        margin: 10px auto;
        color: #000;
        font-weight: bold;
        text-decoration: none;
    }

    .container {
        width: 100%;
        max-width: 400px;
        margin: 0 auto;
    }

    .title-area {
        text-align: center;
        margin-bottom: 20px;
    }

    h2 {
        font-size: 26px;
        margin: 0;
        color: #00FFFF;
    }

    .notification-list {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .notice-card {
        background-color: #FFFFFF;
        border-radius: 12px;
        padding: 15px;
        color: #333;
        box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        border-left: 6px solid #ccc;
    }

    .border-red { border-left-color: #FF5252; }
    .border-blue { border-left-color: #448AFF; }
    .border-green { border-left-color: #69F0AE; }

    .card-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 10px;
    }

    .category-badge {
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        color: white;
    }

    .bg-red { background-color: #FF5252; }
    .bg-blue { background-color: #448AFF; }
    .bg-green { background-color: #00C853; }

    .notice-date {
        color: #888;
        font-size: 14px;
    }

    .message-content {
        font-size: 15px;
        line-height: 1.6;
    }

    .btn-area {
        display: flex;
        gap: 10px;
        margin-top: 12px;
    }

    .btn {
        flex: 1;
        padding: 8px;
        border-radius: 8px;
        text-align: center;
        font-weight: 600;
        text-decoration: none;
        font-size: 14px;
    }

    .btn-edit { background-color: #00E5FF; color: #000; }
    .btn-delete { background-color: #FF5252; color: #FFF; }

    .logout-btn {
        display: block;
        margin: 30px auto 0;
        padding: 12px;
        background: #00E5FF;
        color: #000;
        text-align: center;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        width: 200px;
    }
</style>
</head>

<body>

<div class="top-area">
    <h1>教員用管理画面</h1>
    <p>ようこそ、<%= session.getAttribute("userName") %> 先生</p>

    <a href="UserListServlet?myId=<%= session.getAttribute("userId") %>">チャット一覧</a>
    <a href="qr_generator.jsp">出席QRコード表示</a>
</div>

<div class="container">
    <div class="title-area">
        <h2>お知らせ（教員）</h2>
    </div>

    <div class="notification-list">
        <%
            for (NoticeData item : list) {
                String borderColor = "border-blue";
                String badgeColor = "bg-blue";

                if ("重要".equals(item.category)) { borderColor = "border-red"; badgeColor = "bg-red"; }
                else if ("イベント".equals(item.category)) { borderColor = "border-green"; badgeColor = "bg-green"; }
        %>

        <div class="notice-card <%= borderColor %>">
            <div class="card-header">
                <span class="category-badge <%= badgeColor %>"><%= item.category %></span>
                <span class="notice-date"><%= item.date %></span>
            </div>

            <div class="message-content"><%= item.message %></div>

            <div class="btn-area">
                <a class="btn btn-edit" href="notice_edit.jsp?id=<%= item.id %>">編集</a>
                <a class="btn btn-delete" href="notice_delete.jsp?id=<%= item.id %>">削除</a>
            </div>
        </div>

        <% } %>
    </div>

    <a href="logout.jsp" class="logout-btn">ログアウト</a>
</div>

</body>
</html>
