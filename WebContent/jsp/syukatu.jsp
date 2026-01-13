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
        .submit-button {
            background-color: #00ffff; /* 明るいシアン */
            color: black;
            padding: 15px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            border-radius: 5px;
            margin-top: 30px;
            cursor: pointer;
            width: 100%;
            border: none;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>就活状況の入力</h1>

    <%-- フォームの開始。アクション先は後続のServletを想定 --%>
    <form action="JobSearchRegisterServlet" method="POST">

        <%-- 1. 会社名 (テキスト入力) --%>
        <div class="form-group">
            <label for="companyName" class="label">会社名</label>
            <div class="input-control">
                <input type="text" id="companyName" name="companyName" placeholder="会社" required>
            </div>
        </div>

        <%-- 2. 進捗状況 (ドロップダウン) --%>
        <div class="form-group">
            <label for="progressStatus" class="label">進捗状況</label>
            <div class="input-control">
                <select id="progressStatus" name="progressStatus" required>
                    <%-- JSPスクリプトレットで選択肢を生成 --%>
                    <% for (String status : statusOptions) { %>
                        <option value="<%= status %>" <%= status.equals("選考") ? "selected" : "" %>>
                            <%= status %>
                        </option>
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

        <%-- 4. エントリー ID (テキスト入力) --%>
        <div class="form-group">
            <label for="entryId" class="label">エントリー ID</label>
            <div class="input-control">
                <input type="text" id="entryId" name="entryId" placeholder="エントリー ID">
            </div>
        </div>

        <%-- 5. 備考 (テキストエリア) --%>
        <div class="form-group">
            <label for="notes" class="label">備考</label>
            <div class="input-control">
                <textarea id="notes" name="notes" placeholder="備考"></textarea>
            </div>
        </div>

        <%-- 6. 完了ボタン --%>
        <button type="submit" class="submit-button">
            完了
        </button>
    </form>
</div>

</body>
</html>