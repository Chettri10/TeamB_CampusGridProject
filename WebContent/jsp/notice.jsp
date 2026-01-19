<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }

    // =================================================================
    // データ定義（ダミー）
    // =================================================================
    class NoticeData {
        String date;
        String category;
        String message;

        public NoticeData(String date, String category, String message) {
            this.date = date;
            this.category = category;
            this.message = message;
        }
    }

    List<NoticeData> list = new ArrayList<>();
    list.add(new NoticeData("2025/12/01", "重要", "【休講連絡】 12月5日(金) 3限目の「Java基礎」は休講となります。"));
    list.add(new NoticeData("2025/11/28", "連絡", "進路希望調査票の提出期限は明日までです。"));
    list.add(new NoticeData("2025/11/25", "イベント", "来週の金曜日は学園祭の準備日です。"));
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>キャンパスグリッド - お知らせ一覧</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap" rel="stylesheet">

    <style>
        body {
            background-color: #030820;
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
        }
        .container { width: 100%; max-width: 400px; padding-bottom: 50px; }
        .title-area { text-align: center; margin-bottom: 30px; margin-top: 20px; }
        h1 { font-size: 24px; margin: 0; }
        h2 { font-size: 28px; margin: 5px 0 0 0; font-weight: 700; color: #00FFFF; }

        .notification-list { display: flex; flex-direction: column; gap: 20px; }

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

        .card-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
        .notice-date { color: #888; font-size: 14px; }
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

        .message-content { font-size: 15px; line-height: 1.6; }

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
    </style>
</head>

<body>
<div class="container">
    <div class="title-area">
        <h1>キャンパスグリッド</h1>
        <h2>お知らせ</h2>
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

            <!-- ★ 教員だけ編集・削除ボタン表示 -->
            <div class="btn-area">
                <a class="btn btn-edit"
                   href="notice_edit.jsp?date=<%= item.date %>&category=<%= item.category %>&message=<%= item.message %>">
                    編集
                </a>

                <a class="btn btn-delete"
                   href="notice_delete.jsp?date=<%= item.date %>&message=<%= item.message %>">
                    削除
                </a>
            </div>
        </div>

        <% } %>
    </div>
</div>
</body>
</html>
