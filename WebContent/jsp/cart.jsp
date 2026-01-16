<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>キャンパスグリッド - 購入</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { background-color: #020617; color: #FFFFFF; font-family: 'Noto Sans JP', sans-serif; margin: 0; padding: 0; display: flex; justify-content: center; min-height: 100vh; }
        .container { width: 100%; max-width: 430px; padding: 20px 24px 120px 24px; position: relative; }

        /* 戻るボタン */
        .back-nav { position: absolute; top: 20px; left: 15px; z-index: 10; }
        .back-link { color: #00FFFF; text-decoration: none; font-size: 16px; font-weight: bold; display: flex; align-items: center; gap: 4px; }
        .back-link:hover { opacity: 0.8; }

        .header { text-align: center; margin-bottom: 32px; padding-top: 10px; }
        .text-cyan { color: #00FFFF; }
        .page-title { font-size: 30px; font-weight: 700; margin: 0; }

        .search-container { position: relative; margin-bottom: 24px; }
        .search-input { width: 100%; height: 50px; padding: 0 15px 0 50px; background-color: #E8F5F6; border: none; border-radius: 12px; font-size: 16px; font-weight: bold; color: #333; }
        .search-icon { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: #666; }

        /* 商品リストとカード */
        .product-list { display: flex; flex-direction: column; gap: 16px; }
        .product-item {
            background-color: #0f172a;
            border-radius: 16px;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        /* 左側：商品情報（アイコン・名前・価格） */
        .product-info-group { display: flex; align-items: center; gap: 12px; }
        .icon-box { width: 56px; height: 56px; background-color: #E8F5F6; border-radius: 12px; display: flex; justify-content: center; align-items: center; flex-shrink: 0; }
        .bag-icon { width: 28px; height: 28px; stroke: #020617; stroke-width: 2.5; fill: none; }
        .product-name { font-size: 16px; font-weight: 700; display: block; }
        .product-price { font-size: 14px; color: #00FFFF; font-weight: bold; }

        /* 右側：個数入力と追加ボタンの横並び */
        .action-group { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .qty-input {
            width: 48px; height: 40px;
            background-color: #1e293b;
            border: 1px solid #334155;
            border-radius: 8px;
            color: white;
            text-align: center;
            font-size: 16px;
            font-weight: bold;
        }
        .add-btn {
            background-color: #00FFFF;
            color: #020617;
            border: none;
            border-radius: 8px;
            padding: 0 16px;
            height: 40px;
            font-weight: 700;
            cursor: pointer;
        }

        /* フッターのカートを見るボタン */
        .cart-btn-area { position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%); width: 100%; max-width: 430px; padding: 0 24px; }
        .cart-btn { width: 100%; height: 56px; background-color: #00FFFF; color: #000000; border: none; border-radius: 14px; font-size: 18px; font-weight: 700; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <nav class="back-nav">
            <a href="${pageContext.request.contextPath}/jsp/top.jsp" class="back-link">
                <i class="fas fa-chevron-left"></i> 戻る
            </a>
        </nav>

        <div class="header">
            <div>キャンパス <span class="text-cyan">グリッド</span></div>
            <h1 class="page-title">購入</h1>
        </div>

        <div class="search-container">
            <i class="fas fa-search search-icon"></i>
            <input type="text" class="search-input" placeholder="検索">
        </div>

        <div class="product-list">
            <%
                String url = "jdbc:h2:tcp://localhost/~/CampusGridProject";
                String user = "sa";
                String password = "";

                try {
                    Class.forName("org.h2.Driver");
                    try (Connection conn = DriverManager.getConnection(url, user, password);
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT PRODUCT_ID, PRODUCT_NAME, PRICE FROM PRODUCT")) {

                        while (rs.next()) {
                            String id = rs.getString("PRODUCT_ID");
                            String name = rs.getString("PRODUCT_NAME");
                            int price = rs.getInt("PRICE");
            %>
            <div class="product-item">
                <div class="product-info-group">
                    <div class="icon-box">
                        <svg class="bag-icon" viewBox="0 0 24 24"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                    </div>
                    <div class="product-text">
                        <span class="product-name"><%= name %></span>
                        <span class="product-price">¥<%= price %></span>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/CartServlet" method="POST" class="action-group">
                    <input type="hidden" name="productId" value="<%= id %>">
                    <input type="number" name="quantity" value="1" min="1" class="qty-input">
                    <button type="submit" class="add-btn">追加</button>
                </form>
            </div>
            <%
                        }
                    }
                } catch (Exception e) {
                    out.println("<p style='color:red;'>エラー: " + e.getMessage() + "</p>");
                }
            %>
        </div>

        <div class="cart-btn-area">
            <button type="button" class="cart-btn" onclick="location.href='${pageContext.request.contextPath}/CartServlet'">
                カートを見る
            </button>
        </div>
    </div>
</body>
</html>