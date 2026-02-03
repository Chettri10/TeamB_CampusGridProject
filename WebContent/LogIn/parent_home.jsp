<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="dao.ChatDao" %>
<%@ page import="java.util.*" %>
<%
    // --- 1. 簡易ログインチェック ---
    String userName = (String) session.getAttribute("userName");
    // 変数名を userId に統一
    String userId = (String) session.getAttribute("userId");

    // 未ログイン時のリダイレクト
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
        return;
    }

    // 名前がない場合の初期値
    if(userName == null) userName = "保護者";

    // アイコン用の頭文字
    String initial = (userName.length() > 0) ? userName.substring(0, 1) : "P";

    // 1. 学校全体のお知らせ取得（ハンバーガーメニュー内に表示）
    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();

    // 2. 保護者宛ての通知（重要なお知らせ：遅刻・欠席等）を取得（メイン画面に表示）
    List<Map<String, String>> alertList = new ArrayList<>();
    ChatDao chatDao = new ChatDao();
    alertList = chatDao.getReceivedMessages(userId);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>保護者ホーム - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* --- iPhone 14 Pro Max (430px) サイズ固定用設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 59px);
        --sab: env(safe-area-inset-bottom, 34px);
        --bg-color: #020617;
        --accent-cyan: #00ffff;
    }

    * { box-sizing: border-box; }

    html {
        background-color: #000; /* 枠外は黒 */
    }

    body {
        background-color: var(--bg-color);
        color: white;
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro JP", sans-serif;
        margin: 0 auto; /* 中央寄せ */
        padding: 0;
        text-align: center;
        overflow-x: hidden;

        /* iPhone 14 Pro Max の論理幅に合わせて固定 */
        max-width: 430px;
        min-height: 100vh;
        position: relative;
        box-shadow: 0 0 50px rgba(0,0,0,0.5);
    }

    /* --- ヘッダー --- */
    .header-area {
        padding-top: calc(var(--sat) + 10px);
        padding-bottom: 15px;
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
        letter-spacing: 1px;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }

    /* ハンバーガーアイコン（ボタンデザイン化） */
    .hamburger {
        position: absolute;
        top: calc(var(--sat) + 8px);
        right: 20px;
        /* グラスモーフィズム風ボタンデザイン */
        width: 44px;
        height: 44px;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(5px);
        border-radius: 12px;
        border: 1px solid rgba(255, 255, 255, 0.1);
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        z-index: 1001;
        transition: transform 0.2s, background 0.2s;
        box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    }
    .hamburger i {
        font-size: 20px;
        color: var(--accent-cyan);
    }
    .hamburger:active {
        transform: scale(0.95);
        background: rgba(255, 255, 255, 0.2);
    }

    /* ▼▼▼ ロゴ下の挨拶エリア ▼▼▼ */
    .welcome-header {
        margin-bottom: 30px;
        padding: 0 20px;
    }
    .welcome-msg {
        font-size: 20px;
        font-weight: bold;
        color: #fff;
        margin: 0;
    }
    .user-id {
        font-size: 14px;
        color: #94a3b8;
        margin-top: 5px;
        font-weight: normal;
    }

    /* --- サイドメニュー --- */
    .side-menu {
        position: fixed;
        top: 0;
        right: auto; left: 50%;
        transform: translateX(100%);
        width: 100%;
        max-width: 430px;
        height: 100%;
        background: rgba(15, 23, 42, 0.98);
        backdrop-filter: blur(20px);
        transition: 0.35s cubic-bezier(0.32, 1.25, 0.32, 1);
        z-index: 2000;
        padding: calc(var(--sat) + 20px) 25px var(--sab);
        text-align: left;
        display: flex;
        flex-direction: column;
    }

    .side-menu.active {
        transform: translateX(-50%);
    }

    /* ▼▼▼ メニュー内 閉じる(戻る)ボタンエリア ▼▼▼ */
    .menu-header-actions {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 10px;
    }
    .menu-close-btn {
        background: rgba(255, 255, 255, 0.1);
        border: none;
        border-radius: 30px;
        padding: 8px 16px;
        color: white;
        font-size: 14px;
        font-weight: bold;
        display: flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        transition: background 0.2s;
    }
    .menu-close-btn i { font-size: 16px; color: var(--accent-cyan); }
    .menu-close-btn:active { background: rgba(255, 255, 255, 0.2); }

    /* サイドメニュー上部のプロフィール表示 */
    .side-profile-header {
        display: flex;
        align-items: center;
        gap: 15px;
        padding-bottom: 25px;
        margin-bottom: 20px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
        margin-top: 10px;
    }

    .side-avatar {
        width: 60px;
        height: 60px;
        background: linear-gradient(135deg, #00c6fb, #005bea);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
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
        font-size: 19px;
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

    /* メニュー内のお知らせリスト */
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
        font-weight: bold;
        margin-bottom: 6px;
        display: inline-block;
        color: white;
    }

    .mini-content {
        font-size: 14px;
        line-height: 1.5;
        color: #f1f5f9;
    }
    .mini-date {
        display: block;
        text-align: right;
        font-size: 11px;
        color: #94a3b8;
        margin-top: 5px;
    }

    /* 下部リンクエリア */
    .bottom-links {
        margin-top: auto;
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding-top: 20px;
        border-top: 1px solid rgba(255,255,255,0.1);
    }

    .sub-link {
        display: flex;
        align-items: center;
        gap: 12px;
        color: #e2e8f0;
        text-decoration: none;
        font-size: 16px;
        padding: 15px;
        background: rgba(255,255,255,0.07);
        border-radius: 12px;
        font-weight: bold;
        transition: 0.2s;
    }
    .sub-link:active { background: rgba(255,255,255,0.15); }

    .logout-link {
        color: #ff6b6b;
        border: 1px solid rgba(255, 107, 107, 0.4);
        background: rgba(255, 107, 107, 0.05);
    }

    /* --- メインコンテンツ --- */
    .main-content { padding: 0 24px 20px; }

    /* メニューグリッド */
    .menu-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        width: 100%;
        margin: 0 auto 30px;
    }
    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 160px; /* カード高さを調整 */
        border-radius: 24px;
        text-decoration: none;
        color: white;
        box-shadow: 0 4px 15px rgba(0,0,0,0.4);
        position: relative;
        overflow: hidden;
        transition: transform 0.1s;
    }
    .menu-card::after {
        content: ''; position: absolute;
        top:0; left:0; width:100%; height:100%;
        background: linear-gradient(to bottom, rgba(255,255,255,0.12), transparent);
    }
    .menu-card:active { transform: scale(0.97); }

    .icon-large { font-size: 42px; margin-bottom: 12px; }
    .menu-label { font-size: 16px; font-weight: bold; letter-spacing: 0.5px; }

    .card-green  { background: #10b981; }
    .card-orange { background: #f97316; }

    /* 重要なお知らせ（アラート） */
    .alert-container {
        width: 100%;
        margin: 0 auto;
    }
    .alert-board {
        background: rgba(69, 10, 10, 0.6);
        border: 1px solid #ff5252;
        border-radius: 20px;
        overflow: hidden;
        text-align: left;
        backdrop-filter: blur(5px);
        box-shadow: 0 4px 15px rgba(255, 82, 82, 0.1);
    }
    .alert-header {
        background-color: rgba(255, 82, 82, 0.9);
        color: white;
        padding: 12px 20px;
        font-weight: bold;
        font-size: 16px;
        display: flex; align-items: center; gap: 10px;
    }
    .alert-content {
        padding: 15px 20px;
        max-height: 180px;
        overflow-y: auto;
    }
    .alert-item {
        padding: 10px 0;
        border-bottom: 1px solid rgba(255, 82, 82, 0.3);
    }
    .alert-item:last-child { border-bottom: none; }
    .alert-time { font-size: 12px; color: #ffadad; display: block; margin-bottom: 2px; }
    .alert-msg { font-size: 15px; color: #ffe5e5; line-height: 1.5; }

    .overlay {
        position: fixed;
        top: 0; left: 50%; transform: translateX(-50%);
        width: 100%; max-width: 430px;
        height: 100%;
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
        <p class="welcome-msg">こんにちは、<%= userName %> 様</p>
        <p class="user-id">（ID: <%= userId %>）</p>
    </div>

    <div class="overlay" id="menu-overlay"></div>

    <div class="side-menu" id="side-menu">

        <div class="menu-header-actions">
            <button class="menu-close-btn" onclick="toggleMenu()">
                <i class="fas fa-times"></i> 閉じる
            </button>
        </div>

        <div class="side-profile-header">
            <div class="side-avatar"><%= initial %></div>
            <div class="side-user-info">
                <span class="side-name"><%= userName %></span>
                <span class="side-id">ID: <%= userId %></span>
            </div>
        </div>

        <div class="menu-section-title">
            <i class="fas fa-bullhorn"></i> 教員からのお知らせ
        </div>

        <div class="mini-notice-list">
            <%
                if (list != null && !list.isEmpty()) {
                    boolean hasTeacherNotice = false;
                    for (Map<String, Object> item : list) {
                        Object roleObj = item.get("Role");
                        String noticeRole = (roleObj != null) ? roleObj.toString() : "";

                        if ("teacher".equalsIgnoreCase(noticeRole)) {
                            hasTeacherNotice = true;
                            String category = (item.get("CATEGORY") != null) ? item.get("CATEGORY").toString() : "";
                            String content = (item.get("Content") != null) ? item.get("Content").toString() : "";
                            String date = (item.get("Posted_On") != null) ? item.get("Posted_On").toString() : "";

                            String badgeCol = "#3b82f6";
                            if ("重要".equals(category)) badgeCol = "#ef4444";
                            else if ("イベント".equals(category)) badgeCol = "#10b981";
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
                <p style="font-size:14px; color:#94a3b8; text-align:center; margin-top:30px;">現在お知らせはありません</p>
            <%
                    }
                } else {
            %>
                <p style="font-size:14px; color:#94a3b8; text-align:center; margin-top:30px;">現在お知らせはありません</p>
            <% } %>
        </div>

        <div class="bottom-links">
            <div class="menu-section-title" style="font-size:16px; border:none; padding:0; margin-bottom:5px;">
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
            <a href="<%= request.getContextPath() %>/AttendanceParentServlet" class="menu-card card-green">
                <i class="fas fa-clipboard-user icon-large"></i>
                <span class="menu-label">学生の<br>出席状況</span>
            </a>

            <a href="<%= request.getContextPath() %>/H_syukatuServlet" class="menu-card card-orange">
                <i class="fas fa-briefcase icon-large"></i>
                <span class="menu-label">学生の<br>就活状況</span>
            </a>
        </div>

        <div class="alert-container">
            <div class="alert-board">
                <div class="alert-header">
                    <i class="fas fa-exclamation-circle"></i> 重要なお知らせ
                </div>
                <div class="alert-content">
                    <% if (alertList != null && !alertList.isEmpty()) {
                        for (Map<String, String> msg : alertList) { %>
                        <div class="alert-item">
                            <span class="alert-time"><%= msg.get("time") %></span>
                            <span class="alert-msg"><%= msg.get("message").replace("\n", "<br>") %></span>
                        </div>
                    <%  }
                       } else { %>
                        <div style="padding: 15px; color: #ffcccc; font-size: 14px;">現在、重要なお知らせはありません。</div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>

    <script>
        const btn = document.getElementById('hamburger-btn');
        const menu = document.getElementById('side-menu');
        const overlay = document.getElementById('menu-overlay');

        function toggleMenu() {
            menu.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        btn.addEventListener('click', toggleMenu);
        overlay.addEventListener('click', toggleMenu);
    </script>
</body>
</html>