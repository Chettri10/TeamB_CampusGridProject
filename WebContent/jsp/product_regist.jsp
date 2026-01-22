<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>登録管理画面</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background-color: #f4f7f6; display: flex; flex-direction: column; align-items: center; }
        .form-container { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); width: 400px; margin-bottom: 20px; }
        .field { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; }
        input, textarea { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; }

        /* 商品登録用ボタン */
        .btn-product { background-color: #00bcd4; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; width: 100%; }
        /* カテゴリー登録用ボタン */
        .btn-category { background-color: #ff9800; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; width: 100%; }

        hr { width: 100%; border: 0; border-top: 1px solid #ddd; margin: 20px 0; }
        .cancel-link { text-decoration: none; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>

    <div class="form-container" style="border-top: 5px solid #00bcd4;">
        <h2>新規商品登録</h2>
        <form action="${pageContext.request.contextPath}/ProductRegistServlet" method="post">
            <div class="field">
                <label>商品名</label>
                <input type="text" name="productName" required>
            </div>
            <div class="field">
                <label>価格</label>
                <input type="number" name="price" required>
            </div>
            <div class="field">
                <label>カテゴリーID (登録済みのIDを入力)</label>
                <input type="number" name="categoryId" required>
            </div>
            <div class="field">
                <label>商品説明</label>
                <textarea name="productDetail" rows="4"></textarea>
            </div>
            <button type="submit" class="btn-product">商品を登録する</button>
        </form>
    </div>

    <div class="form-container" style="border-top: 5px solid #ff9800;">
        <h2 style="color: #e68a00;">新規カテゴリー登録</h2>
        <form action="${pageContext.request.contextPath}/CategoryRegistServlet" method="post">
            <div class="field">
                <label>カテゴリーID</label>
                <input type="number" name="categoryId" required placeholder="例: 3">
            </div>
            <div class="field">
                <label>カテゴリー名</label>
                <input type="text" name="categoryName" required placeholder="例: 免許代">
            </div>
            <button type="submit" class="btn-category">カテゴリーを登録する</button>
        </form>
    </div>

    <a href="${pageContext.request.contextPath}/LogIn/teacher_home.jsp" class="cancel-link">ホームへ戻る</a>

</body>
</html>