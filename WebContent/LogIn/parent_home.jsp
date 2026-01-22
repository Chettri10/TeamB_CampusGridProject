<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>
<%
    // セッションからユーザー情報を取得
    Map<String, Object> userMap = (Map<String, Object>) session.getAttribute("user");
    String userName = "ゲスト";

    if (userMap != null) {
        Object nameObj = userMap.get("User_Name");
        if (nameObj != null) {
            userName = (String) nameObj;
        }
    } else {
        response.sendRedirect("login.jsp");
        return;
    }

    NoticeDao dao = new NoticeDao();
    List<Map<String, Object>> list = dao.findAll();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>保護者ホーム - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 0;
        text-align: center;
    }

    .header-area {
        margin-top: 40px;
        margin-bottom: 20px;
    }

    h1 {
        color: #00ffff;
        font-size: 32px;
        margin-bottom: 10px;
        font-weight: bold;
        letter-spacing: 2px;
    }

    .welcome-msg {
        font-size: 18px;
        color: #eee;
    }

    /* メニューボタンエリア */
    .action-menu {
        display: flex;
        justify-content: center;
        gap: 20px;
        margin: 30px auto;
        flex-wrap: wrap;
    }

    /* アクションボタンのデザイン */
    .btn-action {
        background: linear-gradient(135deg, #00ffff 0%, #00cccc 100%);
        color: #020617;
        padding: 15px 30px;
        border-radius: 50px;
        text-decoration: none;
        font-weight: bold;
        font-size: 16px;
        box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3);
        transition: transform 0.2s, box-shadow 0.2s;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .btn-action:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 20px rgba(0, 255, 255, 0.5);
    }

    .btn-action i {
        font-size: 20px;
    }

    /* お知らせ板 */
    .notice-board {
        background-color: #ffffff;
        color: #333;
        width: 85%;
        max-width: 700px;
        margin: 0 auto 50px auto;
        border-radius: 12px;
        padding: 25px;
        text-align: left;
        box-shadow: 0 0 20px rgba(255,255,255,0.1);
    }

    .notice-header-area {
        border-bottom: 2px solid #eee;
        padding-bottom: 10px;
        margin-bottom: 15px;
    }

    .notice-title {
        font-size: 20px;
        font-weight: bold;
        color: #020617;
    }

    .notice-item {
        border-bottom: 1px solid #f0f0f0;
        padding: 10px 0;
    }

    .notice-item:last-child { border-bottom: none; }

    .notice-meta { font-size: 12px; color: #888; margin-bottom: 4px; }

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
        <div class="welcome-msg">こんにちは、<%= userName %> 様（保護者）</div>
    </div>

    <div class="action-menu">
        <a href="<%= request.getContextPath() %>/AttendanceParentServlet" class="btn-action">
            <i class="fas fa-calendar-check"></i> 出席状況を確認
        </a>
    </div>

    <div class="notice-board">
        <div class="notice-header-area">
            <div class="notice-title">お知らせ（教員より）</div>
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

    <a href="logout.jsp" class="logout-link">ログアウト</a>

</body>
</html>