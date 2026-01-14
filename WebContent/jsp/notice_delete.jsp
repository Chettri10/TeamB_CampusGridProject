<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = request.getParameter("id");
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>キャンパスグリッド - お知らせ削除</title>
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
            text-align: center;
        }

        h2 {
            font-size: 22px;
            margin: 0 0 15px;
            font-weight: 700;
            color: #FF5252;
        }

        p {
            font-size: 14px;
            margin-bottom: 20px;
            line-height: 1.6;
        }

        .btn-area {
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

        .btn-delete {
            background-color: #FF5252;
            color: #FFF;
        }

        .btn-cancel {
            background-color: #555;
            color: #FFF;
        }
    </style>
</head>
<body>

<div class="card">
    <h2>削除確認</h2>
    <p>このお知らせを本当に削除しますか？<br>ID：<%= id %></p>

    <form action="noticeDelete" method="post">
        <input type="hidden" name="id" value="<%= id %>">
        <div class="btn-area">
            <button type="submit" class="btn btn-delete">削除する</button>
            <button type="button" class="btn btn-cancel" onclick="history.back()">戻る</button>
        </div>
    </form>
</div>

</body>
</html>
