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
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro JP", sans-serif;
        margin: 0; padding: 0;
        text-align: center;
        overflow-x: hidden;
    }

    /* --- ヘッダー・ハンバーガー --- */
    .header-area {
        padding-top: calc(var(--sat) + 20px);
        padding-bottom: 20px;
        position: relative;
        z-index: 100;
    }

    h1 {
        color: var(--accent-cyan);
        font-size: 28px;
        margin: 0;
        font-weight: 900;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }

    .hamburger {
        position: absolute;
        top: calc(var(--sat) + 22px);
        right: 25px;
        font-size: 28px; /* アイコンを少し大きく */
        color: var(--accent-cyan);
        cursor: pointer;
        z-index: 1001;
    }

    /* --- サイドメニュー --- */
    .side-menu {
        position: fixed;
        top: 0; right: -100%;
        width: 85%;
        max-width: 380px;
        height: 100%;
        background: rgba(15, 23, 42, 0.98);
        backdrop-filter: blur(15px);
        box-shadow: -10px 0 30px rgba(0,0,0,0.6);
        transition: 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 1000;
        padding: calc(var(--sat) + 70px) 25px var(--sab);
        text-align: left;
        display: flex;
        flex-direction: column;
    }

    .side-menu.active { right: 0; }

    .menu-section-title {
        font-size: 20px; /* セクションタイトルを大きく */
        font-weight: bold;
        color: var(--accent-cyan);
        margin-bottom: 15px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* お知らせリスト (メニュー内) */
    .mini-notice-list {
        flex-grow: 1;
        overflow-y: auto;
        margin-bottom: 20px;
        border-top: 1px solid rgba(255,255,255,0.1);
        padding-top: 15px;
    }

    .mini-notice-item {
        margin-bottom: 20px;
        background: rgba(255,255,255,0.04);
        padding: 18px; /* 余白を増やしてゆったりと */
        border-radius: 16px;
        border: 1px solid rgba(255,255,255,0.08);
    }

    .mini-badge {
        font-size: 13px; /* バッジの文字を大きく */
        padding: 4px 10px;
        border-radius: 6px;
        font-weight: 900;
        margin-bottom: 10px;
        display: inline-block;
    }

    .mini-content {
        font-size: 16px; /* ★本文を大きく (13px -> 16px) */
        line-height: 1.6;
        color: #f1f5f9;
        font-weight: 500;
    }

    .notice-actions {
        margin-top: 12px;
        border-top: 1px solid rgba(255,255,255,0.1);
        padding-top: 12px;
        display: flex;
        gap: 20px;
    }
    .notice-actions a {
        color: var(--accent-cyan);
        font-size: 14px; /* 編集・削除リンクも大きく */
        text-decoration: none;
        font-weight: bold;
    }

    /* 下部リンクエリア */
    .bottom-links {
        margin-top: auto;
        display: flex;
        flex-direction: column;
        gap: 15px;
    }

    .sub-link {
        display: flex;
        align-items: center;
        gap: 12px;
        color: #e2e8f0;
        text-decoration: none;
        font-size: 16px; /* ★設定項目の文字も大きく */
        padding: 16px;
        background: rgba(255,255,255,0.07);
        border-radius: 15px;
        font-weight: bold;
    }

    .logout-link { color: #ff6b6b; border: 1px solid rgba(255, 107, 107, 0.4); }

    /* --- メインコンテンツ --- */
    .main-content { padding: 10px 24px; }
    .welcome-box { margin-bottom: 30px; }
    .welcome-msg { font-size: 20px; font-weight: bold; }
    .user-id { font-size: 14px; color: #94a3b8; margin-top: 4px; }

    .menu-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        max-width: 500px;
        margin: 0 auto;
    }

    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 140px;
        border-radius: 20px;
        text-decoration: none;
        color: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.4);
    }
    .menu-card:active { transform: scale(0.97); }
    .icon-large { font-size: 38px; margin-bottom: 10px; }
    .menu-label { font-size: 15px; font-weight: bold; }

    .card-green { background: #22c55e; } .card-blue { background: #3b82f6; }
    .card-orange { background: #ea580c; } .card-purple { background: #a855f7; }
    .card-red { background: #dc2626; } .card-teal { background: #0d9488; }

    .overlay {
        position: fixed;
        top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.6);
        display: none; z-index: 999;
    }
    .overlay.active { display: block; }
</style>
</head>
<body>

    <header class="header-area">
        <h1>CAMPUS GRID</h1>
        <div class="hamburger" id="hamburger-btn">
            <i class="fas fa-bars"></i>
        </div>
    </header>

    <div class="overlay" id="menu-overlay"></div>

    <div class="side-menu" id="side-menu">
        <div class="menu-section-title">
            <i class="fas fa-bullhorn"></i> お知らせ管理
        </div>

        <div class="mini-notice-list">
            <a href="notice_write.jsp" style="color:var(--accent-cyan); text-decoration:none; font-size:16px; display:inline-block; margin-bottom:20px; font-weight:900; background: rgba(0, 255, 255, 0.1); padding: 8px 15px; border-radius: 8px;">
                <i class="fas fa-plus-circle"></i> 新規投稿する
            </a>

            <% if (list != null && !list.isEmpty()) {
                for (Map<String, Object> item : list) {
                    String category = (String)item.get("CATEGORY");
                    String content = (String)item.get("Content");
                    int id = (item.get("Notification_ID") != null) ? (int)item.get("Notification_ID") : 0;
                    String badgeCol = "重要".equals(category) ? "#ef4444" : ("イベント".equals(category) ? "#22c55e" : "#3b82f6");
            %>
                <div class="mini-notice-item">
                    <span class="mini-badge" style="background:<%= badgeCol %>;"><%= category %></span>
                    <div class="mini-content"><%= content %></div>
                    <div class="notice-actions">
                        <a href="notice_edit.jsp?id=<%= id %>"><i class="fas fa-edit"></i> 編集</a>
                        <a href="notice_delete.jsp?id=<%= id %>" style="color:#ff6b6b;"><i class="fas fa-trash"></i> 削除</a>
                    </div>
                </div>
            <% } } else { %>
                <p style="font-size:16px; color:#94a3b8; text-align:center; margin-top:30px;">現在お知らせはありません</p>
            <% } %>
        </div>

        <div class="bottom-links">
            <div class="menu-section-title" style="margin-bottom:5px;"><i class="fas fa-cog"></i> アカウント設定</div>
            <a href="<%= request.getContextPath() %>/LogIn/password_reset.jsp" class="sub-link">
                <i class="fas fa-key"></i> パスワードを変更する
            </a>
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="sub-link logout-link">
                <i class="fas fa-sign-out-alt"></i> ログアウト
            </a>
        </div>
    </div>

    <main class="main-content">
        <div class="welcome-box">
            <div class="welcome-msg">こんにちは、<%= userName %> 先生</div>
            <div class="user-id">（ID: <%= userId %>）</div>
        </div>

        <div class="menu-container">
            <a href="<%= request.getContextPath() %>/AttManagementListServlet" class="menu-card card-green">
                <i class="fas fa-clipboard-user icon-large"></i>
                <span class="menu-label">出席状況一覧</span>
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
    </main>

    <script>
        const btn = document.getElementById('hamburger-btn');
        const menu = document.getElementById('side-menu');
        const overlay = document.getElementById('menu-overlay');

        function toggleMenu() {
            menu.classList.toggle('active');
            overlay.classList.toggle('active');
            const icon = btn.querySelector('i');
            if (menu.classList.contains('active')) {
                icon.classList.replace('fa-bars', 'fa-times');
            } else {
                icon.classList.replace('fa-times', 'fa-bars');
            }
        }

        btn.addEventListener('click', toggleMenu);
        overlay.addEventListener('click', toggleMenu);
    </script>
</body>
</html>