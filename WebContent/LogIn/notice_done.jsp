<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>投稿完了</title>
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
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }
        h2 {
            color: #00E5FF;
            margin-bottom: 20px;
        }
        .btn {
            display: block;
            margin-top: 25px;
            padding: 12px;
            background: #00E5FF;
            color: #000;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>

<body>
<div class="card">
    <h2>投稿が完了しました</h2>

    <p>お知らせが正常に投稿されました。</p>

    <!-- ★ 絶対パスで LogIn/teacher_home.jsp に戻る -->
    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="btn">
        お知らせ一覧へ戻る
    </a>
</div>
</body>
</html>
