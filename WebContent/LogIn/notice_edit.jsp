<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.NoticeDao" %>
<%@ page import="java.util.*" %>

<%
    // ★ 教員チェック
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("teacher")) {
        response.sendRedirect("error_permission.jsp");
        return;
    }

    // ★ 編集対象ID
    int id = Integer.parseInt(request.getParameter("id"));

    // ★ DBから1件取得
    NoticeDao dao = new NoticeDao();
    Map<String, Object> notice = dao.findById(id);

    if (notice == null) {
        out.println("データが見つかりません");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>お知らせ編集</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
    body { background:#030820; color:#fff; font-family:'Noto Sans JP'; padding:20px; }
    .container { max-width:400px; margin:0 auto; background:#fff; color:#333; padding:20px; border-radius:12px; }
    h2 { text-align:center; color:#00E5FF; }
    label { font-weight:bold; margin-top:10px; display:block; }
    select, textarea { width:100%; padding:10px; margin-top:5px; border-radius:8px; border:1px solid #ccc; }
    .btn { display:block; width:100%; padding:12px; margin-top:20px; background:#00E5FF; color:#000; border-radius:8px; text-align:center; font-weight:600; text-decoration:none; }
</style>
</head>

<body>

<div class="container">
    <h2>お知らせ編集</h2>

    <form action="<%= request.getContextPath() %>/NoticeEditServlet" method="post">


        <input type="hidden" name="id" value="<%= notice.get("Notification_ID") %>">

        <label>カテゴリ</label>
        <select name="category">
            <option value="重要" <%= "重要".equals(notice.get("CATEGORY")) ? "selected" : "" %>>重要</option>
            <option value="連絡" <%= "連絡".equals(notice.get("CATEGORY")) ? "selected" : "" %>>連絡</option>
            <option value="イベント" <%= "イベント".equals(notice.get("CATEGORY")) ? "selected" : "" %>>イベント</option>
        </select>

        <label>内容</label>
        <textarea name="content" rows="6"><%= notice.get("Content") %></textarea>

        <!-- ★ 更新ボタンのみ -->
        <button type="submit" class="btn">更新する</button>
    </form>

    <a href="teacher_home.jsp" class="btn" style="margin-top:10px;">戻る</a>
</div>

</body>
</html>
