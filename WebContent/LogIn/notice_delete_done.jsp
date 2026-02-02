<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>削除完了</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&display=swap" rel="stylesheet">

<style>
    /* 全体の設定（前回と共通） */
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

    /* カードデザイン（前回と共通） */
    .container {
        background: #fff;
        width: 100%;
        max-width: 400px;
        padding: 40px 30px;
        border-radius: 16px;
        text-align: center;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
        animation: fadeIn 0.6s ease-out;
    }

    /* --- 削除固有のスタイル --- */

    /* アイコンの背景円 */
    .delete-icon-wrapper {
        width: 70px;
        height: 70px;
        background: #FFECEC; /* 薄い赤背景 */
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 25px;
    }

    /* CSSでゴミ箱を描画 */
    .delete-trash-bin {
        position: relative;
        width: 22px;
        height: 28px;
        background: #FF5252; /* 削除カラー（赤） */
        border-radius: 0 0 4px 4px;
    }
    /* ゴミ箱の蓋 */
    .delete-trash-bin::before {
        content: '';
        position: absolute;
        top: -5px;
        left: -3px;
        width: 28px;
        height: 4px;
        background: #FF5252;
        border-radius: 2px;
    }
    /* ゴミ箱の取っ手 */
    .delete-trash-bin::after {
        content: '';
        position: absolute;
        top: -9px;
        left: 7px;
        width: 8px;
        height: 4px;
        background: #FF5252;
        border-radius: 2px 2px 0 0;
    }
    /* ゴミ箱の中の線（装飾） */
    .trash-lines {
        position: absolute;
        top: 5px;
        left: 5px;
        width: 4px;
        height: 18px;
        background: rgba(255, 255, 255, 0.6);
        border-radius: 2px;
    }
    .trash-lines::after {
        content: '';
        position: absolute;
        left: 8px;
        width: 4px;
        height: 18px;
        background: rgba(255, 255, 255, 0.6);
        border-radius: 2px;
    }

    /* 見出し */
    h2 {
        color: #FF5252; /* 赤色を強調 */
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

    /* --- ボタン（前回と共通） --- */
    .btn {
        display: block;
        width: 100%;
        padding: 14px 0;
        background: #00E5FF; /* 一覧に戻るアクションは青色で肯定的に */
        color: #030820;
        border-radius: 50px;
        text-decoration: none;
        font-weight: 700;
        font-size: 16px;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(0, 229, 255, 0.3);
        box-sizing: border-box;
    }

    .btn:hover {
        background: #00cce6;
        transform: translateY(-2px);
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
    <div class="delete-icon-wrapper">
        <div class="delete-trash-bin">
            <div class="trash-lines"></div>
        </div>
    </div>

    <h2>削除が完了しました</h2>
    <p>お知らせは正常に削除されました。<br>この操作は取り消せません。</p>

    <a href="teacher_home.jsp" class="btn">お知らせ一覧へ戻る</a>
</div>

</body>
</html>