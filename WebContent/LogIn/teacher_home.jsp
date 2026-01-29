<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>

<%
    // --- 1. ログイン・教員チェック ---
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role");

    if (userId == null || (!userId.startsWith("T") && !"teacher".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
        return;
    }
    if(userName == null) userName = "先生";

    // --- 2. お知らせ取得 ---
    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>教員ホーム - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* --- デザイン設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 50px);
        --sab: env(safe-area-inset-bottom, 34px);
        --bg-color: #020617;
        --accent-cyan: #00ffff;
    }

    * { box-sizing: border-box; }

    body {
        background-color: var(--bg-color);
        color: white;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro JP", "Hiragino Kaku Gothic ProN", sans-serif;
        margin: 0;
        padding: 0;
        text-align: center;
        -webkit-overflow-scrolling: touch;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    /* --- ヘッダーエリア --- */
    .header-area {
        padding-top: calc(var(--sat) + 30px);
        padding-bottom: 10px;
        flex-shrink: 0;
    }

    h1 {
        color: var(--accent-cyan);
        font-size: 32px;
        margin: 0 0 10px 0;
        font-weight: 900;
        letter-spacing: 1px;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }
    .welcome-msg { font-size: 16px; color: #fff; font-weight: bold; }
    .user-id { font-size: 13px; color: #94a3b8; margin-top: 5px; }

    /* --- メニューグリッド --- */
    .menu-container {
        display: grid;
        grid-template-columns: 1fr 1fr; /* 2列固定 */
        gap: 16px;
        padding: 20px 24px;
        width: 100%;
        max-width: 500px;
        margin: 0 auto 20px auto;
    }

    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 140px; /* 6個並ぶため少し高さを調整 */
        border-radius: 20px;
        text-decoration: none;
        color: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.4);
        position: relative;
        transition: transform 0.1s;
    }

    .menu-card:active { transform: scale(0.97); }

    .icon-large { font-size: 38px; margin-bottom: 10px; }
    .menu-label {
        font-size: 15px;
        font-weight: bold;
        line-height: 1.3;
    }

    /* カラー設定 */
    .card-green  { background: #22c55e; }
    .card-blue   { background: #3b82f6; }
    .card-orange { background: #ea580c; }
    .card-purple { background: #a855f7; }
    .card-red    { background: #dc2626; }
    .card-teal   { background: #0d9488; } /* ユーザー登録用 */

    /* --- お知らせセクション --- */
    .notice-section {
        background-color: #ffffff;
        color: #333;
        border-radius: 30px 30px 0 0;
        flex-grow: 1;
        min-height: 400px;
        padding: 25px 24px 80px;
        text-align: left;
        position: relative;
        box-shadow: 0 -10px 30px rgba(0,0,0,0.5);
    }

    .notice-bar {
        position: absolute;
        left: 24px;
        top: 28px;
        width: 6px;
        height: 28px;
        background-color: #00E5FF;
        border-radius: 3px;
    }

    .notice-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-left: 15px;
    }

    .notice-title {
        font-size: 22px;
        font-weight: 800;
        color: #0f172a;
    }

    .new-post-btn {
        background-color: #00E5FF;
        color: #0f172a;
        padding: 8px 16px;
        border-radius: 50px;
        text-decoration: none;
        font-weight: bold;
        font-size: 13px;
    }

    .notice-item {
        border-bottom: 1px solid #f1f5f9;
        padding: 16px 0;
    }
    .notice-meta { font-size: 13px; color: #94a3b8; margin-bottom: 4px; }
    .badge {
        padding: 4px 10px;
        border-radius: 6px;
        color: white;
        font-size: 11px;
        font-weight: bold;
        margin-right: 6px;
    }
    .bg-red { background: #ef4444; }
    .bg-blue { background: #3b82f6; }
    .bg-green { background: #22c55e; }
    .notice-content { font-size: 15px; color: #334155; line-height: 1.6; }

    .logout-area { margin-top: 40px; text-align: center; }
    .logout-btn {
        display: inline-block;
        color: #ff5252;
        border: 2px solid #ff5252;
        padding: 12px 40px;
        border-radius: 30px;
        text-decoration: none;
        font-weight: bold;
    }
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
            <i class="fas fa-clipboard-user icon-large"></i>
            <span class="menu-label">出席状況<br>一覧</span>
        </a>

        <a href="<%= request.getContextPath() %>/ChatServlet?action=list&myId=<%= userId %>" class="menu-card card-blue">
            <i class="fas fa-comments icon-large"></i>
            <span class="menu-label">チャット</span>
        </a>

        <a href="<%= request.getContextPath() %>/RouteServlet?action=view" class="menu-card card-orange">
            <i class="fas fa-train icon-large"></i>
            <span class="menu-label">路線情報</span>
        </a>

        <a href="<%= request.getContextPath() %>/jsp/product_regist.jsp" class="menu-card card-purple">
            <i class="fas fa-cart-plus icon-large"></i>
            <span class="menu-label">商品登録</span>
        </a>

        <a href="<%= request.getContextPath() %>/ClassListServlet?className=1-1" class="menu-card card-red">
            <i class="fas fa-users icon-large"></i>
            <span class="menu-label">クラス名簿</span>
        </a>

        <a href="<%= request.getContextPath() %>/LogIn/signup.jsp" class="menu-card card-teal">
            <i class="fas fa-user-plus icon-large"></i>
            <span class="menu-label">ユーザー登録</span>
        </a>
    </div>

    <div class="notice-section">
        <div class="notice-bar"></div>
        <div class="notice-header">
            <div class="notice-title">お知らせ</div>
            <a href="notice_write.jsp" class="new-post-btn">＋ 新規投稿</a>
        </div>

        <div class="notice-list">
            <%
                if (list != null && !list.isEmpty()) {
                    for (Map<String, Object> item : list) {
                        String category = (String)item.get("CATEGORY");
                        String content  = (String)item.get("Content");
                        String date     = String.valueOf(item.get("Posted_On"));
                        Object rawId    = item.get("Notification_ID");
                        int id          = (rawId != null) ? (int)rawId : 0;

                        String badgeClass = "bg-blue";
                        if ("重要".equals(category)) badgeClass = "bg-red";
                        else if ("イベント".equals(category)) badgeClass = "bg-green";
            %>
                <div class="notice-item">
                    <div class="notice-meta">
                        <span class="badge <%= badgeClass %>"><%= category %></span> <%= date %>
                    </div>
                    <div class="notice-content"><%= content %></div>
                    <div style="text-align:right; margin-top:8px;">
                        <a href="notice_edit.jsp?id=<%= id %>" style="color:#3b82f6; font-size:13px; font-weight:bold; margin-right:10px; text-decoration:none;">編集</a>
                        <a href="notice_delete.jsp?id=<%= id %>" style="color:#ef4444; font-size:13px; font-weight:bold; text-decoration:none;">削除</a>
                    </div>
                </div>
            <%
                    }
                } else {
            %>
                <p style="color:#94a3b8; text-align:center; padding:40px;">現在、お知らせはありません</p>
            <% } %>
        </div>

        <div class="logout-area">
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="logout-btn">ログアウト</a>
        </div>
    </div>

</body>
</html>