<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>

<%
    // --- JSPスクリプトレットで選択肢データを準備 ---
    // 進捗状況の選択肢
    List<String> statusOptions = Arrays.asList("選考", "書類提出済", "内定獲得", "辞退");
%>



<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>就活状況の入力</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #0b1a37; /* 画像の背景色に合わせる */
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        .container {
            width: 90%;
            max-width: 450px;
            padding: 20px;
        }
        h1 {
            font-size: 24px;
            text-align: center;
            margin-bottom: 30px;
        }
        /* フォームの各行のスタイル */
        .form-group {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .label {
            width: 120px; /* ラベル幅を固定 */
            font-size: 16px;
            font-weight: bold;
            color: white;
        }
        .input-control {
            flex-grow: 1;
        }
        /* テキスト入力、セレクトボックス、テキストエリアの共通スタイル */
        input[type="text"], select, textarea {
            width: 100%;
            padding: 10px;
            background-color: white;
            color: #333;
            border: none;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 16px;
        }
        /* テキストエリアの高さ */
        textarea {
            height: 80px;
            resize: none;
        }
        /* ラジオボタンのコンテナ */
        .radio-group label {
            margin-right: 20px;
            font-size: 16px;
        }
        .radio-group input[type="radio"] {
            margin-right: 5px;
        }
        /* 完了ボタンのスタイル */
         .back-btn {
        display: inline-block;
        margin-top: 30px;
        padding: 12px 30px;
        background-color: transparent;
        color: #00ffff;
        text-decoration: none;
        border: 2px solid #00ffff;
        border-radius: 50px;
        font-weight: bold;
        transition: 0.3s;
    }
    .back-btn:hover {
        background-color: #00ffff;
        color: #020617;
        transform: translateY(-2px);
    }
    </style>
</head>
<body>

<div class="container">
    <h1>就活状況の入力</h1>
    <h1>登録が完了しました！</h1>

 <a href="<%= request.getContextPath() %>/LogIn/student_home.jsp" class="back-btn">
        メニューへ戻る
    </a>

</div>

</body>
</html>