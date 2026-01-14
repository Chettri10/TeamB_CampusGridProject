<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>キャンパスグリッド - 支払い方法</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <style>
        /* --- 1. ベース設定 --- */
        * {
            box-sizing: border-box;
        }

        body {
            background-color: #020617; /* 濃紺 */
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            min-height: 100vh;
        }

        .container {
            width: 100%;
            max-width: 430px; /* スマホサイズ */
            padding: 40px 24px;
            background-color: #020617;
            text-align: center;
        }

        /* --- 2. タイトル --- */
        .page-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 40px;
            color: #FFFFFF;
            letter-spacing: 1px;
        }

        /* --- 3. 支払い方法ボタン --- */
        .payment-btn {
            display: block;
            width: 100%;
            padding: 15px 0;
            margin-bottom: 20px;
            background-color: #00FFFF; /* シアン */
            color: #000000;
            border: none;
            border-radius: 12px;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none; /* リンクの場合用 */
            box-shadow: 0 4px 10px rgba(0, 255, 255, 0.2);
            transition: opacity 0.2s;
        }

        .payment-btn:hover {
            opacity: 0.9;
        }

        /* --- 4. 商品確認カード（白いエリア） --- */
        .product-card {
            background-color: #FFFFFF;
            border-radius: 20px;
            padding: 25px 20px;
            margin-top: 30px;
            color: #000000;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }

        .card-title {
            font-size: 16px;
            font-weight: 700;
            margin: 0 0 20px 0;
            color: #333;
        }

        /* 商品行（アイコン + 名前） */
        .product-row {
            display: flex;
            align-items: center;
            justify-content: center; /* 中央寄せ */
            gap: 15px;
            margin-bottom: 25px;
        }

        /* アイコンの丸い背景 */
        .icon-circle {
            width: 50px;
            height: 50px;
            background-color: #D1D5DB; /* 薄いグレー */
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .bag-icon {
            width: 24px;
            height: 24px;
            stroke: #666;
            stroke-width: 2.5;
            fill: none;
            stroke-linecap: round;
            stroke-linejoin: round;
        }

        .product-name {
            font-size: 20px;
            font-weight: 700;
            color: #000;
        }

        /* カード内のボタン（カートに移動） */
        .cart-btn {
            width: 100%;
            padding: 15px 0;
            background-color: #00FFFF; /* 上のボタンと同じ色 */
            color: #000000;
            border: none;
            border-radius: 12px;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .cart-btn:hover {
            opacity: 0.9;
        }

    </style>
</head>
<body>

    <div class="container">

        <h1 class="page-title">支払い方法</h1>

        <a href="payment_credit.jsp" class="payment-btn">クレジットカード</a>
        <a href="payment_konbini.jsp" class="payment-btn">コンビニ決済</a>

        <div class="product-card">
            <p class="card-title">選択された商品</p>

            <div class="product-row">
                <div class="icon-circle">
                    <svg class="bag-icon" viewBox="0 0 24 24">
                        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <path d="M16 10a4 4 0 0 1-8 0"></path>
                    </svg>
                </div>
                <div class="product-name">カバン</div>
            </div>

            <button class="cart-btn" onclick="location.href='cart2.jsp'">カートに移動</button>
        </div>

    </div>

</body>
</html>