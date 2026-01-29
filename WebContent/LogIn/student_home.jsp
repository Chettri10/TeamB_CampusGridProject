<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>
<%
    // --- 1. セッションチェック ---
    String username = (String) session.getAttribute("userName");
    String userId = (String) session.getAttribute("userId");

    if (username == null || userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // --- 2. お知らせ取得 ---
    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>CAMPUS GRID - Student</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* --- iPhone 14 Pro Max & 共通デザイン設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 50px);
        --sab: env(safe-area-inset-bottom, 34px);
        --bg-color: #020617; /* 深い紺色 */
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

    /* --- ヘッダー --- */
    .header-area {
        padding-top: calc(var(--sat) + 30px);
        padding-bottom: 10px;
        flex-shrink: 0;
    }

    .logo {
        color: var(--accent-cyan);
        font-size: 32px;
        margin: 0 0 10px 0;
        font-weight: 900;
        letter-spacing: 1px;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }
    .greeting { font-size: 16px; color: #fff; font-weight: bold; }
    .user-id { font-size: 13px; color: #94a3b8; margin-top: 5px; }

    /* --- メニューグリッド --- */
    .menu-container {
        display: grid;
        grid-template-columns: 1fr 1fr; /* 2列 */
        gap: 20px;
        padding: 20px 24px;
        width: 100%;
        max-width: 500px;
        margin: 0 auto 20px auto;
    }

    /* ボタン共通 */
    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 150px; /* 大きく押しやすく */
        border-radius: 20px;
        text-decoration: none;
        color: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.4);
        position: relative;
        transition: transform 0.1s;
    }
    .menu-card:active { transform: scale(0.97); }

    .icon-large { font-size: 40px; margin-bottom: 12px; }
    .menu-label {
        font-size: 16px;
        font-weight: bold;
        line-height: 1.4;
    }

    /* カラー設定 */
    .card-green  { background: linear-gradient(135deg, #22c55e, #15803d); } /* 出席 */
    .card-blue   { background: linear-gradient(135deg, #3b82f6, #1d4ed8); } /* チャット */
    .card-purple { background: linear-gradient(135deg, #d946ef, #a21caf); } /* 商品 */
    .card-orange { background: linear-gradient(135deg, #f97316, #c2410c); } /* 就活 */

    /* --- お知らせセクション（シート風） --- */
    .notice-section {
        background-color: #ffffff;
        color: #333;
        border-radius: 30px 30px 0 0;
        flex-grow: 1;
        min-height: 450px;
        padding: 25px 24px 80px; /* 下部はホームバー回避 */
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
        font-size: 20px;
        font-weight: 800;
        color: #0f172a;
        margin-bottom: 20px;
        padding-left: 15px;
        display: flex;
        align-items: center;
    }

    .notice-list { list-style: none; padding: 0; margin: 0; }

    .notice-item {
        border-bottom: 1px solid #f1f5f9;
        padding: 15px 0;
    }
    .notice-item:last-child { border-bottom: none; }

    .badge {
        padding: 4px 10px;
        border-radius: 6px;
        color: white;
        font-size: 11px;
        font-weight: bold;
        margin-right: 6px;
        background-color: #3b82f6;
    }

    .notice-content { font-size: 15px; color: #334155; line-height: 1.5; }
    .notice-date { font-size: 12px; color: #94a3b8; margin-top: 4px; display: block; text-align: right; }

    /* ログアウト */
    .logout-area { margin-top: 40px; text-align: center; }
    .logout-btn {
        display: inline-block;
        color: #ff5252;
        border: 2px solid #ff5252;
        padding: 12px 40px;
        border-radius: 30px;
        text-decoration: none;
        font-weight: bold;
        font-size: 14px;
    }
</style>
</head>
<body>

    <div class="header-area">
        <div class="logo">CAMPUS GRID</div>
        <div class="greeting">こんにちは、<%= username %> さん</div>
        <div class="user-id">(ID: <%= userId %>)</div>
    </div>

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

    <div class="notice-section">
        <div class="notice-bar"></div>
        <div class="notice-header">教員からのお知らせ</div>

        <div class="notice-list">
            <%
            if (list != null && !list.isEmpty()) {
                boolean hasTeacherNotice = false;
                for (Map<String, Object> item : list) {
                    String role = (String)item.get("Role");
                    // 教員の投稿のみ表示
                    if ("teacher".equalsIgnoreCase(role)) {
                        hasTeacherNotice = true;
                        String category = (String)item.get("CATEGORY");
                        String content  = (String)item.get("Content");
                        String date     = String.valueOf(item.get("Posted_On"));
            %>
                <div class="notice-item">
                    <div>
                        <span class="badge"><%= category %></span>
                        <span class="notice-content"><%= content %></span>
                    </div>
                    <span class="notice-date"><%= date %></span>
                </div>
            <%
                    }
                }
                if (!hasTeacherNotice) {
            %>
                <p style="text-align:center; color:#94a3b8; padding:20px;">現在、お知らせはありません。</p>
            <%
                }
            } else {
            %>
                <p style="text-align:center; color:#94a3b8; padding:20px;">現在、お知らせはありません。</p>
            <% } %>
        </div>

        <div class="logout-area">
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="logout-btn">ログアウト</a>
        </div>
    </div>

</body>
</html>