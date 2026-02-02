<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>

<%
    // --- 1. ログイン・学生チェック ---
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role");

    // IDがない、または"S"で始まらない（学生でない）場合はログイン画面へ
    if (userId == null || (!userId.startsWith("S") && !"student".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
        return;
    }

    // null対策
    if(userName == null) userName = "学生";

    // 名前の頭文字を取得（アイコン用）
    String initial = (userName.length() > 0) ? userName.substring(0, 1) : "S";

    // --- 2. DB からお知らせ一覧を取得 ---
    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>学生ホーム - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* --- 教員画面と共通のデザイン定義 --- */
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

    /* --- ヘッダー --- */
    .header-area {
        padding-top: calc(var(--sat) + 15px);
        padding-bottom: 10px;
        position: relative;
        z-index: 100;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    h1 {
        color: var(--accent-cyan);
        font-size: 28px;
        margin: 0;
        font-weight: 900;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
        letter-spacing: 1px;
    }

    .hamburger {
        position: absolute;
        top: calc(var(--sat) + 20px);
        right: 25px;
        font-size: 28px;
        color: var(--accent-cyan);
        cursor: pointer;
        z-index: 1001;
    }

    /* ▼▼▼ ロゴ下の挨拶エリア ▼▼▼ */
    .welcome-header {
        margin-bottom: 25px;
        padding: 0 20px;
    }
    .welcome-msg {
        font-size: 18px;
        font-weight: bold;
        color: #fff;
        margin: 0;
    }
    .user-id {
        font-size: 13px;
        color: #94a3b8;
        margin-top: 4px;
        font-weight: normal;
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
        padding: calc(var(--sat) + 20px) 25px var(--sab);
        text-align: left;
        display: flex;
        flex-direction: column;
    }

    .side-menu.active { right: 0; }

    /* サイドメニュー上部のプロフィール表示 */
    .side-profile-header {
        display: flex;
        align-items: center;
        gap: 15px;
        padding-bottom: 25px;
        margin-bottom: 20px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
        margin-top: 30px;
    }

    .side-avatar {
        width: 54px;
        height: 54px;
        background: linear-gradient(135deg, #00c6fb, #005bea);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        font-weight: bold;
        color: #fff;
        box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        flex-shrink: 0;
    }

    .side-user-info {
        display: flex;
        flex-direction: column;
        justify-content: center;
    }

    .side-name {
        font-size: 18px;
        font-weight: bold;
        color: #fff;
    }

    .side-id {
        font-size: 13px;
        color: #94a3b8;
        margin-top: 4px;
    }

    .menu-section-title {
        font-size: 16px;
        font-weight: bold;
        color: var(--accent-cyan);
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 8px;
        opacity: 0.9;
    }

    /* お知らせリスト (メニュー内・閲覧専用) */
    .mini-notice-list {
        flex-grow: 1;
        overflow-y: auto;
        margin-bottom: 20px;
        scrollbar-width: thin;
        scrollbar-color: rgba(255,255,255,0.2) transparent;
    }

    .mini-notice-item {
        margin-bottom: 15px;
        background: rgba(255,255,255,0.04);
        padding: 15px;
        border-radius: 12px;
        border: 1px solid rgba(255,255,255,0.08);
    }

    .mini-badge {
        font-size: 11px;
        padding: 3px 8px;
        border-radius: 4px;
        font-weight: 700;
        margin-bottom: 8px;
        display: inline-block;
        color: white;
    }

    .mini-content {
        font-size: 14px;
        line-height: 1.5;
        color: #f1f5f9;
        margin-bottom: 5px;
    }

    .mini-date {
        display: block;
        text-align: right;
        font-size: 11px;
        color: #64748b;
    }

    /* 下部リンクエリア */
    .bottom-links {
        margin-top: auto;
        display: flex;
        flex-direction: column;
        gap: 10px;
        padding-top: 20px;
        border-top: 1px solid rgba(255,255,255,0.1);
    }

    .sub-link {
        display: flex;
        align-items: center;
        gap: 12px;
        color: #e2e8f0;
        text-decoration: none;
        font-size: 15px;
        padding: 14px;
        background: rgba(255,255,255,0.07);
        border-radius: 12px;
        font-weight: bold;
        transition: background 0.2s;
    }
    .sub-link:active { background: rgba(255,255,255,0.15); }

    .logout-link { color: #ff6b6b; border: 1px solid rgba(255, 107, 107, 0.4); }

    /* --- メインコンテンツ --- */
    .main-content { padding: 0 24px 20px; }

    .menu-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
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
        box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        position: relative;
        overflow: hidden;
    }
    .menu-card::after {
        content: ''; position: absolute;
        top:0; left:0; width:100%; height:100%;
        background: linear-gradient(to bottom, rgba(255,255,255,0.1), transparent);
    }
    .menu-card:active { transform: scale(0.97); }

    .icon-large { font-size: 38px; margin-bottom: 10px; }
    .menu-label { font-size: 15px; font-weight: bold; }

    .card-green  { background: #10b981; }
    .card-blue   { background: #3b82f6; }
    .card-purple { background: #a855f7; }
    .card-orange { background: #f97316; }

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

    <div class="welcome-header">
        <p class="welcome-msg">こんにちは、<%= userName %> さん</p>
        <p class="user-id">（ID: <%= userId %>）</p>
    </div>

    <div class="overlay" id="menu-overlay"></div>

    <div class="side-menu" id="side-menu">

        <div class="side-profile-header">
            <div class="side-avatar"><%= initial %></div>
            <div class="side-user-info">
                <span class="side-name"><%= userName %></span>
                <span class="side-id">ID: <%= userId %></span>
            </div>
        </div>

        <div class="menu-section-title">
            <i class="fas fa-bell"></i> お知らせ一覧
        </div>

        <div class="mini-notice-list">
            <%
                if (list != null && !list.isEmpty()) {
                    boolean hasTeacherNotice = false;
                    for (Map<String, Object> item : list) {
                        String noticeRole = (String)item.get("Role");
                        // 教員からの投稿のみ表示
                        if ("teacher".equalsIgnoreCase(noticeRole)) {
                            hasTeacherNotice = true;
                            String category = (String)item.get("CATEGORY");
                            String content = (String)item.get("Content");
                            String date = String.valueOf(item.get("Posted_On"));

                            String badgeCol = "#3b82f6"; // Default Blue
                            if ("重要".equals(category)) badgeCol = "#ef4444"; // Red
                            else if ("イベント".equals(category)) badgeCol = "#10b981"; // Green
            %>
                <div class="mini-notice-item">
                    <span class="mini-badge" style="background:<%= badgeCol %>;"><%= category %></span>
                    <div class="mini-content"><%= content %></div>
                    <span class="mini-date"><%= date %></span>
                </div>
            <%
                        }
                    }
                    if (!hasTeacherNotice) {
            %>
                <p style="font-size:14px; color:#94a3b8; text-align:center; margin-top:30px;">お知らせはありません</p>
            <%
                    }
                } else {
            %>
                <p style="font-size:14px; color:#94a3b8; text-align:center; margin-top:30px;">お知らせはありません</p>
            <% } %>
        </div>

        <div class="bottom-links">
            <div class="menu-section-title" style="margin-bottom:5px; font-size:16px;">
                <i class="fas fa-cog"></i> アカウント設定
            </div>

            <a href="profile_view.jsp" class="sub-link">
                <i class="fas fa-id-card"></i> プロフィール詳細
            </a>
            <a href="<%= request.getContextPath() %>/LogIn/password_reset.jsp" class="sub-link">
                <i class="fas fa-key"></i> パスワードを変更する
            </a>
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="sub-link logout-link">
                <i class="fas fa-sign-out-alt"></i> ログアウト
            </a>
        </div>
    </div>

    <main class="main-content">
        <div class="menu-container">
            <a href="<%= request.getContextPath() %>/jsp/student_pass.jsp" class="menu-card card-green">
                <i class="fas fa-qrcode icon-large"></i>
                <span class="menu-label">出席登録</span>
            </a>

            <a href="<%= request.getContextPath() %>/ChatServlet?action=list&myId=<%= userId %>" class="menu-card card-blue">
                <i class="fas fa-comments icon-large"></i>
                <span class="menu-label">チャット</span>
            </a>

            <a href="<%= request.getContextPath() %>/jsp/cart.jsp" class="menu-card card-purple">
                <i class="fas fa-cart-shopping icon-large"></i>
                <span class="menu-label">商品購入</span>
            </a>

            <a href="<%= request.getContextPath() %>/jsp/syukatu.jsp" class="menu-card card-orange">
                <i class="fas fa-user-tie icon-large"></i>
                <span class="menu-label">就活情報</span>
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