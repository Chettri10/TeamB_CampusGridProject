<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String[][] products = {
        {"1", "教科書・参考書"},
        {"2", "文房具セット"},
        {"3", "学校指定ジャージ"},
        {"4", "キャンパスバッグ"}
    };
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>キャンパスグリッド - 購入</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body { background-color: #020617; color: #FFFFFF; font-family: 'Noto Sans JP', sans-serif; margin: 0; padding: 0; display: flex; justify-content: center; min-height: 100vh; }
        .container { width: 100%; max-width: 430px; padding: 20px 24px 120px 24px; position: relative; }
        .header { text-align: center; margin-bottom: 32px; }
        .text-cyan { color: #00FFFF; }
        .page-title { font-size: 30px; font-weight: 700; margin: 0; letter-spacing: 2px; }
        .search-container { position: relative; margin-bottom: 24px; }
        .search-input { width: 100%; height: 50px; padding: 0 15px 0 50px; background-color: #E8F5F6; border: none; border-radius: 12px; font-size: 16px; font-weight: bold; color: #333; }
        .search-icon { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); }
        .product-list { display: flex; flex-direction: column; gap: 24px; }
        .add-btn { background: none; border: none; cursor: pointer; padding: 0; display: flex; align-items: center; width: 100%; color: inherit; transition: transform 0.1s; }
        .add-btn:active { transform: scale(0.97); }
        .icon-box { width: 64px; height: 64px; background-color: #E8F5F6; border-radius: 16px; display: flex; justify-content: center; align-items: center; }
        .bag-icon { width: 32px; height: 32px; stroke: #020617; stroke-width: 2.5; fill: none; }
        .product-name { font-size: 18px; font-weight: 700; margin-left: 20px; }
        .cart-btn-area { position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%); width: 100%; max-width: 430px; padding: 0 24px; }
        .cart-btn { width: 100%; height: 56px; background-color: #00FFFF; color: #000000; border: none; border-radius: 14px; font-size: 20px; font-weight: 700; cursor: pointer; box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3); }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>キャンパス <span class="text-cyan">グリッド</span></div>
            <h1 class="page-title">購入</h1>
        </div>
        <div class="search-container">
            <span class="search-icon">🔍</span>
            <input type="text" class="search-input" placeholder="検索">
        </div>
        <div class="product-list">
            <% for (String[] p : products) { %>
            <div class="product-item">
                <form action="<%= request.getContextPath() %>/CartServlet" method="POST">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="productId" value="<%= p[0] %>">
                    <button type="submit" class="add-btn">
                        <div class="icon-box">
                            <svg class="bag-icon" viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                        </div>
                        <div class="product-name"><%= p[1] %></div>
                    </button>
                </form>
            </div>
            <% } %>
        </div>
        <div class="cart-btn-area">
            <button type="button" class="cart-btn" onclick="location.href='<%= request.getContextPath() %>/CartServlet'">カートを見る</button>
        </div>
    </div>
</body>
</html>