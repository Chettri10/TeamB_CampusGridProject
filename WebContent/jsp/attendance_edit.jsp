<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>出席情報の編集</title>
<style>
    :root {
        --bg-main: #021024;
        --accent-cyan: #00e5ff;
        --accent-hover: #6effff;
        --panel-bg: #ffffff;
        --input-border: #ccc;
        --input-focus: #00e5ff;
    }

    body {
        background-color: var(--bg-main);
        color: #fff;
        font-family: "Helvetica Neue", Arial, sans-serif;
        padding: 30px;
        text-align: center;
    }

    h1 { margin-bottom: 30px; text-shadow: 0 2px 4px rgba(0,0,0,0.5); }

    /* フォームコンテナ（白パネル） */
    .edit-container {
        background: var(--panel-bg);
        color: #333; /* パネル内の文字は黒 */
        width: 500px;
        margin: 0 auto;
        padding: 40px;
        border-radius: 10px;
        box-shadow: 0 0 20px rgba(0, 229, 255, 0.15); /* ほんのりシアンの光 */
        text-align: left;
        position: relative;
        overflow: hidden;
    }

    /* 上部のカラーバーアクセント */
    .edit-container::before {
        content: "";
        position: absolute;
        top: 0; left: 0; right: 0;
        height: 6px;
        background: linear-gradient(90deg, #00e5ff, #0056b3);
    }

    .form-group { margin-bottom: 25px; }

    label {
        display: block;
        font-weight: bold;
        margin-bottom: 8px;
        color: #052c48; /* ラベルは濃い紺色 */
        font-size: 14px;
    }

    /* 入力フィールド */
    input[type="text"], input[type="time"], select, textarea {
        width: 100%; padding: 12px; font-size: 16px;
        border: 2px solid #e0e0e0; border-radius: 6px; box-sizing: border-box;
        background-color: #f9f9f9;
        transition: all 0.3s;
    }
    input:focus, select:focus, textarea:focus {
        border-color: var(--input-focus);
        background-color: #fff;
        outline: none;
        box-shadow: 0 0 5px rgba(0, 229, 255, 0.3);
    }
    textarea { height: 100px; resize: vertical; }

    /* 日付・名前の表示エリア */
    .value-display {
        font-size: 1.2em;
        padding: 5px 0;
        font-weight: bold;
        color: #021024;
        border-bottom: 1px solid #eee;
    }

    /* ボタンエリア */
    .btn-group {
        text-align: center;
        margin-top: 40px;
        display: flex;
        justify-content: center;
        gap: 20px;
    }

    button, .btn-cancel {
        padding: 12px 40px;
        font-size: 16px;
        border: none;
        border-radius: 30px;
        cursor: pointer;
        font-weight: bold;
        text-decoration: none;
        transition: all 0.2s;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    .btn-save {
        background-color: var(--accent-cyan);
        color: #021024;
    }
    .btn-save:hover {
        background-color: var(--accent-hover);
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0, 229, 255, 0.3);
    }

    .btn-cancel {
        background-color: #e0e0e0;
        color: #555;
    }
    .btn-cancel:hover {
        background-color: #d0d0d0;
        transform: translateY(-2px);
    }
</style>
<script>
    // 公欠や欠席が選ばれたら、時刻入力をクリアして無効化する補助機能
    function toggleTimeInputs() {
        const status = document.getElementById("statusSelect").value;
        const timeInputs = document.querySelectorAll('input[type="time"]');
        if (status === "欠席" || status === "公欠") {
            timeInputs.forEach(input => {
                input.value = "";
                input.style.opacity = "0.5";
            });
        } else {
            timeInputs.forEach(input => {
                input.style.opacity = "1";
            });
        }
    }
</script>
</head>
<body>

    <h1>出席情報の編集</h1>

    <%
        Map<String, Object> data = (Map<String, Object>) request.getAttribute("attData");
        String currentStatus = (data != null && data.get("status") != null) ? (String) data.get("status") : "未登録";

        // 時刻データから HH:mm 部分だけを抽出（yyyy-MM-dd HH:mm:ss.s 対策）
        String checkIn = (String) data.get("checkInTime");
        if (checkIn != null && checkIn.contains(" ")) checkIn = checkIn.split(" ")[1].substring(0, 5);
        if (checkIn == null || checkIn.equals("--:--")) checkIn = "";

        String checkOut = (String) data.get("checkOutTime");
        if (checkOut != null && checkOut.contains(" ")) checkOut = checkOut.split(" ")[1].substring(0, 5);
        if (checkOut == null || checkOut.equals("--:--")) checkOut = "";
    %>

    <div class="edit-container">
        <form action="<%= request.getContextPath() %>/AttManagementEditServlet" method="post">

            <input type="hidden" name="userId" value="<%= data.get("userId") %>">
            <input type="hidden" name="targetDate" value="<%= request.getAttribute("targetDate") %>">

            <div class="form-group">
                <label>日付</label>
                <div class="value-display"><%= request.getAttribute("targetDate") %></div>
            </div>

            <div class="form-group">
                <label>氏名 (学籍番号)</label>
                <div class="value-display">
                    <%= data.get("userName") %> <span style="font-size:0.8em; color:#666;">(<%= data.get("userId") %>)</span>
                </div>
            </div>

            <div class="form-group">
                <label>状況</label>
                <select name="status" id="statusSelect" onchange="toggleTimeInputs()">
                    <option value="出席" <%= "出席".equals(currentStatus) ? "selected" : "" %>>出席</option>
                    <option value="遅刻" <%= "遅刻".equals(currentStatus) ? "selected" : "" %>>遅刻</option>
                    <option value="早退" <%= "早退".equals(currentStatus) ? "selected" : "" %>>早退</option>
                    <option value="欠席" <%= "欠席".equals(currentStatus) ? "selected" : "" %>>欠席</option>
                    <option value="公欠" <%= "公欠".equals(currentStatus) ? "selected" : "" %>>公欠</option>
                    <option value="未登録" <%= "未登録".equals(currentStatus) ? "selected" : "" %>>未登録</option>
                </select>
            </div>

            <div class="form-group">
                <label>出席時刻</label>
                <input type="time" name="checkInTime" value="<%= checkIn %>">
            </div>

            <div class="form-group">
                <label>退室時刻</label>
                <input type="time" name="checkOutTime" value="<%= checkOut %>">
            </div>

            <div class="form-group">
                <label>備考 (理由など)</label>
                <textarea name="reason" placeholder="公欠の理由などを記入してください"><%= data.get("reason") != null ? data.get("reason") : "" %></textarea>
            </div>

            <div class="btn-group">
                <a href="AttManagementListServlet?targetDate=<%= request.getAttribute("targetDate") %>" class="btn-cancel">戻る</a>
                <button type="submit" class="btn-save">更新する</button>
            </div>

        </form>
    </div>

</body>
</html>