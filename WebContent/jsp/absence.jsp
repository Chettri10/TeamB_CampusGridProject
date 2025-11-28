<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">

<!-- ▼ スマホ対応 必須タグ ▼ -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>欠席登録 - CAMPUS GRID</title>

<!-- iPhone 15 Plus の論理幅に合わせた viewport -->
<meta name="viewport" content="width=430, initial-scale=1.0">

<style>
body {
    background-color: #000033;
    color: white;
    font-family: "Meiryo", sans-serif;
    margin: 0;
    padding: 0;
    text-align: center;
}

.container {
    margin: 25px auto;
    width: 90%;
    max-width: 480px;  /* スマホ + タブレット両対応 */
}

.title-main {
    font-size: 26px;
    font-weight: bold;
}

.title-sub {
    font-size: 20px;
    margin-top: 5px;
}

.label {
    margin-top: 25px;
    font-size: 16px;
    text-align: left;
    width: 100%;
}

.textbox {
    width: 100%;
    height: 110px;
    border-radius: 12px;
    border: none;
    margin-top: 10px;
    padding: 10px;
    font-size: 15px;
    box-sizing: border-box;
}

.submit-btn {
    width: 100%;
    height: 50px;
    margin-top: 35px;
    background-color: #a5d4ff;
    color: black;
    font-size: 20px;
    font-weight: bold;
    border-radius: 10px;
    border: none;
    cursor: pointer;
}

.submit-btn:hover {
    opacity: 0.9;
}

/* ▼ スマホ特化の最適化 ▼ */
@media (max-width: 480px) {
    .title-main { font-size: 23px; }
    .title-sub { font-size: 18px; }
    .textbox { height: 100px; font-size: 14px; }
    .submit-btn { height: 48px; font-size: 18px; }
}
</style>

</head>
<body>

<div class="container">

    <div class="title-main">キャンパスグリッド</div>
    <div class="title-sub">欠席</div>

    <form action="AbsenceServlet" method="post">

        <div class="label">欠席した理由は？</div>
        <textarea class="textbox" name="reason"></textarea>

        <div class="label">欠席しないためには？</div>
        <textarea class="textbox" name="solution"></textarea>

        <button type="submit" class="submit-btn">送信</button>

    </form>

</div>

</body>
</html>
