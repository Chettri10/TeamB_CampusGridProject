<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        // ログインしていない場合などの処理（必要に応じて有効化）
        // response.sendRedirect("LogIn/login.jsp");
        // return;
    }

    // ユーザー名取得
    String userName = (String) session.getAttribute("userName");
    String userId   = (String) session.getAttribute("userId");

    // ★ DB からお知らせ一覧を取得
    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>教員ホーム - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    /* 全体設定 */
    body {
        background-color: #020617; /* 濃紺 */
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 0;
        text-align: center;
    }

    /* ヘッダーエリア */
    .header-area {
        margin-top: 40px;
        margin-bottom: 30px;
    }

    h1 {
        color: #00ffff; /* シアン */
        font-size: 32px;
        margin-bottom: 10px;
        font-weight: bold;
        letter-spacing: 2px;
    }

    .welcome-msg {
        font-size: 18px;
        color: #eee;
    }
    .user-id {
        font-size: 14px;
        color: #aaa;
        margin-top: 5px;
    }

    /* メニューボタンのコンテナ */
    .menu-container {
        display: flex;
        justify-content: center;
        gap: 30px;
        margin: 40px auto;
        flex-wrap: wrap;
        max-width: 800px;
    }

    /* ボタン共通スタイル */
    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        width: 220px;
        height: 160px;
        border-radius: 20px;
        text-decoration: none;
        color: white;
        transition: transform 0.3s, box-shadow 0.3s;
        box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        position: relative;
    }
    .menu-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.5);
    }

    .icon-large {
        font-size: 40px;
        margin-bottom: 15px;
    }
    .menu-label {
        font-size: 18px;
        font-weight: bold;
    }

    /* 色別スタイル */
    .card-green {
        background: linear-gradient(135deg, #32cd32, #228b22);
    }
    .card-blue {
        background: linear-gradient(135deg, #1e90ff, #0000cd);
    }
    .card-orange {
        background: linear-gradient(135deg, #ff8c00, #ff4500);
    }

    /* お知らせボード（白背景） */
    .notice-board {
        background-color: #ffffff;
        color: #333;
        width: 85%;
        max-width: 700px;
        margin: 50px auto;
        border-radius: 12px;
        padding: 25px;
        text-align: left;
        box-shadow: 0 0 20px rgba(255,255,255,0.1);
    }

    .notice-header-area {
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 2px solid #eee;
        padding-bottom: 10px;
        margin-bottom: 15px;
    }

    .notice-title {
        font-size: 20px;
        font-weight: bold;
        color: #020617;
    }

    /* 新規投稿ボタン */
    .new-post-btn {
        background-color: #00E5FF;
        color: #000;
        padding: 8px 15px;
        border-radius: 20px;
        text-decoration: none;
        font-weight: bold;
        font-size: 14px;
        transition: background 0.3s;
    }
    .new-post-btn:hover { background-color: #6effff; }

    /* お知らせリストアイテム */
    .notice-item {
        border-bottom: 1px solid #f0f0f0;
        padding: 10px 0;
    }
    .notice-item:last-child { border-bottom: none; }

    .notice-meta {
        font-size: 12px;
        color: #888;
        margin-bottom: 4px;
    }
    .badge {
        padding: 2px 8px;
        border-radius: 10px;
        color: white;
        font-size: 11px;
        margin-right: 5px;
    }
    .bg-red { background-color: #ff5252; }
    .bg-blue { background-color: #448aff; }
    .bg-green { background-color: #00c853; }

    .notice-content { font-size: 15px; }

    .notice-actions {
        margin-top: 5px;
        text-align: right;
    }
    .action-link {
        font-size: 12px;
        color: #00E5FF;
        text-decoration: none;
        margin-left: 10px;
    }
    .action-link:hover { text-decoration: underline; }
    .delete-link { color: #ff5252; }

    /* ログアウト */
    .logout-link {
        display: inline-block;
        margin: 30px auto;
        color: #aaa;
        text-decoration: none;
        font-size: 14px;
    }
    .logout-link:hover { color: white; }
</style>
</head>
<body>

    <div class="header-area">
        <h1>CAMPUS GRID</h1>
        <div class="welcome-msg">こんにちは、<%= userName %> 先生</div>
        <div class="user-id">(ID: <%= userId %>)</div>
    </div>

    <div class="menu-container">

        <a href="<%= request.getContextPath() %>/AttManagementListServlet" class="menu-card card-green">
            <i class="fas fa-clipboard-list icon-large"></i>
            <span class="menu-label">出席状況一覧</span>
        </a>

<a href="<%= request.getContextPath() %>/jsp/user_list.jsp?myId=<%= userId %>" class="menu-card card-blue">
        <i class="fas fa-comments icon-large"></i>
        <span class="menu-label">教員・学生 チャット</span>
    </a>
        <a href="qr_generator.jsp" class="menu-card card-orange">
            <i class="fas fa-qrcode icon-large"></i>
            <span class="menu-label">出席QRコード表示</span>
        </a>

    </div>

    <div class="notice-board">
        <div class="notice-header-area">
            <div class="notice-title">お知らせ (教員用)</div>
            <a href="notice_write.jsp" class="new-post-btn">＋ 新規投稿</a>
        </div>

        <div class="notice-list">
            <%
                if (list != null && !list.isEmpty()) {
                    for (Map<String, Object> item : list) {
                        String category = (String)item.get("CATEGORY");
                        String content  = (String)item.get("Content");
                        String date     = String.valueOf(item.get("Posted_On"));
                        int id          = (int)item.get("Notification_ID");

                        String badgeClass = "bg-blue";
                        if ("重要".equals(category)) { badgeClass = "bg-red"; }
                        else if ("イベント".equals(category)) { badgeClass = "bg-green"; }
            %>
                <div class="notice-item">
                    <div class="notice-meta">
                        <span class="badge <%= badgeClass %>"><%= category %></span>
                        <%= date %>
                    </div>
                    <div class="notice-content"><%= content %></div>
                    <div class="notice-actions">
                        <a href="notice_edit.jsp?id=<%= id %>" class="action-link">編集</a>
                        <a href="notice_delete.jsp?id=<%= id %>" class="action-link delete-link">削除</a>
                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <p style="color:#888; text-align:center; padding:20px;">現在、お知らせはありません。</p>
            <%
                }
            %>
        </div>
    </div>

    <a href="logout.jsp" class="logout-link">ログアウト</a>

</body>
</html>