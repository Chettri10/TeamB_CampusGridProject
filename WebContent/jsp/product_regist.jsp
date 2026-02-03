<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理パネル - Campus Grid</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Noto Sans JP', sans-serif;
            background-color: #020617;
            color: #FFFFFF;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* --- iPad向けレイアウト設定 --- */
        .main-layout {
            display: flex;
            gap: 20px;
            width: 100%;
            max-width: 1200px; /* iPad横向きなど広い画面に対応 */
            margin: 0 auto;
            flex-wrap: wrap; /* 画面幅が狭い時は縦並びに */
        }

        .product-section { flex: 2; min-width: 400px; } /* 商品管理は少し広く */
        .category-section { flex: 1.2; min-width: 300px; }

        /* ガラス風カードデザイン */
        .glass-card {
            background: #0f172a;
            padding: 24px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            border: 1px solid rgba(255,255,255,0.1);
            margin-bottom: 20px;
        }

        .product-card { border-top: 4px solid #00FFFF; }
        .category-card { border-top: 4px solid #ff9800; }

        h2 { font-size: 20px; margin-top: 0; display: flex; align-items: center; gap: 10px; margin-bottom: 20px; }
        .text-cyan { color: #00FFFF; }
        .text-orange { color: #ff9800; }

        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; font-size: 13px; color: #94a3b8; padding: 10px; border-bottom: 1px solid #1e293b; white-space: nowrap; }
        td { padding: 12px 10px; border-bottom: 1px solid #1e293b; vertical-align: middle; }

        /* 入力フォームデザイン */
        input {
            background: #1e293b;
            border: 1px solid #334155;
            color: white;
            padding: 10px;
            border-radius: 8px;
            width: 100%;
            font-size: 15px; /* タッチしやすいサイズ */
        }
        input:focus { border-color: #00FFFF; outline: none; background: #26334d; }

        input[readonly] {
            background-color: #0f172a;
            color: #64748b;
            border-color: transparent;
            cursor: default;
            text-align: center;
        }

        /* アクションボタン */
        .action-btns { display: flex; gap: 8px; justify-content: flex-end; }
        .btn {
            border: none; border-radius: 8px; padding: 0;
            width: 36px; height: 36px; /* タップしやすい正方形 */
            cursor: pointer;
            transition: 0.2s; display: flex; align-items: center; justify-content: center;
            font-size: 16px;
        }
        .btn-update { background-color: rgba(0, 255, 255, 0.1); color: #00FFFF; border: 1px solid rgba(0, 255, 255, 0.3); }
        .btn-update:active { background-color: #00FFFF; color: #000; }

        .category-card .btn-update { color: #ff9800; border-color: rgba(255, 152, 0, 0.3); background-color: rgba(255, 152, 0, 0.1); }
        .category-card .btn-update:active { background-color: #ff9800; color: #000; }

        .btn-delete { background-color: rgba(255, 68, 68, 0.1); color: #ff4444; border: 1px solid rgba(255, 68, 68, 0.3); }
        .btn-delete:active { background-color: #ff4444; color: #fff; }

        /* フッターナビゲーションのスタイル */
        .footer-nav {
            display: flex;
            justify-content: flex-start;
            align-items: center;
            gap: 15px;
            max-width: 1200px;
            margin: 20px auto 40px;
            width: 100%;
            padding: 0 10px;
            flex-wrap: wrap;
        }

        .nav-link {
            text-decoration: none;
            padding: 12px 20px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: 0.2s;
            flex-grow: 1; /* ボタンを均等に伸ばす */
            justify-content: center;
            max-width: 250px;
        }

        .link-home { color: #94a3b8; border: 1px solid #334155; }
        .link-home:active { background: #334155; color: #fff; }

        .link-add-product { color: #00FFFF; border: 1px solid #00FFFF; background: rgba(0, 255, 255, 0.05); }
        .link-add-product:active { background: #00FFFF; color: #000; }

        .link-add-category { color: #ff9800; border: 1px solid #ff9800; background: rgba(255, 152, 0, 0.05); }
        .link-add-category:active { background: #ff9800; color: #000; }

        .error-msg { color: #ff4444; font-size: 12px; padding: 10px; background: rgba(255,68,68,0.1); border-radius: 5px; text-align: center; }

        /* 縦向きiPad用調整 */
        @media (max-width: 768px) {
            .main-layout { flex-direction: column; }
            .product-section, .category-section { min-width: 100%; }
            .footer-nav { justify-content: center; }
        }
    </style>
</head>
<body>

    <div class="main-layout">
        <section class="product-section">
            <div class="glass-card product-card">
                <h2><i class="fas fa-box text-cyan"></i> 商品マスター管理</h2>
                <div style="overflow-x: auto;"> <table>
                        <thead>
                            <tr>
                                <th>商品名</th>
                                <th style="width: 100px;">価格</th>
                                <th style="width: 70px;">CAT ID</th>
                                <th style="width: 100px; text-align: right;">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                String url = "jdbc:h2:tcp://localhost/~/CampusGridProject";
                                String user = "sa";
                                String password = "";

                                try {
                                    Class.forName("org.h2.Driver");
                                    try (Connection conn = DriverManager.getConnection(url, user, password);
                                         Statement stmt = conn.createStatement();
                                         ResultSet rs = stmt.executeQuery("SELECT * FROM PRODUCT")) {
                                        while (rs.next()) {
                                            String prodId = rs.getString("PRODUCT_ID");
                            %>
                            <tr>
                                <form action="${pageContext.request.contextPath}/ProductUpdateServlet" method="POST">
                                    <input type="hidden" name="productId" value="<%= prodId %>">
                                    <td><input type="text" name="productName" value="<%= rs.getString("PRODUCT_NAME") %>"></td>
                                    <td><input type="number" name="price" value="<%= rs.getInt("PRICE") %>"></td>
                                    <td>
                                        <input type="number" name="categoryId" value="<%= rs.getInt("CATEGORY_ID") %>" readonly>
                                    </td>
                                    <td>
                                        <div class="action-btns">
                                            <button type="submit" name="action" value="update" class="btn btn-update" title="更新"><i class="fas fa-save"></i></button>
                                            <button type="submit" name="action" value="delete" class="btn btn-delete" title="削除" onclick="return confirm('商品を削除しますか？')"><i class="fas fa-trash"></i></button>
                                        </div>
                                    </td>
                                </form>
                            </tr>
                            <%
                                        }
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='4' class='error-msg'>⚠️ 商品データ取得エラー: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <section class="category-section">
            <div class="glass-card category-card">
                <h2><i class="fas fa-tags text-orange"></i> カテゴリー管理</h2>
                <div style="overflow-x: auto;">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 60px;">ID</th>
                                <th>カテゴリー名</th>
                                <th style="width: 100px; text-align: right;">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    try (Connection conn = DriverManager.getConnection(url, user, password);
                                         Statement stmt = conn.createStatement();
                                         ResultSet rs = stmt.executeQuery("SELECT * FROM CATEGORY ORDER BY CATEGORY_ID ASC")) {
                                        while (rs.next()) {
                                            int catId = rs.getInt("CATEGORY_ID");
                            %>
                            <tr>
                                <form action="${pageContext.request.contextPath}/CategoryUpdateServlet" method="POST">
                                    <td>
                                        <input type="number" name="categoryId" value="<%= catId %>" readonly>
                                    </td>
                                    <td><input type="text" name="categoryName" value="<%= rs.getString("CATEGORY_NAME") %>"></td>
                                    <td>
                                        <div class="action-btns">
                                            <button type="submit" name="action" value="update" class="btn btn-update" title="更新"><i class="fas fa-save"></i></button>
                                            <button type="submit" name="action" value="delete" class="btn btn-delete" onclick="return confirm('カテゴリーを削除しますか？')"><i class="fas fa-trash"></i></button>
                                        </div>
                                    </td>
                                </form>
                            </tr>
                            <%
                                        }
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='3' class='error-msg'>⚠️ カテゴリ取得エラー: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </div>

    <nav class="footer-nav">
        <a href="${pageContext.request.contextPath}/LogIn/teacher_home.jsp" class="nav-link link-home">
            <i class="fas fa-arrow-left"></i> ホームへ戻る
        </a>
        <a href="${pageContext.request.contextPath}/jsp/product_add.jsp" class="nav-link link-add-product">
            <i class="fas fa-plus-circle"></i> 商品を追加
        </a>
        <a href="${pageContext.request.contextPath}/jsp/category_add.jsp" class="nav-link link-add-category">
            <i class="fas fa-folder-plus"></i> カテゴリーを追加
        </a>
    </nav>

</body>
</html>