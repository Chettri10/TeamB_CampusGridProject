<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>キャンパスグリッド - 投稿完了</title>
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
            padding: 30px 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }

        h2 {
            font-size: 24px;
            margin-bottom: 15px;
            font-weight: 700;
            color: #00E5FF;
        }

        p {
            font-size: 15px;
            margin-bottom: 25px;
            line-height: 1.6;
        }

        .btn {
            display: block;
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            text-align: center;
            margin-top: 10px;
        }

        .btn-list {
            background-color: #00E5FF;
            color: #000;
        }

        .btn-write {
            background-color: #555;
            color: #FFF;
        }
    </style>
</head>

<body>

<div class="card">
    <h2>投稿が完了しました</h2>
    <p>お知らせの投稿が正常に完了しました。</p>

    <!-- ★ 遷移先を notice.jsp に変更 ★ -->
    <a href="notice.jsp" class="btn btn-list">お知らせ一覧へ戻る</a>

    <a href="notice_write.jsp" class="btn btn-write">続けて投稿する</a>
</div>

</body>
</html>
