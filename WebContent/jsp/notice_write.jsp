<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>キャンパスグリッド - お知らせ投稿</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700&display=swap" rel="stylesheet">

    <style>
        body {
            background-color: #030820;
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
        }

        .container {
            width: 100%;
            max-width: 400px;
            padding-bottom: 50px;
        }

        .title-area {
            text-align: center;
            margin-bottom: 30px;
            margin-top: 20px;
        }

        h1 {
            font-size: 24px;
            margin: 0;
            line-height: 1.3;
            letter-spacing: 1px;
        }

        h2 {
            font-size: 24px;
            margin: 5px 0 0 0;
            font-weight: 700;
            color: #00FFFF;
        }

        form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        label {
            font-size: 14px;
            margin-bottom: 4px;
        }

        input[type="text"],
        textarea,
        select {
            width: 100%;
            padding: 10px;
            border-radius: 8px;
            border: none;
            font-size: 14px;
            box-sizing: border-box;
        }

        textarea {
            min-height: 120px;
            resize: vertical;
        }

        .btn-area {
            margin-top: 20px;
            display: flex;
            gap: 10px;
            justify-content: space-between;
        }

        .btn {
            flex: 1;
            padding: 12px;
            border-radius: 8px;
            border: none;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
        }

        .btn-submit {
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

<div class="container">
    <div class="title-area">
        <h1>キャンパスグリッド</h1>
        <h2>お知らせ投稿</h2>
    </div>

    <!-- NoticePostServlet に送信 -->
    <form action="noticePost" method="post">

        <!-- 投稿者ID -->
        <label for="userId">投稿者ID</label>
        <input type="text" id="userId" name="userId" placeholder="例: teacher01" required>

        <!-- カテゴリ -->
        <label for="category">カテゴリ</label>
        <select id="category" name="category">
            <option value="連絡">連絡</option>
            <option value="重要">重要</option>
            <option value="イベント">イベント</option>
        </select>

        <!-- 本文 -->
        <label for="content">お知らせ内容</label>
        <textarea id="content" name="content" placeholder="お知らせ内容を入力してください" required></textarea>

        <div class="btn-area">
            <button type="submit" class="btn btn-submit">投稿する</button>
            <button type="button" class="btn btn-cancel" onclick="history.back()">戻る</button>
        </div>
    </form>
</div>

</body>
</html>
