<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>カテゴリー新規登録 - Campus Grid</title>
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
            border: 2px solid #ff9800; /* カテゴリー用のオレンジ色 */
            width: 100%;
            max-width: 500px;
        }

        h2 {
            font-size: 24px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #ff9800;
        }

        .form-group { margin-bottom: 25px; }
        label { display: block; font-size: 14px; color: #94a3b8; margin-bottom: 8px; }

        input {
            background: #1e293b;
            border: 1px solid #334155;
            color: white;
            padding: 12px;
            border-radius: 8px;
            width: 100%;
            font-size: 16px;
            transition: 0.3s;
        }
        input:focus { border-color: #ff9800; outline: none; box-shadow: 0 0 10px rgba(255,152,0,0.2); }

        .btn-submit {
            background: transparent;
            color: #ff9800;
            border: 2px solid #ff9800;
            padding: 14px;
            border-radius: 8px;
            width: 100%;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
            transition: 0.3s;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }
        .btn-submit:hover { background: #ff9800; color: #000; }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 25px;
            color: #94a3b8;
            text-decoration: none;
            font-size: 14px;
        }
        .back-link:hover { color: #fff; }

        .info-box {
            background: rgba(255, 152, 0, 0.05);
            border-left: 4px solid #ff9800;
            padding: 15px;
            margin-bottom: 25px;
            font-size: 13px;
            color: #cbd5e1;
            line-height: 1.6;
        }
    </style>
</head>
<body>

    <div class="glass-card">
        <h2><i class="fas fa-folder-plus"></i> カテゴリーの新規登録</h2>

        <div class="info-box">
            <i class="fas fa-info-circle"></i>
            新しいカテゴリー（例：飲み物、お弁当、文房具など）を作成します。登録したカテゴリーは商品の追加時に選択できるようになります。
        </div>

        <form action="${pageContext.request.contextPath}/CategoryAddServlet" method="POST">
            <div class="form-group">
                <label>カテゴリーID (数値)</label>
                <input type="number" name="categoryId" placeholder="例: 10" required>
            </div>

            <div class="form-group">
                <label>カテゴリー名</label>
                <input type="text" name="categoryName" placeholder="例: デザート" required>
            </div>

            <button type="submit" class="btn-submit">
                <i class="fas fa-save"></i> 登録
            </button>
        </form>

        <a href="${pageContext.request.contextPath}/jsp/product_regist.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> 管理パネルへ戻る
        </a>
    </div>

</body>
</html>