<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>チャット相手を選択 - キャンパスグリッド</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 20px;
        position: relative;
        min-height: 100vh;
    }

    h1 { margin-bottom: 20px; margin-top: 10px; text-align: center; color: #00ffff; }

    /* 戻るボタンのスタイル */
    .header-nav {
        position: absolute;
        top: 20px;
        left: 20px;
    }
    .back-btn {
        color: #00ffff;
        font-size: 16px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: bold;
        background-color: rgba(21, 31, 66, 0.8);
        padding: 8px 12px;
        border-radius: 8px;
        transition: opacity 0.3s;
    }
    .back-btn:hover { opacity: 0.8; color: white; }

    /* ★検索エリアのスタイル */
    .search-container {
        width: 100%;
        max-width: 500px;
        margin-bottom: 20px;
    }
    .search-form {
        display: flex;
        gap: 8px;
    }
    .search-input {
        flex-grow: 1;
        background-color: #151f42;
        border: 1px solid #33416b;
        border-radius: 8px;
        padding: 12px;
        color: white;
        outline: none;
    }
    .search-input:focus { border-color: #00ffff; }
    .search-btn {
        background-color: #00ffff;
        color: #020617;
        border: none;
        padding: 0 20px;
        border-radius: 8px;
        font-weight: bold;
        cursor: pointer;
    }

    .list-label {
        width: 100%;
        max-width: 500px;
        font-size: 14px;
        color: #8892b0;
        margin-bottom: 8px;
        padding-left: 5px;
    }

    .user-list {
        width: 100%;
        max-width: 500px;
        background-color: #151f42;
        border-radius: 15px;
        padding: 10px;
        box-sizing: border-box;
    }

    .user-item {
        display: flex;
        align-items: center;
        padding: 15px;
        border-bottom: 1px solid #33416b;
        text-decoration: none;
        color: white;
        transition: background 0.3s;
    }
    .user-item:last-child { border-bottom: none; }
    .user-item:hover { background-color: #1e2a5a; border-radius: 10px; }

    .icon {
        width: 40px; height: 40px;
        background-color: #00ffff;
        color: #020617;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        margin-right: 15px;
        font-size: 20px;
    }
    .name { font-size: 18px; font-weight: bold; }
    .id { font-size: 12px; color: #8892b0; margin-left: 10px; }
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
            <div style="text-align:center; padding:40px; color:#8892b0;">
                <i class="fas fa-user-slash" style="font-size:30px; margin-bottom:10px; display:block;"></i>
                <p><%= isSearch ? "該当するユーザーが見つかりません" : "まだチャット履歴がありません。<br>上の検索窓から相手を探しましょう！" %></p>
            </div>
        <%
            }
        %>
    </div>

</body>
</html>