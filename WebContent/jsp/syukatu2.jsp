<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>登録完了 - CAMPUS GRID</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: "Helvetica Neue", Arial, sans-serif;
            background-color: #020617; /* 共通の深い紺色 */
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh; /* 画面中央に配置 */
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
        }

        .container {
            text-align: center;
            width: 100%;
            max-width: 500px;
            padding: 40px 20px;
            background-color: rgba(255, 255, 255, 0.05); /* うっすら明るい背景 */
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        .success-icon {
            font-size: 60px;
            color: #00ffff; /* シアン */
            margin-bottom: 20px;
            animation: popIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        h1 {
            font-size: 24px;
            margin-bottom: 10px;
            color: #00ffff;
            text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
        }

        p {
            font-size: 16px;
            color: #e2e8f0;
            margin-bottom: 40px;
            line-height: 1.6;
        }

        /* 戻るボタンのスタイル */
        .back-btn {
            display: inline-block;
            padding: 15px 40px;
            background-color: transparent;
            color: #00ffff;
            text-decoration: none;
            border: 2px solid #00ffff;
            border-radius: 50px;
            font-weight: bold;
            font-size: 16px;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .back-btn:hover {
            background-color: #00ffff;
            color: #020617;
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 255, 255, 0.4);
        }

        /* アニメーション */
        @keyframes popIn {
            0% { transform: scale(0); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>

    <div class="container">
        <i class="fas fa-check-circle success-icon"></i>

        <h1>登録が完了しました！</h1>
        <p>
            就職活動の状況が正常に保存されました。<br>
            引き続き頑張ってください！
        </p>

        <a href="<%= request.getContextPath() %>/LogIn/student_home.jsp" class="back-btn">
            メニューへ戻る
        </a>
    </div>

</body>
</html>