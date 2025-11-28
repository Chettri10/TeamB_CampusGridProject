<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    // --- 1. Beanを使わず、JSP内で直接データ構造を定義 ---
    // [商品名, 価格] の形式でデータを格納します。
    // 画面構成の画像に基づきデータを設定。

    String[][] cartItemsData = {
        {"キャンパスグリッド有料版", "12800"},
        {"カバン", "4500"},
        {"筆箱", "1500"}
    };

    long totalPrice = 0;

    // 合計金額を計算
    for (String[] item : cartItemsData) {
        try {
            totalPrice += Long.parseLong(item[1]); // 価格 (item[1]) を long 型に変換して加算
        } catch (NumberFormatException e) {
            // エラー処理（念のため）
            System.err.println("価格の解析エラー: " + item[1]);
        }
    }

    // 価格表示用のフォーマッタ (日本円、カンマ区切り)
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("ja", "JP"));
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
        /* 内容確認ボタンのスタイル */
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
        /* 個別商品/ボタンの基本スタイル */
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
        }
        /* 支払いボタンのスタイル */
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
            width: 100%; /* 全幅に広げる */
            border: none;
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
    </style>
    <%-- Font Awesomeのショッピングカートアイコンを使用するために外部CSSを参照 --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>

<div class="container">
    <h1>キャンパスグリッド 購入</h1>

    <%-- 1. 内容確認エリア --%>
    <div class="content-confirm">
        内容確認
    </div>

    <%-- 2. カートの商品一覧 --%>
    <% for (String[] item : cartItemsData) { %>
        <div class="item-box">
            <i class="fas fa-shopping-bag"></i>
            <%= item[0] %> <%-- 商品名 (item[0]) --%>
            <span style="margin-left: auto; font-weight: bold;">
                <%= currencyFormatter.format(Long.parseLong(item[1])) %> <%-- 価格 (item[1]) --%>
            </span>
        </div>
    <% } %>

    <%-- 3. 合計金額表示 --%>
    <div class="total-price">
        合計金額: <%= currencyFormatter.format(totalPrice) %>
    </div>

    <%-- 4. 支払いボタン --%>
    <form action="PaymentServlet" method="POST">
        <input type="hidden" name="action" value="processPayment">
        <button type="submit" class="payment-button">
            支払いへ
        </button>
    </form>

</div>

</body>
</html>
