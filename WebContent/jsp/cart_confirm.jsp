<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>

<%
    // サーブレットからデータを受け取る
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
        .payment-button { background-color: #00ffff; color: black; padding: 20px; text-align: center; font-size: 20px; font-weight: bold; border-radius: 5px; margin-top: 30px; cursor: pointer; width: 100%; border: none; }
        .empty-message { text-align: center; padding: 40px 20px; opacity: 0.7; }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>

<div class="container">
    <h1>キャンパスグリッド 購入</h1>
    <div class="content-confirm">内容確認</div>

    <% if (cartList != null && !cartList.isEmpty()) { %>
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
                <%-- 削除ボタン(delete-btn)は作成しないため、削除しました --%>
            </div>
        <% } %>

        <div class="total-price">
            合計金額: <%= nf.format(totalPrice) %>
        </div>

        <%-- 支払いへ（PaymentServletへ） --%>
        <form action="${pageContext.request.contextPath}/PaymentServlet" method="POST">
            <button type="submit" class="payment-button">支払いへ</button>
        </form>

    <% } else { %>
        <div class="empty-message">カートに商品は入っていません。</div>
        <%-- 同じフォルダ内の cart.jsp へ戻るリンク --%>
        <button onclick="location.href='${pageContext.request.contextPath}/jsp/cart.jsp'" class="payment-button" style="background-color: #555; color: white;">
    買い物を続ける
</button>
    <% } %>
</div>

</body>
</html>