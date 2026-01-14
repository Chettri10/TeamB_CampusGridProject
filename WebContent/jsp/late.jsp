<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>キャンパスグリッド - 遅刻</title>

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
        width: 100%;
        max-width: 380px;
        margin: 0 auto;
        padding-top: 20px;
    }
    h1 {
        font-size: 26px;
        font-weight: bold;
        margin-bottom: 10px;
    }
    h2 {
        font-size: 22px;
        margin-bottom: 15px;
    }
    .qr-btn {
        background-color: #aeeaff;
        padding: 12px 20px;
        border-radius: 12px;
        color: black;
        font-size: 18px;
        width: 80%;
        margin: 0 auto 20px;
        text-decoration: none;
        display: block;
        font-weight: bold;
    }
    label {
        font-size: 18px;
        display: block;
        text-align: left;
        width: 85%;
        margin: 15px auto 8px;
    }
    textarea {
        width: 85%;
        height: 90px;
        border-radius: 12px;
        border: none;
        padding: 10px;
        font-size: 16px;
    }
    .submit-btn {
        width: 85%;
        background-color: #aee0ff;
        color: black;
        border: none;
        padding: 15px;
        margin-top: 25px;
        margin-bottom: 40px;
        border-radius: 12px;
        font-size: 22px;
        font-weight: bold;
        cursor: pointer;
    }
</style>

</head>
<body>

<div class="container">

    <h1>キャンパスグリッド</h1>
    <h2>遅刻</h2>

    <a href="qr.jsp" class="qr-btn">QRコードを表示　＞</a>

    <form action="student_menu.jsp" method="post">

        <label>遅刻した理由は？</label>
        <textarea name="lateReason"></textarea>

        <label>遅刻しないためには？</label>
        <textarea name="latePlan"></textarea>

        <button type="submit" class="submit-btn">送信</button>

    </form>

</div>

</body>
</html>
