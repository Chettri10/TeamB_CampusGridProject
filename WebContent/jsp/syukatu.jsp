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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: "Helvetica Neue", Arial, sans-serif;
            background-color: #020617; /* ★修正：他の画面と同じ深い紺色 */
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
            margin: 0;
        }
        .container {
            width: 90%;
            max-width: 450px;
            padding: 20px;
            margin-top: 20px; /* 少し上に詰める */
        }

        /* 戻るボタンエリア */
        .header-nav {
            width: 100%;
            text-align: left;
            margin-bottom: 20px;
        }
        .back-link {
            color: #94a3b8;
            text-decoration: none;
            font-size: 15px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: 0.3s;
            font-weight: bold;
        }
        .back-link:hover {
            color: #00ffff;
            transform: translateX(-3px);
        }

        h1 {
            font-size: 24px;
            text-align: center;
            margin-bottom: 30px;
            color: #00ffff; /* タイトルもシアンに合わせる */
            text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
        }

        /* フォームの各行のスタイル */
        .form-group {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .label {
            width: 100px; /* ラベル幅 */
            font-size: 16px;
            font-weight: bold;
            color: #e2e8f0;
            flex-shrink: 0;
        }
        .input-control {
            flex-grow: 1;
        }

        /* テキスト入力、セレクトボックス、テキストエリアの共通スタイル */
        input[type="text"], select, textarea {
            width: 100%;
            padding: 12px;
            background-color: #ffffff;
            color: #333;
            border: none;
            border-radius: 8px;
            box-sizing: border-box;
            font-size: 16px;
        }

        /* テキストエリアの高さ */
        textarea {
            height: 100px;
            resize: none;
        }

        /* ラジオボタンのコンテナ */
        .radio-group {
            display: flex;
            align-items: center;
        }
        .radio-group label {
            margin-right: 20px;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
        }
        .radio-group input[type="radio"] {
            margin-right: 8px;
            width: 18px;
            height: 18px;
            accent-color: #00ffff; /* ラジオボタンの色 */
        }

        /* 完了ボタンのスタイル */
        .submit-button {
            background-color: #00ffff; /* 明るいシアン */
            color: #020617;
            padding: 15px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            border-radius: 30px;
            margin-top: 30px;
            cursor: pointer;
            width: 100%;
            border: none;
            transition: 0.3s;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3);
        }
        .submit-button:hover {
            background-color: #00cccc;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

    <div class="container">

        <div class="header-nav">
            <a href="<%= request.getContextPath() %>/LogIn/student_home.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> ホームへ戻る
            </a>
        </div>

        <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
        %>
            <p style="color:#ff5252; text-align:center; margin-bottom:20px;"><%= error %></p>
        <%
        }
        %>

        <h1>就活状況の入力</h1>

        <form action="<%= request.getContextPath() %>/JobSearchServlet" method="POST">

            <%-- 1. 会社名 (テキスト入力) --%>
            <div class="form-group">
                <label for="companyName" class="label">会社名</label>
                <div class="input-control">
                    <input type="text" id="companyName" name="companyName" placeholder="会社名を入力" required>
                </div>
            </div>

            <%-- 2. 進捗状況 (ドロップダウン) --%>
            <div class="form-group">
                <label for="progressStatus" class="label">進捗状況</label>
                <div class="input-control">
                    <%-- ★修正：初期値を空にし、required属性をつけることで選択を必須化 --%>
                    <select id="progressStatus" name="progressStatus" required>
                        <option value="" selected disabled hidden>▼ 選択してください</option>
                        <% for (String status : statusOptions) { %>
                            <option value="<%= status %>"><%= status %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <%-- 3. 志望度 (ラジオボタン) --%>
            <div class="form-group">
                <label class="label">志望度</label>
                <div class="input-control radio-group">
                    <label><input type="radio" name="motivation" value="高" checked>高</label>
                    <label><input type="radio" name="motivation" value="中">中</label>
                    <label><input type="radio" name="motivation" value="低">低</label>
                </div>
            </div>

            <%-- 5. 備考 (テキストエリア) --%>
            <div class="form-group">
                <label for="notes" class="label">備考</label>
                <div class="input-control">
                    <textarea id="notes" name="notes" placeholder="次回面接日やメモなど"></textarea>
                </div>
            </div>

            <%-- 6. 完了ボタン --%>
            <button type="submit" class="submit-button">
                登録する
            </button>
        </form>

    </div>
</body>
</html>