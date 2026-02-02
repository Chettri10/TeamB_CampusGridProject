<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>編集完了</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&display=swap" rel="stylesheet">

<style>
    /* 全体の設定 */
    body {
        background-color: #030820; /* 深い紺色 */
        color: #333;
        font-family: 'Noto Sans JP', sans-serif;
        margin: 0;
        padding: 20px;
        min-height: 100vh;
        display: flex;
        align-items: center; /* 垂直方向中央揃え */
        justify-content: center; /* 水平方向中央揃え */
        box-sizing: border-box;
    }

    /* カードデザイン */
    .container {
        background: #fff;
        width: 100%;
        max-width: 400px;
        padding: 40px 30px;
        border-radius: 16px; /* 角丸を少し大きく */
        text-align: center;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5); /* 影をつけて浮き上がらせる */
        animation: fadeIn 0.6s ease-out; /* ふわっと表示 */
    }

    /* 成功アイコン（CSSのみで描画） */
    .success-icon {
        width: 60px;
        height: 60px;
        background: #E0FCFF; /* 薄いシアン背景 */
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 20px;
    }
    .success-icon::after {
        content: '';
        display: block;
        width: 18px;
        height: 9px;
        border-left: 3px solid #00E5FF; /* アクセントカラー */
        border-bottom: 3px solid #00E5FF;
        transform: rotate(-45deg) translate(2px, -2px);
    }

    /* 見出し */
    h2 {
        color: #030820;
        font-size: 24px;
        margin: 0 0 10px 0;
        font-weight: 700;
    }

    /* 本文 */
    p {
        color: #666;
        font-size: 15px;
        line-height: 1.6;
        margin: 0 0 30px 0;
    }

    /* ボタン */
    .btn {
        display: block;
        width: 100%;
        padding: 14px 0;
        background: #00E5FF;
        color: #030820;
        border-radius: 50px; /* 丸みのあるボタン */
        text-decoration: none;
        font-weight: 700;
        font-size: 16px;
        transition: all 0.3s ease; /* アニメーション設定 */
        box-shadow: 0 4px 15px rgba(0, 229, 255, 0.3); /* ボタン自体も光らせる */
        box-sizing: border-box;
    }

    /* ボタンのホバー時（マウスを乗せた時） */
    .btn:hover {
        background: #00cce6;
        transform: translateY(-2px); /* 少し上に動く */
        box-shadow: 0 6px 20px rgba(0, 229, 255, 0.5);
    }

    /* アニメーション定義 */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>
</head>

<body>

<div class="container">
    <div class="success-icon"></div>

    <h2>編集が完了しました</h2>
    <p>お知らせの内容が正常に更新されました。<br>一覧画面より内容をご確認ください。</p>

    <a href="teacher_home.jsp" class="btn">お知らせ一覧へ戻る</a>
</div>

</body>
</html>