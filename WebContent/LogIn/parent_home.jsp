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
    /* --- 共通デザイン設定 --- */
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
        letter-spacing: 1px;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }

    /* ハンバーガーアイコン */
    .hamburger {
        position: absolute;
        top: calc(var(--sat) + 22px);
        right: 25px;
        font-size: 28px;
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
        font-size: 18px;
        font-weight: bold;
        color: var(--accent-cyan);
        margin-bottom: 15px;
        display: flex;
        align-items: center;
        gap: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.2);
        padding-bottom: 10px;
    }

    /* メニュー内のお知らせリスト */
    .mini-notice-list {
        flex-grow: 1;
        overflow-y: auto;
        margin-bottom: 20px;
        padding-right: 5px;
    }

    .mini-notice-item {
        margin-bottom: 15px;
        background: rgba(255,255,255,0.05);
        padding: 15px;
        border-radius: 12px;
        border: 1px solid rgba(255,255,255,0.1);
    }

    .mini-badge {
        font-size: 11px;
        padding: 3px 8px;
        border-radius: 6px;
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
        gap: 10px;
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
        transition: 0.2s;
    }
    .sub-link:active { background: rgba(255,255,255,0.15); }

    .logout-link {
        color: #ff6b6b;
        border: 1px solid rgba(255, 107, 107, 0.4);
        background: rgba(255, 107, 107, 0.05);
    }

    /* --- メインコンテンツ --- */
    .main-content { padding: 10px 24px; }
    .welcome-box { margin-bottom: 20px; }
    .welcome-msg { font-size: 20px; font-weight: bold; }
    .user-id { font-size: 14px; color: #94a3b8; margin-top: 4px; }

    /* メニューグリッド */
    .menu-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        max-width: 500px;
        margin: 0 auto 30px; /* 下に余白を追加 */
    }
    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 150px;
        border-radius: 20px;
        text-decoration: none;
        color: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.4);
        transition: transform 0.1s;
    }
    .menu-card:active { transform: scale(0.97); }
    .icon-large { font-size: 40px; margin-bottom: 12px; }
    .menu-label { font-size: 16px; font-weight: bold; }

    .btn-attendance { background: linear-gradient(135deg, #059669, #10b981); }
    .btn-job { background: linear-gradient(135deg, #0284c7, #38bdf8); }

    /* 重要なお知らせ（アラート） */
    .alert-container {
        width: 100%;
        max-width: 500px;
        margin: 0 auto;
    }
    .alert-board {
        background: rgba(69, 10, 10, 0.6);
        border: 1px solid #ff5252;
        border-radius: 16px;
        overflow: hidden;
        text-align: left;
        backdrop-filter: blur(5px);
    }
    .alert-header {
        background-color: rgba(255, 82, 82, 0.9);
        color: white;
        padding: 10px 20px;
        font-weight: bold;
        font-size: 15px;
        display: flex; align-items: center; gap: 10px;
    }
    .alert-content {
        padding: 15px 20px;
        max-height: 150px;
        overflow-y: auto;
    }
    .alert-item {
        padding: 8px 0;
        border-bottom: 1px solid rgba(255, 82, 82, 0.3);
    }
    .alert-item:last-child { border-bottom: none; }
    .alert-time { font-size: 11px; color: #ffadad; display: block; }
    .alert-msg { font-size: 14px; color: #ffe5e5; }

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
                            else if ("イベント".equals(category)) badgeCol = "#22c55e";
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
                <i class="fas fa-cog"></i>アカウント設定
            </div>

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
            <div class="welcome-msg">こんにちは、<%= userName %> 様</div>
            <div class="user-id">(ID: <%= userId %>)</div>
        </div>

        <div class="menu-container">
            <a href="<%= request.getContextPath() %>/AttendanceParentServlet" class="menu-card btn-attendance">
                <i class="fas fa-clipboard-user icon-large"></i>
                <span class="menu-label">学生の<br>出席状況</span>
            </a>

            <a href="<%= request.getContextPath() %>/H_syukatuServlet" class="menu-card btn-job">
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