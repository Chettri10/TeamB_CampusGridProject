<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>キャンパスグリッド - 出欠席登録</title>

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
        padding-top: 30px;
    }

    .logo-area img {
        width: 160px;
        margin-bottom: 15px;
    }

    h1 {
        font-size: 26px;
        margin: 10px 0;
        font-weight: bold;
    }

    h2 {
        font-size: 20px;
        margin-bottom: 25px;
        color: #00ffff;
    }

    /* ボタン共通 */
    .btn {
        width: 80%;
        margin: 0 auto 18px;
        padding: 15px;
        border-radius: 12px;
        font-size: 18px;
        font-weight: bold;
        display: block;
        text-decoration: none;
        color: white;
    }

    /* 個別色 */
    .btn-blue {
        background-color: #00ffff;
        color: black;
    }
    .btn-dark {
        background-color: #0b3b7a;
    }
</style>

</head>
<body>

<div class="container">

    <!-- ロゴ（必要なら画像差し替え） -->
    <div class="logo-area">
        <!-- 差し替え用： <img src="images/logo.png"> -->
        <img src="https://dummyimage.com/200x200/1a2a57/00eaff&text=C" alt="logo">
    </div>

    <h1>キャンパス グリッド</h1>
    <h2>学生の出欠登録</h2>

    <!-- QRコード表示 -->
    <a href="qr.jsp" class="btn btn-blue">QRコードを表示　＞</a>

    <!-- 遅刻ボタン -->
    <a href="late.jsp" class="btn btn-dark">遅刻</a>

    <!-- 早退ボタン -->
    <a href="leave.jsp" class="btn btn-dark">早退</a>


</div>

</body>
</html>
