<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    // --- 1. サーブレットから渡されたデータを受け取る ---
    // CartServletのdoGetで "cartList" という名前で保存されたList<Map>を取得します。
    List<Map<String, Object>> cartList = (List<Map<String, Object>>) request.getAttribute("cartList");

    long totalPrice = 0;
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("ja", "JP"));

    // --- 2. 合計金額を動的に計算 ---
    if (cartList != null) {
        for (Map<String, Object> item : cartList) {
            try {
                // TODO: DAOでProductテーブルと結合(JOIN)して"Price"を取得するように修正が必要です。
                // 現時点では、計算ロジックのみ用意しておきます（DBにPriceカラムがある前提）
                Object priceObj = item.get("Price");
                if (priceObj != null) {
                    totalPrice += Long.parseLong(priceObj.toString()) * (Integer)item.get("Quantity");
                }
            } catch (Exception e) {
                System.err.println("価格計算エラー");
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>キャンパスグリッド 購入内容確認</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #0b1a37; /* 背景色 */
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
            margin: 0;
        }
        .container {
            width: 90%;
            max-width: 400px;
        }
        h1 {
            color: white;
            font-size: 24px;
            text-align: center;
            margin-bottom: 30px;
        }
        .content-confirm {
            background-color: #2e435a;
            color: white;
            padding: 15px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .item-box {
            background-color: #e5f2ff;
            color: #333;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 5px;
            display: flex;
            align-items: center;
            font-size: 16px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .item-box i {
            margin-right: 15px;
            font-size: 20px;
            color: #0b1a37;
        }
        .payment-button {
            background-color: #00ffff; /* 明るいシアン */
            color: black;
            padding: 20px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            border-radius: 5px;
            margin-top: 30px;
            cursor: pointer;
            width: 100%;
            border: none;
            transition: opacity 0.2s;
        }
        .payment-button:hover {
            opacity: 0.8;
        }
        .total-price {
            background-color: #2e435a;
            color: white;
            padding: 10px 15px;
            margin-top: 10px;
            border-radius: 5px;
            text-align: right;
            font-weight: bold;
        }
        .empty-message {
            text-align: center;
            padding: 20px;
            opacity: 0.7;
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>

<div class="container">
    <h1>キャンパスグリッド 購入</h1>

    <div class="content-confirm">内容確認</div>

    <%-- --- 3. 商品一覧の動的表示 --- --%>
    <%
        if (cartList != null && !cartList.isEmpty()) {
            for (Map<String, Object> item : cartList) {
                // 商品名が取得できていない場合はIDを表示
                String productName = (item.get("Product_Name") != null) ?
                                     item.get("Product_Name").toString() :
                                     "商品ID: " + item.get("Product_ID");

                // 価格が取得できていない場合は0を表示
                long price = (item.get("Price") != null) ?
                             Long.parseLong(item.get("Price").toString()) : 0;
    %>
        <div class="item-box">
            <i class="fas fa-shopping-bag"></i>
            <%= productName %>
            <span style="margin-left: auto; font-weight: bold;">
                <%= currencyFormatter.format(price) %>
            </span>
        </div>
    <%
            }
        } else {
    %>
        <div class="empty-message">カートに商品は入っていません。</div>
    <% } %>

    <%-- --- 4. 合計金額の表示 --- --%>
    <div class="total-price">
        合計金額: <%= currencyFormatter.format(totalPrice) %>
    </div>

    <%-- --- 5. 支払いボタン --- --%>
    <form action="PaymentServlet" method="POST">
        <input type="hidden" name="action" value="processPayment">
        <button type="submit" class="payment-button">
            支払いへ
        </button>
    </form>
</div>

</body>
</html>