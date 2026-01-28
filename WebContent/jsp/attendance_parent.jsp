<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // データ取得
    String childId = (String) request.getAttribute("childId");
    List<Map<String, Object>> attendanceList = (List<Map<String, Object>>) request.getAttribute("attendanceList");
    String errorMsg = (String) request.getAttribute("errorMsg");

    // 時間フォーマット
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
    SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy/MM/dd");
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>出席状況一覧 - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    body {
        background-color: #020617;
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 20px;
        text-align: center;
    }

    h1 {
        color: #00ffff;
        font-size: 28px;
        margin-bottom: 5px;
    }

    .sub-title {
        color: #aaa;
        font-size: 14px;
        margin-bottom: 30px;
    }

    .container {
        max-width: 900px; /* 理由欄が増えたので少し幅を広げました */
        margin: 0 auto;
        background-color: #fff;
        color: #333;
        border-radius: 10px;
        padding: 20px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
        table-layout: fixed; /* 列幅を固定してレイアウト崩れを防ぐ */
    }

    th, td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #ddd;
        vertical-align: middle;
        word-wrap: break-word; /* 長い文章は折り返す */
    }

    th {
        background-color: #f8f9fa;
        color: #555;
        font-weight: bold;
    }

    .status-badge {
        display: inline-block;
        padding: 4px 8px;
        border-radius: 4px;
        color: white;
        font-size: 12px;
        font-weight: bold;
    }
    .status-present { background-color: #00c853; } /* 出席：緑 */
    .status-late { background-color: #ffb300; }    /* 遅刻：黄 */
    .status-absent { background-color: #ff5252; }  /* 欠席：赤 */
    .status-early { background-color: #ff9800; }   /* 早退：オレンジ */
    .status-none { background-color: #9e9e9e; }    /* 未登録：グレー */

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

    .error-msg {
        color: #ff5252;
        margin-bottom: 15px;
    }
</style>
</head>
<body>

    <h1>学生出席状況</h1>
    <div class="sub-title">学生ID: <%= childId != null ? childId : "不明" %></div>

    <div class="container">
        <% if (errorMsg != null) { %>
            <div class="error-msg"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
        <% } %>

        <% if (attendanceList != null && !attendanceList.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th style="width: 20%;">日付</th>
                        <th style="width: 15%;">ステータス</th>
                        <th style="width: 15%;">打刻時間</th>
                        <th style="width: 50%;">理由</th> </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> record : attendanceList) {
                        String status = (String) record.get("Status");
                        Object dateObj = record.get("Target_Date");
                        Object timeObj = record.get("Check_In_Time");

                        // ★追加：理由データを取得
                        String reason = (String) record.get("Absence_Reason");
                        if (reason == null) reason = ""; // nullなら空文字にする

                        // バッジの色判定
                        String badgeClass = "status-present";
                        if (status == null || status.equals("未登録")) badgeClass = "status-none";
                        else if (status.contains("遅刻")) badgeClass = "status-late";
                        else if (status.contains("欠席")) badgeClass = "status-absent";
                        else if (status.contains("早退") || status.contains("早退")) badgeClass = "status-early";
                    %>
                    <tr>
                        <td><%= dateObj != null ? dateObj.toString() : "" %></td>
                        <td><span class="status-badge <%= badgeClass %>"><%= status != null ? status : "未登録" %></span></td>
                        <td><%= timeObj != null ? sdfTime.format(timeObj) : "--:--" %></td>

                        <td style="color: #555;"><%= reason %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p style="text-align:center; padding: 20px; color: #888;">
                <i class="fas fa-info-circle"></i> 出席データが見つかりません。
            </p>
        <% } %>
    </div>

    <a href="<%= request.getContextPath() %>/LogIn/parent_home.jsp" class="back-btn">
        <i class="fas fa-home"></i> メニューへ戻る
    </a>

</body>
</html>