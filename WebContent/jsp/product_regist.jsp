<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>登録管理画面 - Campus Grid</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Noto Sans JP', sans-serif;
            padding: 40px 20px;
            background-color: #020617; /* 画像のようなダークネイビー */
            color: #FFFFFF;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin: 0;
        }

        h2 { font-size: 24px; font-weight: 700; margin-bottom: 25px; text-align: center; }

        .form-container {
            background: #0f172a; /* カードの背景色 */
            padding: 30px;
            border-radius: 20px;
            width: 100%;
            max-width: 430px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }

        /* 商品登録用（シアン）の光る枠線 */
        .product-card { border: 2px solid #00FFFF; box-shadow: 0 0 15px rgba(0, 255, 255, 0.3); }
        /* カテゴリー登録用（オレンジ）の光る枠線 */
        .category-card { border: 2px solid #ff9800; box-shadow: 0 0 15px rgba(255, 152, 0, 0.3); }

        .field { margin-bottom: 20px; }
        label { display: block; font-weight: bold; margin-bottom: 8px; color: #cbd5e1; font-size: 14px; }

        input, textarea {
            width: 100%;
            padding: 12px 15px;
            background-color: #1e293b;
            border: 1px solid #334155;
            border-radius: 12px;
            color: white;
            font-size: 16px;
            outline: none;
            transition: 0.3s;
        }

        input:focus, textarea:focus { border-color: #00FFFF; background-color: #0f172a; }

        /* ボタンの共通スタイル */
        .btn {
            width: 100%;
            height: 56px;
            border: none;
            border-radius: 14px;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.1s, opacity 0.2s;
            margin-top: 10px;
        }
        .btn:active { transform: scale(0.98); }

        /* 商品登録ボタン（シアン） */
        .btn-product {
            background-color: #00FFFF;
            color: #000000;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.4);
        }

        /* カテゴリー登録ボタン（オレンジ） */
        .btn-category {
            background-color: #ff9800;
            color: #ffffff;
            box-shadow: 0 4px 15px rgba(255, 152, 0, 0.4);
        }

        .cancel-link {
            text-decoration: none;
            color: #00FFFF;
            font-weight: bold;
            margin-top: 20px;
            padding: 10px;
        }
        .cancel-link:hover { text-decoration: underline; }
    </style>
</head>
<body>

    <div class="form-container product-card">
        <h2>新規商品登録</h2>
        <form action="${pageContext.request.contextPath}/ProductRegistServlet" method="post">
            <div class="field">
                <label>商品名</label>
                <input type="text" name="productName" placeholder="商品名を入力" required>
            </div>
            <div class="field">
                <label>価格</label>
                <input type="number" name="price" placeholder="¥ 0" required>
            </div>
            <div class="field">
                <label>カテゴリーID</label>
                <input type="number" name="categoryId" placeholder="登録済みのIDを入力" required>
            </div>
            <div class="field">
                <label>商品説明</label>
                <textarea name="productDetail" rows="3" placeholder="商品の詳細説明を入力"></textarea>
            </div>
            <button type="submit" class="btn btn-product">商品を登録する</button>
        </form>
    </div>

    <div class="form-container category-card">
        <h2 style="color: #ff9800;">新規カテゴリー登録</h2>
        <form action="${pageContext.request.contextPath}/CategoryRegistServlet" method="post">
            <div class="field">
                <label>カテゴリーID</label>
                <input type="number" name="categoryId" placeholder="例: 0" required>
            </div>
            <div class="field">
                <label>カテゴリー名</label>
                <input type="text" name="categoryName" placeholder="例: 専門用具" required>
            </div>
            <button type="submit" class="btn btn-category">カテゴリーを登録する</button>
        </form>
    </div>

    <a href="${pageContext.request.contextPath}/LogIn/teacher_home.jsp" class="cancel-link">← ホームへ戻る</a>

</body>
</html>