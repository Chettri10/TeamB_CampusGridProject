<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // session から優先的に取得（データ消失防止）
    Integer price = (Integer) session.getAttribute("price");
    List<Map<String, Object>> cartList = (List<Map<String, Object>>) session.getAttribute("cartList");

    // バックアップ（Servletからの初回遷移時用）
    if (price == null) price = (Integer) request.getAttribute("price");
    if (cartList == null) cartList = (List<Map<String, Object>>) request.getAttribute("cartList");

    // デフォルト値の設定
    if (price == null) price = 0;
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お支払い方法の選択 - キャンパスグリッド</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { font-family: 'Noto Sans JP', sans-serif; background-color: #0b1a37; color: white; display: flex; flex-direction: column; align-items: center; min-height: 100vh; margin: 0; padding: 20px; }
        .payment-container { background-color: #162a4d; padding: 30px; border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); width: 90%; max-width: 400px; text-align: center; position: relative; padding-top: 60px; }
        .back-btn { position: absolute; top: 20px; left: 20px; color: #00ffff; text-decoration: none; font-size: 15px; display: flex; align-items: center; gap: 8px; opacity: 0.8; transition: 0.2s; }
        .back-btn:hover { opacity: 1; transform: translateX(-3px); }
        .cart-detail-area { width: 100%; background-color: rgba(255,255,255,0.05); border-radius: 10px; padding: 15px; margin-bottom: 20px; box-sizing: border-box; }
        .cart-detail-title { font-size: 12px; opacity: 0.6; margin-bottom: 10px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 5px; }
        .cart-item { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px; }
        .order-summary { background-color: rgba(0, 255, 255, 0.1); padding: 15px; border-radius: 10px; margin-bottom: 30px; text-align: center; border: 1px solid #00ffff; }
        .price-total { font-size: 30px; color: #00ffff; font-weight: bold; }
        .method-option { background-color: #2e435a; margin: 12px 0; padding: 18px; border-radius: 12px; cursor: pointer; transition: 0.2s; border: 2px solid transparent; display: flex; align-items: center; text-align: left; }
        .method-option:hover { background-color: #3d5a7a; }
        input[type="radio"] { display: none; }
        input[type="radio"]:checked + .method-option { border-color: #00ffff; background-color: #3d5a7a; box-shadow: 0 0 10px rgba(0, 255, 255, 0.3); }
        .method-icon { font-size: 22px; margin-right: 15px; color: #00ffff; width: 30px; text-align: center; }
        .method-title { font-weight: bold; display: block; }
        .method-desc { font-size: 11px; opacity: 0.7; display: block; }
        #submit-area { display: none; margin-top: 30px; animation: fadeInUp 0.4s ease forwards; }
        .complete-btn { background-color: #00ffff; color: #0b1a37; border: none; padding: 18px; border-radius: 12px; width: 100%; font-size: 18px; font-weight: bold; cursor: pointer; box-shadow: 0 4px 15px rgba(0, 255, 255, 0.4); transition: 0.2s; }
        .complete-btn:hover { background-color: #5effff; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

<div class="payment-container">
    <a href="${pageContext.request.contextPath}/CartServlet" class="back-btn">
        <i class="fas fa-arrow-left"></i> 戻る
    </a>

    <h2 style="margin-top:0; font-size: 18px; margin-bottom: 20px;">ご注文の最終確認</h2>

    <div class="cart-detail-area">
        <div class="cart-detail-title">商品内訳</div>
        <% if (cartList != null && !cartList.isEmpty()) {
            for (Map<String, Object> item : cartList) { %>
            <div class="cart-item">
                <span><%= item.get("Product_Name") %></span>
                <span>¥<%= String.format("%,d", item.get("Price")) %> x<%= item.get("Quantity") %></span>
            </div>
        <% } } else { %>
            <div style="font-size: 12px; opacity: 0.5;">内訳が読み込めませんでした</div>
        <% } %>
    </div>

    <div class="order-summary">
        <div style="font-size: 13px; opacity: 0.9; margin-bottom: 5px;">最終お支払い合計</div>
        <div class="price-total">¥<%= String.format("%,d", price) %></div>
    </div>

    <p style="text-align: left; font-size: 14px; margin-bottom: 10px; opacity: 0.7; padding-left: 5px;">支払い方法を選択</p>

    <%-- 修正：actionは空にしておき、JavaScriptでServletのパスをセットします --%>
    <form id="payment-form" action="" method="POST">
        <label>
            <%-- 引数を整理：JSPではなく、ボタンに表示するテキストだけを渡します --%>
            <input type="radio" name="method" value="credit" onclick="showCompleteBtn('注文を確定する')">
            <div class="method-option">
                <i class="fas fa-credit-card method-icon"></i>
                <div>
                    <span class="method-title">クレジットカード</span>
                    <span class="method-desc">VISA, Mastercard, JCB</span>
                </div>
            </div>
        </label>

        <label>
            <input type="radio" name="method" value="cvs" onclick="showCompleteBtn('注文を確定する')">
            <div class="method-option">
                <i class="fas fa-store method-icon"></i>
                <div>
                    <span class="method-title">コンビニ支払い</span>
                    <span class="method-desc">手数料 ¥200 加算</span>
                </div>
            </div>
        </label>

        <div id="submit-area">
            <button type="submit" class="complete-btn" id="btn-text">注文を確定する</button>
        </div>
    </form>
</div>

<script>
    function showCompleteBtn(text) {
        const area = document.getElementById('submit-area');
        const form = document.getElementById('payment-form');
        const btnText = document.getElementById('btn-text');

        area.style.display = 'block';

        // 【最重要修正】
        // 直接JSPに飛ばすとDBが消えないため、CartServletのaction=clearCartを呼び出すように設定
        form.action = "${pageContext.request.contextPath}/CartServlet?action=clearCart";

        btnText.innerText = text;
    }
</script>
</body>
</html>