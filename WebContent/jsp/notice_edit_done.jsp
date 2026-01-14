<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>キャンパスグリッド - 変更完了</title>
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
            padding: 30px 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }

        h2 {
            font-size: 22px;
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
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            background-color: #00E5FF;
            color: #000;
        }
    </style>
</head>

<body>

<div class="card">
    <h2>変更が完了しました</h2>
    <p>お知らせの内容が正常に更新されました。</p>

    <a href="notice.jsp" class="btn">お知らせ一覧へ戻る</a>
</div>

</body>
</html>
