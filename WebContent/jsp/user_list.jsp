<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<title>チャット相手を選択 - キャンパスグリッド</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    /* --- iPhone 14 Pro Max (430px) 最適化設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 50px);
        --sab: env(safe-area-inset-bottom, 34px);
    }

    html {
        background-color: #000; /* 枠外は黒 */
        height: 100%;
    }

    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        display: flex;
        flex-direction: column;
        align-items: center;
        margin: 0 auto; /* 中央寄せ */
        padding: 0 20px; /* 横の余白 */
        position: relative;
        min-height: 100vh;

        /* iPhone 14 Pro Max 幅固定 */
        max-width: 430px;
        box-shadow: 0 0 50px rgba(0,0,0,0.5);
        padding-top: calc(var(--sat) + 10px); /* Dynamic Island回避 */
    }

    h1 {
        margin-bottom: 25px;
        margin-top: 50px; /* ヘッダーボタンとの距離確保 */
        text-align: center;
        color: #00ffff;
        font-size: 22px;
    }

    /* 戻るボタンのスタイル */
    .header-nav {
        position: absolute;
        top: calc(var(--sat) + 15px); /* 安全領域を考慮して配置 */
        left: 20px;
        z-index: 10;
    }
    .back-btn {
        color: #00ffff;
        font-size: 15px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: bold;
        background-color: rgba(21, 31, 66, 0.9);
        padding: 10px 16px; /* タップしやすいサイズへ拡大 */
        border-radius: 20px;
        transition: opacity 0.3s;
        backdrop-filter: blur(4px);
    }
    .back-btn:hover { opacity: 0.8; color: white; }

    /* ★検索エリアのスタイル */
    .search-container {
        width: 100%;
        margin-bottom: 25px;
    }
    .search-form {
        display: flex;
        gap: 10px;
        height: 50px; /* 高さ固定で押しやすく */
    }
    .search-input {
        flex-grow: 1;
        background-color: #151f42;
        border: 1px solid #33416b;
        border-radius: 12px;
        padding: 0 15px;
        color: white;
        outline: none;
        font-size: 16px; /* iOSでズームしないサイズ */
    }
    .search-input:focus { border-color: #00ffff; }
    .search-btn {
        background-color: #00ffff;
        color: #020617;
        border: none;
        padding: 0 24px;
        border-radius: 12px;
        font-weight: bold;
        cursor: pointer;
        font-size: 16px;
        white-space: nowrap;
    }

    .list-label {
        width: 100%;
        font-size: 14px;
        color: #8892b0;
        margin-bottom: 12px;
        padding-left: 5px;
        font-weight: bold;
    }

    .user-list {
        width: 100%;
        background-color: #151f42;
        border-radius: 20px;
        padding: 5px; /* 内側余白調整 */
        box-sizing: border-box;
        margin-bottom: var(--sab); /* 下部セーフエリア確保 */
    }

    .user-item {
        display: flex;
        align-items: center;
        padding: 18px 15px; /* リストの高さを広げてタップしやすく */
        border-bottom: 1px solid #33416b;
        text-decoration: none;
        color: white;
        transition: background 0.3s;
    }
    .user-item:last-child { border-bottom: none; }
    .user-item:hover { background-color: #1e2a5a; border-radius: 15px; }

    .icon {
        width: 48px; height: 48px; /* アイコンサイズ拡大 */
        background-color: #00ffff;
        color: #020617;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        margin-right: 16px;
        font-size: 24px;
        flex-shrink: 0;
    }
    .name { font-size: 17px; font-weight: bold; }
    .id { font-size: 13px; color: #8892b0; margin-left: 8px; }
</style>
</head>
<body>

    <%
        String myId = (String)request.getAttribute("myId");
        List<String[]> list = (List<String[]>)request.getAttribute("userList");
        Boolean isSearch = (Boolean)request.getAttribute("isSearch");
        if(isSearch == null) isSearch = false;

        // ホームへ戻るためのURL決定ロジック
        String homeUrl = "";
        if (myId != null && myId.startsWith("T")) {
            homeUrl = request.getContextPath() + "/LogIn/teacher_home.jsp";
        } else {
            homeUrl = request.getContextPath() + "/LogIn/student_home.jsp";
        }
    %>

    <div class="header-nav">
        <a href="<%= homeUrl %>" class="back-btn">
            <i class="fas fa-arrow-left"></i> ホーム
        </a>
    </div>

    <h1>メッセージ</h1>

    <div class="search-container">
        <form action="ChatServlet" method="get" class="search-form">
            <input type="hidden" name="action" value="list">
            <input type="hidden" name="myId" value="<%= myId %>">
            <input type="text" name="keyword" class="search-input"
                   placeholder="氏名またはIDで検索..."
                   value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <button type="submit" class="search-btn">検索</button>
        </form>
    </div>

    <div class="list-label">
        <i class="fas <%= isSearch ? "fa-search" : "fa-history" %>"></i>
        <%= isSearch ? "検索結果" : "最近のチャット" %>
    </div>

    <div class="user-list">
        <%
            if(list != null && !list.isEmpty()) {
                for(String[] user : list) {
                    String userId = user[0];
                    String userName = user[1];
        %>
            <a href="ChatServlet?myId=<%= myId %>&targetId=<%= userId %>" class="user-item">
                <div class="icon"><i class="fas fa-user"></i></div>
                <div>
                    <span class="name"><%= userName %></span>
                    <span class="id">(<%= userId %>)</span>
                </div>
                <div style="margin-left: auto; color: #00ffff;">
                    <i class="fas fa-chevron-right"></i>
                </div>
            </a>
        <%
                }
            } else {
        %>
            <div style="text-align:center; padding:50px 20px; color:#8892b0;">
                <i class="fas fa-user-slash" style="font-size:36px; margin-bottom:15px; display:block;"></i>
                <p style="line-height: 1.6;"><%= isSearch ? "該当するユーザーが見つかりません" : "まだチャット履歴がありません。<br>上の検索窓から相手を探しましょう！" %></p>
            </div>
        <%
            }
        %>
    </div>

</body>
</html>