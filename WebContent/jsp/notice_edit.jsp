<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = request.getParameter("id");
    String category = request.getParameter("category");
    String content = request.getParameter("content");
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>キャンパスグリッド - お知らせ編集</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap" rel="stylesheet">

    <style>
        body {
            background-color: #030820;
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .card {
            background-color: #FFFFFF;
            color: #333;
            width: 90%;
            max-width: 380px;
            padding: 25px 20px 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }

        h2 {
            font-size: 22px;
            margin: 0 0 15px;
            font-weight: 700;
            color: #00E5FF;
            text-align: center;
        }

        label {
            font-size: 14px;
            display: block;
            margin-bottom: 4px;
        }

        input[type="text"],
        select,
        textarea {
            width: 100%;
            padding: 8px 10px;
            border-radius: 8px;
            border: 1px solid #CCC;
            font-size: 14px;
            box-sizing: border-box;
            margin-bottom: 12px;
        }

        textarea {
            min-height: 100px;
            resize: vertical;
        }

        .btn-area {
            margin-top: 10px;
            display: flex;
            gap: 10px;
        }

        .btn {
            flex: 1;
            padding: 10px;
            border-radius: 8px;
            border: none;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .btn-update {
            background-color: #00E5FF;
            color: #000;
        }

        .btn-cancel {
            background-color: #555;
            color: #FFF;
        }
    </style>
</head>
<body>

<div class="card">
    <h2>お知らせ編集</h2>

    <form action="noticeEdit" method="post">
        <input type="hidden" name="id" value="<%= id %>">

        <label for="category">カテゴリ</label>
        <select id="category" name="category">
            <option value="連絡" <%= "連絡".equals(category) ? "selected" : "" %>>連絡</option>
            <option value="重要" <%= "重要".equals(category) ? "selected" : "" %>>重要</option>
            <option value="イベント" <%= "イベント".equals(category) ? "selected" : "" %>>イベント</option>
        </select>

        <label for="content">内容</label>
        <textarea id="content" name="content"><%= content %></textarea>

        <div class="btn-area">
            <button type="submit" class="btn btn-update">更新する</button>
            <button type="button" class="btn btn-cancel" onclick="history.back()">戻る</button>
        </div>
    </form>
</div>

</body>
</html>
