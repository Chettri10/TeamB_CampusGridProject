<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }

    int id = Integer.parseInt(request.getParameter("id"));
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>お知らせ削除</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
    body { background:#030820; color:#fff; font-family:'Noto Sans JP'; padding:20px; }
    .container { max-width:400px; margin:0 auto; background:#fff; color:#333; padding:20px; border-radius:12px; text-align:center; }
    h2 { color:#FF5252; }
    .btn { display:block; width:100%; padding:12px; margin-top:20px; border-radius:8px; text-align:center; font-weight:600; text-decoration:none; }
    .btn-del { background:#FF5252; color:#fff; }
    .btn-back { background:#00E5FF; color:#000;width:350px; margin: 30px auto 0 auto;}
</style>
</head>

<body>

<div class="container">
    <h2>本当に削除しますか？</h2>

    <!-- ★ 削除ボタンだけ残す -->
    <form action="<%= request.getContextPath() %>/NoticeDeleteServlet" method="post">
        <input type="hidden" name="id" value="<%= id %>">
        <button type="submit" class="btn btn-del">削除する</button>
    </form>

    <a href="teacher_home.jsp" class="btn btn-back">戻る</a>
</div>

</body>
</html>
