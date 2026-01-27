<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>商品新規登録 - Campus Grid</title>
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
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .glass-card {
            background: #0f172a;
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.6);
            border: 2px solid #00FFFF;
            width: 100%;
            max-width: 500px;
        }

        h2 {
            font-size: 24px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #00FFFF;
        }

        .form-group { margin-bottom: 20px; }
        label { display: block; font-size: 14px; color: #94a3b8; margin-bottom: 8px; }

        input, select, textarea {
            background: #1e293b;
            border: 1px solid #334155;
            color: white;
            padding: 12px;
            border-radius: 8px;
            width: 100%;
            font-size: 16px;
            transition: 0.3s;
            font-family: inherit;
        }
        input:focus, select:focus, textarea:focus {
            border-color: #00FFFF;
            outline: none;
            box-shadow: 0 0 10px rgba(0,255,255,0.2);
        }

        /* 詳細入力エリアの調整 */
        textarea {
            resize: vertical;
            min-height: 80px;
        }

        .btn-submit {
            background: transparent;
            color: #00FFFF;
            border: 2px solid #00FFFF;
            padding: 14px;
            border-radius: 8px;
            width: 100%;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
            transition: 0.3s;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }
        .btn-submit:hover { background: #00FFFF; color: #000; }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 25px;
            color: #94a3b8;
            text-decoration: none;
            font-size: 14px;
        }
        .back-link:hover { color: #fff; }

        .error-msg { color: #ff4444; background: rgba(255,68,68,0.1); padding: 10px; border-radius: 5px; margin-bottom: 20px; font-size: 13px; }
    </style>
</head>
<body>

    <div class="glass-card">
        <h2><i class="fas fa-plus-circle"></i> 商品の新規登録</h2>

        <form action="${pageContext.request.contextPath}/ProductAddServlet" method="POST">
            <div class="form-group">
                <label>商品ID (数値など)</label>
                <input type="text" name="productId" placeholder="例: 101" required>
            </div>

            <div class="form-group">
                <label>商品名</label>
                <input type="text" name="productName" placeholder="商品名を入力" required>
            </div>

            <div class="form-group">
                <label>価格 (円)</label>
                <input type="number" name="price" placeholder="例: 150" required>
            </div>

            <div class="form-group">
                <label>商品の詳細説明</label>
                <textarea name="productDetail" placeholder="例: B5サイズ、アルコール度数85%など"></textarea>
            </div>

            <div class="form-group">
                <label>カテゴリー選択</label>
                <select name="categoryId" required>
                    <option value="">カテゴリーを選択してください</option>
                    <%
                        String url = "jdbc:h2:tcp://localhost/~/CampusGridProject";
                        String user = "sa";
                        String password = "";
                        try {
                            Class.forName("org.h2.Driver");
                            try (Connection conn = DriverManager.getConnection(url, user, password);
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery("SELECT * FROM CATEGORY ORDER BY CATEGORY_ID ASC")) {
                                while (rs.next()) {
                    %>
                    <option value="<%= rs.getInt("CATEGORY_ID") %>">
                        <%= rs.getInt("CATEGORY_ID") %>: <%= rs.getString("CATEGORY_NAME") %>
                    </option>
                    <%
                                }
                            }
                        } catch (Exception e) {
                    %>
                    <option value="">カテゴリー取得エラー</option>
                    <%
                        }
                    %>
                </select>
            </div>

            <button type="submit" class="btn-submit">
                <i class="fas fa-save"></i> データベースに登録
            </button>
        </form>

        <a href="${pageContext.request.contextPath}/jsp/product_regist.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> 管理パネルへ戻る
        </a>
    </div>

</body>
</html>