<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>

<%
    List<Map<String, Object>> cartList = (List<Map<String, Object>>) request.getAttribute("cartList");
    long totalPrice = 0;
    NumberFormat nf = NumberFormat.getCurrencyInstance(Locale.JAPAN);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>購入内容確認</title>
    <style>
        body { font-family: sans-serif; background-color: #0b1a37; color: white; display: flex; flex-direction: column; align-items: center; padding: 20px; }
        .container { width: 90%; max-width: 400px; }
        h1 { text-align: center; font-size: 24px; }
        .content-confirm { background-color: #2e435a; padding: 15px; text-align: center; font-weight: bold; border-radius: 5px; margin-bottom: 20px; }
        .item-box { background-color: #e5f2ff; color: #333; padding: 15px; margin-bottom: 10px; border-radius: 5px; display: flex; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .item-info { flex-grow: 1; }
        .price-text { font-weight: bold; margin-left: 10px; display: block; font-size: 0.9em; color: #666; }
        .total-price { background-color: #2e435a; padding: 10px 15px; margin-top: 10px; border-radius: 5px; text-align: right; font-weight: bold; border: 1px solid #00ffff; }
        /* ボタンのスタイル統一 */
        .payment-button { border: none; padding: 18px; text-align: center; font-size: 18px; font-weight: bold; border-radius: 5px; margin-top: 15px; cursor: pointer; width: 100%; display: block; }
        .btn-pay { background-color: #00ffff; color: black; }
        .btn-continue { background-color: #555; color: white; text-decoration: none; }
        .empty-message { text-align: center; padding: 40px 20px; opacity: 0.7; }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>

<div class="container">
    <h1>キャンパスグリッド 購入</h1>
    <div class="content-confirm">内容確認</div>

    <% if (cartList != null && !cartList.isEmpty()) { %>
        <%-- 商品がある場合 --%>
        <% for (Map<String, Object> item : cartList) {
            String name = (item.get("Product_Name") != null) ? item.get("Product_Name").toString() : "商品";
            int price = (item.get("Price") != null) ? (Integer)item.get("Price") : 0;
            int qty = (item.get("Quantity") != null) ? (Integer)item.get("Quantity") : 0;
            totalPrice += (long)price * qty;
        %>
            <div class="item-box">
                <div class="item-info">
                    <i class="fas fa-shopping-bag"></i>
                    <%= name %>
                    <span class="price-text"><%= nf.format(price) %> (×<%= qty %>)</span>
                </div>
            </div>
        <% } %>

        <div class="total-price">
            合計金額: <%= nf.format(totalPrice) %>
        </div>

        <%-- 1. 支払いボタン --%>
        <form action="${pageContext.request.contextPath}/PaymentServlet" method="POST">
            <button type="submit" class="payment-button btn-pay">
                <i class="fas fa-credit-card"></i> 支払いへ
            </button>
        </form>

        <%-- 2. 買い物を続けるボタン --%>
        <button onclick="location.href='${pageContext.request.contextPath}/jsp/cart.jsp'" class="payment-button btn-continue">
            買い物を続ける
        </button>

    <% } else { %>
        <%-- カートが空の場合 --%>
        <div class="empty-message">カートに商品は入っていません。</div>
        <button onclick="location.href='${pageContext.request.contextPath}/jsp/cart.jsp'" class="payment-button btn-continue">
            買い物を続ける
        </button>
    <% } %>
</div>

</body>
</html>