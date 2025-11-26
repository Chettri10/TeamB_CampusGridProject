<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">

<!-- ▼ スマホ対応 -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>学生 出欠登録 | キャンパスグリッド</title>

<style>
body {
    background-color: #001a4d; /* 濃いネイビーブルー */
    margin: 0;
    padding: 0;
    font-family: "Meiryo", sans-serif;
    color: white;
    text-align: center;
}

.container {
    width: 90%;
    max-width: 420px;
    margin: 0 auto;
    padding-top: 30px;
}

/* ロゴ丸枠 */
.logo-circle {
    width: 140px;
    height: 140px;
    margin: 0 auto;
    border-radius: 50%;
    background: #00235c;
    display: flex;
    align-items: center;
    justify-content: center;
}

.logo-text {
    font-size: 65px;
    font-weight: bold;
    color: #00dfff;
}

/* タイトル */
.main-title {
    font-size: 26px;
    font-weight: bold;
    margin-top: 20px;
}

.sub-title {
    font-size: 18px;
    color: #b8e8ff;
    margin-bottom: 30px;
}

/* ▼ ボタン共通 */
.btn {
    width: 100%;
    padding: 14px 0;
    margin: 12px 0;
    border-radius: 15px;
    font-size: 18px;
    border: none;
    cursor: pointer;
    font-weight: bold;
}

/* QR 表示ボタン（1番上） */
.btn-qr {
    background-color: #9ff6ff;
    color: black;
    display: flex;
    justify-content: center;
    align-items: center;
}

.btn-qr span {
    flex-grow: 1;
}

.btn-qr .arrow {
    font-size: 22px;
    margin-right: 10px;
}

/* 遅刻・早退ボタン */
.btn-normal {
    background-color: #0c2a60;
    color: white;
}

/* スマホ微調整 */
@media (max-width: 480px) {
    .main-title { font-size: 23px; }
    .sub-title { font-size: 16px; }
    .btn { font-size: 17px; padding: 12px 0; }
}
</style>

</head>
<body>

<div class="container">

    <!-- ロゴ部分（仮デザイン） -->
    <div class="logo-circle">
        <div class="logo-text">C</div>
    </div>

    <div class="main-title">キャンパス グリッド</div>
    <div class="sub-title">学生の出欠登録</div>

    <!-- ▼ 出欠登録メニュー -->
    <form action="StudentAttendanceServlet" method="post">

        <!-- QR 表示ボタン -->
        <button type="submit" name="action" value="qr" class="btn btn-qr">
            <span>QR コードを表示</span>
            <span class="arrow">➜</span>
        </button>

        <!-- 遅刻 -->
        <button type="submit" name="action" value="late" class="btn btn-normal">
            遅刻
        </button>

        <!-- 早退 -->
        <button type="submit" name="action" value="early" class="btn btn-normal">
            早退
        </button>

    </form>

</div>

</body>
</html>
