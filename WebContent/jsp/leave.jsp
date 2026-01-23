<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>キャンパスグリッド - 早退</title>

<!-- iPhone 15 Plus の論理幅に合わせた viewport -->
<meta name="viewport" content="width=430, initial-scale=1.0">

<style>
    body {
        background-color: #00144a;
        color: white;
        font-family: "Meiryo", sans-serif;
        margin: 0;
        padding: 0;
        text-align: center;
    }
    .container {
        width: 95%;
        max-width: 430px; /* iPhone 15 Plus の論理幅に合わせる */
        margin: 0 auto;
        padding-top: 20px;
    }
    h1 {
        font-size: 1.6em;
        font-weight: bold;
        margin-bottom: 10px;
    }
    h2 {
        font-size: 1.3em;
        margin-bottom: 15px;
    }
    .qr-btn {
        background-color: #00ffff;
        padding: 12px 20px;
        border-radius: 12px;
        color: black;
        font-size: 1em;
        width: 90%;
        margin: 0 auto 20px;
        text-decoration: none;
        display: block;
        font-weight: bold;
    }
    label {
        font-size: 1em;
        display: block;
        text-align: left;
        width: 90%;
        margin: 15px auto 8px;
    }
    textarea {
        width: 90%;
        height: 90px;
        border-radius: 12px;
        border: none;
        padding: 10px;
        font-size: 1em;
        box-sizing: border-box;
    }
    .submit-btn {
        width: 90%;
        background-color: #00ffff;
        color: black;
        border: none;
        padding: 15px;
        margin-top: 25px;
        margin-bottom: 40px;
        border-radius: 12px;
        font-size: 1.2em;
        font-weight: bold;
        cursor: pointer;
    }

    /* スマホ用にさらに調整 */
    @media (max-width: 430px) {
        h1 { font-size: 1.4em; }
        h2 { font-size: 1.2em; }
        .submit-btn { font-size: 1.1em; padding: 12px; }
    }
</style>

</head>
<body>

<div class="container">

    <h1>キャンパスグリッド</h1>
    <h2>早退</h2>

    <a href="qr.jsp" class="qr-btn">QRコードを表示　＞</a>

    <form action="student_menu.jsp" method="post">

        <label>早退した理由は？</label>
        <textarea name="leaveReason"></textarea>

        <label>早退しないためには？</label>
        <textarea name="leavePlan"></textarea>

		<!-- 送信ボタン -->
        <button type="submit" class="submit-btn">送信</button>

    </form>

</div>

</body>
</html>
