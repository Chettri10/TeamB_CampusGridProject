<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="dao.ChatDao" %>
<%@ page import="java.util.*" %>
<%
    // --- セッション確認 ---
    String userName = (String) session.getAttribute("userName");
    String parentId = (String) session.getAttribute("userId"); // 保護者ID

    // 1. 学校全体のお知らせ取得
    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();

    // 2. 保護者宛ての通知（遅刻・早退など）を取得
    List<Map<String, String>> alertList = new ArrayList<>();
    if (parentId != null) {
        ChatDao chatDao = new ChatDao();
        alertList = chatDao.getReceivedMessages(parentId);
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>保護者ホーム - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    /* --- 全体設定 --- */
    body {
        background-color: #020617; /* ダーク背景 */
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 0;
        text-align: center;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .header-area {
        margin-top: 50px;
        margin-bottom: 30px;
    }

    h1 {
        color: #00ffff; /* シアン色 */
        font-size: 36px;
        margin: 0 0 10px 0;
        font-weight: bold;
        letter-spacing: 2px;
    }

    .welcome-msg {
        font-size: 20px;
        color: #fff;
        margin-bottom: 5px;
    }

    /* --- ボタンエリア（学生の出席状況） --- */
    .menu-container {
        display: flex;
        justify-content: center;
        width: 100%;
        max-width: 800px;
        margin-bottom: 40px; /* 下に余白 */
        padding: 0 20px;
    }

    .menu-card {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        width: 240px; /* 少し大きくしました */
        height: 160px;
        border-radius: 20px;
        text-decoration: none;
        color: white;
        font-weight: bold;
        font-size: 18px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        transition: transform 0.2s, box-shadow 0.2s;
        /* 緑グラデーション */
        background: linear-gradient(135deg, #42e695 0%, #3bb2b8 100%);
    }

    .menu-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.5);
    }

    .menu-card i {
        font-size: 48px;
        margin-bottom: 15px;
    }

    /* --- 重要なお知らせ（赤枠） --- */
    .alert-board {
        background-color: #2b0a0a; /* 暗い赤背景 */
        border: 2px solid #ff5252; /* 赤い枠線 */
        color: #fff;
        width: 90%;
        max-width: 600px;
        margin-bottom: 30px;
        border-radius: 12px;
        padding: 0;
        text-align: left;
        box-shadow: 0 0 15px rgba(255, 82, 82, 0.3);
        overflow: hidden;
    }

    .alert-header {
        background-color: #ff5252;
        color: white;
        padding: 15px 20px;
        font-weight: bold;
        font-size: 18px;
        display: flex;
        align-items: center;
    }
    .alert-header i { margin-right: 10px; font-size: 20px; }

    .alert-content {
        padding: 10px 20px 20px 20px;
        max-height: 200px; /* 高さを抑える */
        overflow-y: auto;
    }

    .alert-item {
        padding: 15px 0;
        border-bottom: 1px solid #5c2b2b;
        font-size: 15px;
        line-height: 1.6;
    }
    .alert-item:last-child { border-bottom: none; }

    .alert-time {
        font-size: 12px;
        color: #ffadad;
        margin-bottom: 5px;
        display: block;
    }

    .alert-msg { color: #fff; font-weight: 500; }

    /* --- 学校からのお知らせ（白枠） --- */
    .notice-board {
        background-color: #ffffff;
        color: #333;
        width: 90%;
        max-width: 600px;
        border-radius: 12px;
        padding: 20px;
        text-align: left;
        box-shadow: 0 -4px 20px rgba(0,0,0,0.5);
        margin-bottom: 30px;
    }

    .notice-header-area {
        border-bottom: 2px solid #eee;
        padding-bottom: 10px;
        margin-bottom: 15px;
    }

    .notice-title {
        font-size: 18px;
        font-weight: bold;
        color: #020617;
    }

    .notice-title i {
        color: #e91e63;
        margin-right: 8px;
    }

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

    .logout-link {
        color: #aaa;
        text-decoration: none;
        font-size: 14px;
        margin-bottom: 20px;
    }
    .logout-link:hover { color: white; }
</style>
</head>
<body>

    <div class="header-area">
        <h1>CAMPUS GRID</h1>
        <div class="welcome-msg">こんにちは、<%= userName %> 様</div>
    </div>

    <div class="menu-container">
        <a href="<%= request.getContextPath() %>/AttendanceParentServlet" class="menu-card">
            <i class="fas fa-clipboard-check"></i>
            <span>学生の出席状況</span>
        </a>
    </div>

    <div class="alert-board">
        <div class="alert-header">
            <i class="fas fa-bell"></i> 重要なお知らせ（遅刻・欠席等）
        </div>

        <div class="alert-content">
        <%
            if (alertList != null && !alertList.isEmpty()) {
                for (Map<String, String> msg : alertList) {
                    String message = msg.get("message");
                    String time = msg.get("time");
        %>
            <div class="alert-item">
                <span class="alert-time"><%= time %></span>
                <span class="alert-msg"><%= message.replace("\n", "<br>") %></span>
            </div>
        <%
                }
            } else {
        %>
            <div style="padding: 20px; text-align: center; color: #ffadad;">
                現在、通知はありません。
            </div>
        <%
            }
        %>
        </div>
    </div>

    <div class="notice-board">
        <div class="notice-header-area">
            <div class="notice-title"><i class="fas fa-bullhorn"></i> お知らせ（教員より）</div>
        </div>

        <div class="notice-list">
        <%
            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> item : list) {
                    String category = (String)item.get("CATEGORY");
                    String content  = (String)item.get("Content");
                    String date     = String.valueOf(item.get("Posted_On"));
                    String role     = (String)item.get("Role");

                    if ("teacher".equalsIgnoreCase(role)) {
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
            </div>
        <%
                    }
                }
            } else {
        %>
            <p style="color:#888; text-align:center; padding:20px;">現在、お知らせはありません。</p>
        <%
            }
        %>
        </div>
    </div>

    <a href="LogOut.jsp" class="logout-link">ログアウト</a>

</body>
</html>