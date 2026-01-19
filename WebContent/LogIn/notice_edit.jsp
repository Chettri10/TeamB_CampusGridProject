<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String date = request.getParameter("date");
    String category = request.getParameter("category");
    String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お知らせ編集</title>
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
        .btn-update { background: #00E5FF; color: #000; }
        .btn-cancel { background: #555; color: #FFF; }
    </style>
</head>

<body>
<div class="card">
    <h2>お知らせ編集</h2>

    <form action="NoticeEditServlet" method="post">
        <input type="hidden" name="id" value="<%= date %>">

        <label>カテゴリ</label>
        <select name="category">
            <option value="重要" <%= "重要".equals(category) ? "selected" : "" %>>重要</option>
            <option value="連絡" <%= "連絡".equals(category) ? "selected" : "" %>>連絡</option>
            <option value="イベント" <%= "イベント".equals(category) ? "selected" : "" %>>イベント</option>
        </select>

        <label>内容</label>
        <textarea name="content"><%= message %></textarea>

        <div class="btn-area">
            <button type="submit" class="btn btn-update">更新する</button>
            <a href="notice.jsp" class="btn btn-cancel">戻る</a>
        </div>
    </form>
</div>
</body>
</html>
