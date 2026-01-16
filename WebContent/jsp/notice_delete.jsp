<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }

    String id = request.getParameter("id");
    String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お知らせ削除</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            background-color: #030820;
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .card {
            background: #FFF;
            color: #333;
            width: 90%;
            max-width: 380px;
            padding: 25px;
            border-radius: 12px;
            text-align: center;
        }
        h2 { color: #FF5252; }
        .btn-area { display: flex; gap: 10px; margin-top: 20px; }
        .btn { flex: 1; padding: 10px; border-radius: 8px; font-weight: 600; text-align: center; }
        .btn-delete { background: #FF5252; color: #FFF; }
        .btn-cancel { background: #555; color: #FFF; }
    </style>
</head>

<body>
<div class="card">
    <h2>削除確認</h2>
    <p>以下のお知らせを削除しますか？</p>
    <p><strong><%= message %></strong></p>

    <form action="NoticeDeleteServlet" method="post">
        <input type="hidden" name="id" value="<%= id %>">

        <div class="btn-area">
            <button type="submit" class="btn btn-delete">削除する</button>
            <a href="teacher_home.jsp" class="btn btn-cancel">戻る</a>
        </div>
    </form>
</div>
</body>
</html>
