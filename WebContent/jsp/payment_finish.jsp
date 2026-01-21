<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // カートの商品リスト（cartList）と合計金額（price）をセッションから削除
    // これにより、商品一覧画面やカート画面の中身が空になります
    session.removeAttribute("cartList");
    session.removeAttribute("price");
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>購入完了 - キャンパスグリッド</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { background-color: #0b1a37; color: white; font-family: 'Noto Sans JP', sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .finish-container { background-color: #162a4d; padding: 40px; border-radius: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); text-align: center; width: 90%; max-width: 400px; }
        .success-icon { font-size: 60px; color: #00ffff; margin-bottom: 20px; }
        h1 { font-size: 24px; margin-bottom: 10px; }
        p { opacity: 0.8; margin-bottom: 30px; line-height: 1.6; }
        .btn-home { display: block; background-color: #00ffff; color: #0b1a37; text-decoration: none; padding: 15px; border-radius: 12px; font-weight: bold; transition: 0.2s; }
        .btn-home:hover { background-color: #5effff; transform: translateY(-2px); }
    </style>
</head>
<body>

<div class="finish-container">
    <div class="success-icon"><i class="fas fa-check-circle"></i></div>
    <h1>ご購入ありがとうございました！</h1>
    <p>注文処理が正常に完了しました。<br>商品は順次手配させていただきます。</p>

    <%--
       修正ポイント：
       スクリーンショットに合わせて、ファイル名の「半角スペース」と「LogIn」の綴りを正確に反映
    --%>
    <a href="${pageContext.request.contextPath}/LogIn/student_home.jsp" class="btn-home">
        メニュー画面へ戻る
    </a>
</div>

</body>
</html>