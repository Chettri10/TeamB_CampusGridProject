<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("../jsp/error_permission.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お知らせ投稿</title>
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
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }
        h2 { color: #00E5FF; text-align: center; }
        label { font-size: 14px; margin-top: 10px; display: block; }
        input, select, textarea {
            width: 100%; padding: 8px; border-radius: 8px;
            border: 1px solid #CCC; margin-top: 5px;
        }
        textarea { height: 100px; }
        .btn-area { display: flex; gap: 10px; margin-top: 20px; }
        .btn { flex: 1; padding: 10px; border-radius: 8px; font-weight: 600; text-align: center; }
        .btn-post { background: #00E5FF; color: #000; }
        .btn-cancel { background: #555; color: #FFF; }
    </style>
</head>

<body>
<div class="card">
    <h2>お知らせ投稿</h2>

    <!-- ★ 重要：絶対パスで Servlet に送る -->
    <form action="<%= request.getContextPath() %>/NoticePostServlet" method="post">

        <label>カテゴリ</label>
        <select name="category">
            <option value="重要">重要</option>
            <option value="連絡">連絡</option>
            <option value="イベント">イベント</option>
        </select>

        <label>内容</label>
        <textarea name="content"></textarea>

        <div class="btn-area">
            <button type="submit" class="btn btn-post">投稿する</button>
            <a href="teacher_home.jsp" class="btn btn-cancel">戻る</a>
        </div>
    </form>
</div>
</body>
</html>
