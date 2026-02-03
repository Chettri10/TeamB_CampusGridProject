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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* --- iPhone 14 Pro Max (430px) 最適化設定 --- */
        :root {
            --sat: env(safe-area-inset-top, 50px);
            --sab: env(safe-area-inset-bottom, 34px);
        }

        html {
            background-color: #000; /* 枠外は黒 */
            height: 100%;
        }

        body {
            font-family: "Helvetica Neue", Arial, sans-serif;
            background-color: #020617; /* 深い紺色 */
            color: white;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin: 0 auto; /* 中央寄せ */
            padding: 0;
            min-height: 100vh;

            /* iPhone 14 Pro Max 幅固定 */
            max-width: 430px;
            box-shadow: 0 0 50px rgba(0,0,0,0.5);

            /* Dynamic Island考慮 */
            padding-top: calc(var(--sat) + 10px);
            padding-bottom: calc(var(--sab) + 20px);
            box-sizing: border-box;
        }

        .container {
            width: 100%;
            padding: 0 24px; /* 横の余白 */
            box-sizing: border-box;
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
            padding: 10px 0; /* タップしやすく */
        }
        .back-link:hover {
            color: #00ffff;
            opacity: 0.8;
        }

        h1 {
            font-size: 24px;
            text-align: center;
            margin-bottom: 30px;
            color: #00ffff;
            text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
        }

        /* フォームの各行のスタイル - スマホ用に縦積みに変更 */
        .form-group {
            display: flex;
            flex-direction: column; /* 縦並び */
            align-items: flex-start;
            margin-bottom: 24px;
            width: 100%;
        }

        .label {
            width: 100%;
            font-size: 15px;
            font-weight: bold;
            color: #e2e8f0;
            margin-bottom: 10px; /* 入力欄との間隔 */
        }

        .input-control {
            width: 100%;
        }

        /* テキスト入力、セレクトボックス、テキストエリアの共通スタイル */
        input[type="text"], select, textarea {
            width: 100%;
            padding: 14px; /* 指で押しやすい高さ */
            background-color: #ffffff;
            color: #333;
            border: none;
            border-radius: 12px; /* 少し丸みを強く */
            box-sizing: border-box;
            font-size: 16px; /* iOSでズームしないサイズ */
            appearance: none; /* OS標準スタイル解除 */
        }

        /* セレクトボックスの矢印用ハック */
        select {
            background-image: url("data:image/svg+xml;charset=utf8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 4 5'%3E%3Cpath fill='%23333' d='M2 0L0 2h4zm0 5L0 3h4z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 15px center;
            background-size: 8px 10px;
        }

        /* テキストエリアの高さ */
        textarea {
            height: 120px;
            resize: none;
        }

        /* ラジオボタンのコンテナ */
        .radio-group {
            display: flex;
            align-items: center;
            justify-content: space-between; /* 均等配置 */
            background: rgba(255, 255, 255, 0.05); /* 薄い背景でグループ化 */
            padding: 10px 15px;
            border-radius: 12px;
        }
        .radio-group label {
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            padding: 5px; /* タップ領域拡大 */
        }
        .radio-group input[type="radio"] {
            margin-right: 8px;
            width: 20px;
            height: 20px;
            accent-color: #00ffff;
        }

        /* 完了ボタンのスタイル */
        .submit-button {
            background-color: #00ffff;
            color: #020617;
            padding: 16px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            border-radius: 12px;
            margin-top: 20px;
            cursor: pointer;
            width: 100%;
            border: none;
            transition: 0.3s;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3);
        }
        .submit-button:active {
            transform: scale(0.98);
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
            <p style="color:#ff5252; text-align:center; margin-bottom:20px; font-weight:bold;"><%= error %></p>
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