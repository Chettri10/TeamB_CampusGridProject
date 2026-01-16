<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>

<%
    // サーブレットから渡されたカートリストを取得
    List<Map<String, Object>> cartList = (List<Map<String, Object>>) request.getAttribute("cartList");
    long totalPrice = 0;
    NumberFormat nf = NumberFormat.getCurrencyInstance(Locale.JAPAN);
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>購入内容確認 - キャンパスグリッド</title>
    <style>
        body { font-family: 'Noto Sans JP', sans-serif; background-color: #0b1a37; color: white; display: flex; flex-direction: column; align-items: center; padding: 20px; margin: 0; }
        .container { width: 90%; max-width: 400px; position: relative; padding-top: 40px; }

        .back-link { position: absolute; top: 0; left: 0; color: #00ffff; text-decoration: none; font-size: 16px; display: flex; align-items: center; gap: 5px; opacity: 0.8; }
        .back-link:hover { opacity: 1; }

        h1 { text-align: center; font-size: 24px; margin-top: 10px; letter-spacing: 1px; }
        .content-confirm { background-color: #2e435a; padding: 15px; text-align: center; font-weight: bold; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(255,255,255,0.1); }

        /* 商品アイテムのレイアウト */
        .item-box { background-color: #e5f2ff; color: #333; padding: 15px; margin-bottom: 12px; border-radius: 12px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 4px 6px rgba(0,0,0,0.2); }
        .item-info { flex-grow: 1; display: flex; flex-direction: column; }
        .item-name-row { display: flex; align-items: center; font-weight: bold; font-size: 16px; }
        .item-icon { margin-right: 10px; color: #0b1a37; }
        .price-text { margin-left: 26px; font-weight: bold; font-size: 14px; color: #555; margin-top: 4px; }

        /* 削除ボタン */
        .delete-btn { background: none; border: none; color: #ff4d4d; cursor: pointer; font-size: 18px; padding: 8px; transition: transform 0.1s, color 0.2s; }
        .delete-btn:hover { transform: scale(1.2); color: #ff0000; }

        .total-price { background-color: #2e435a; padding: 15px; margin-top: 10px; border-radius: 8px; text-align: right; font-weight: bold; border: 1px solid #00ffff; font-size: 18px; }

        .payment-button { border: none; padding: 18px; text-align: center; font-size: 18px; font-weight: bold; border-radius: 12px; margin-top: 15px; cursor: pointer; width: 100%; display: flex; justify-content: center; align-items: center; gap: 10px; transition: opacity 0.2s; }
        .btn-pay { background-color: #00ffff; color: black; box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3); }
        .btn-continue { background-color: #334155; color: white; text-decoration: none; border: 1px solid rgba(255,255,255,0.2); }
        .payment-button:active { opacity: 0.8; transform: scale(0.98); }

        .empty-message { text-align: center; padding: 60px 20px; opacity: 0.7; font-size: 16px; }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>

<div class="container">


    <h1>キャンパスグリッド 購入</h1>
    <div class="content-confirm">内容確認</div>

    <% if (cartList != null && !cartList.isEmpty()) { %>
        <% for (Map<String, Object> item : cartList) {
            // CartDetailDao.java の toMap メソッド内のキー名に厳密に合わせる
            String name = (item.get("Product_Name") != null) ? item.get("Product_Name").toString() : "不明な商品";
            int price = (item.get("Price") != null) ? (Integer)item.get("Price") : 0;
            int qty = (item.get("Quantity") != null) ? (Integer)item.get("Quantity") : 0;

            // 削除キー：CartDetailDaoのキー名「Cart_details_ID」を使用
            Object detailId = item.get("Cart_details_ID");
            totalPrice += (long)price * qty;
        %>
            <div class="item-box">
                <div class="item-info">
                    <div class="item-name-row">
                        <i class="fas fa-shopping-bag item-icon"></i>
                        <%= name %>
                    </div>
                    <span class="price-text">¥<%= price %> (×<%= qty %>)</span>
                </div>

                <%-- 削除ボタン：CartServletの doPost 内の action=delete 分岐へ送る --%>
                <form action="${pageContext.request.contextPath}/CartServlet" method="POST" style="margin: 0;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="detailId" value="<%= detailId %>">
                    <button type="submit" class="delete-btn" title="削除">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </form>
            </div>
        <% } %>

        <div class="total-price">
            合計金額: ¥<%= totalPrice %>
        </div>

        <form action="${pageContext.request.contextPath}/PaymentServlet" method="POST">
            <button type="submit" class="payment-button btn-pay">
                <i class="fas fa-credit-card"></i> 支払いへ
            </button>
        </form>

        <button onclick="location.href='${pageContext.request.contextPath}/jsp/cart.jsp'" class="payment-button btn-continue">
            買い物を続ける
        </button>

    <% } else { %>
        <div class="empty-message">
            <i class="fas fa-shopping-cart" style="font-size: 48px; margin-bottom: 20px; display: block;"></i>
            カートに商品は入っていません。
        </div>
        <button onclick="location.href='${pageContext.request.contextPath}/jsp/cart.jsp'" class="payment-button btn-continue">
            商品一覧へ戻る
        </button>
    <% } %>
</div>

</body>
</html>