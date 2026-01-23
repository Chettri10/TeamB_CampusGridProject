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
        position: relative; /* 戻るボタンの配置のため */
        min-height: 100vh;
    }

    h1 { margin-bottom: 30px; margin-top: 10px; text-align: center; }

    /* 戻るボタンのスタイル */
    .header-nav {
        position: absolute;
        top: 20px;
        left: 20px;
    }
    .back-btn {
        color: #00ffff;
        font-size: 18px;
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

    .user-list {
        width: 100%;
        max-width: 500px;
        background-color: #151f42;
        border-radius: 15px;
        padding: 20px;
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

        // ▼▼▼ ホームへ戻るためのURL決定ロジック ▼▼▼
        String homeUrl = "";

        // request.getContextPath() は "/ProjectName" のようなルートパスを取得します
        // これにより、リンク切れを防ぎます。

        // 【条件分岐】IDが "T" で始まるなら先生、それ以外は学生と判定しています。
        // ※必要に応じて条件式を変更してください (例: userRole変数がsessionにある場合など)
        if (myId != null && myId.startsWith("T")) {
            // 先生の場合
            homeUrl = request.getContextPath() + "/LogIn/teacher_home.jsp";
        } else {
            // 学生の場合 (デフォルト)
            homeUrl = request.getContextPath() + "/LogIn/student_home.jsp";
        }
    %>

    <div class="header-nav">
        <a href="<%= homeUrl %>" class="back-btn">
            <i class="fas fa-arrow-left"></i> ホーム
        </a>
    </div>

    <h1>チャット相手を選択</h1>

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
                    <i class="fas fa-comment-dots"></i>
                </div>
            </a>
        <%
                }
            } else {
        %>
            <p style="text-align:center; padding:20px;">チャット可能な相手が見つかりません。</p>
        <%
            }
        %>
    </div>

</body>
</html>