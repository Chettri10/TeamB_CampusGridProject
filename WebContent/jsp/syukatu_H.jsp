<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    // Servletからデータを受け取る
    List<Map<String, Object>> attendanceList = (List<Map<String, Object>>) request.getAttribute("syukatuList");
    String studentName = (String) request.getAttribute("USER_NAME");
    String studentId = (String) request.getAttribute("StudentId");

    // ロールチェック（保護者以外はエラー）
    String role = (String) session.getAttribute("role");
    // ※今回は簡易チェックとして、roleがnullでなければOKとするか、厳密に "parent" かチェックしてください
    // if (role == null || !role.equals("parent")) { ... }
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>就活情報確認 - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    /* --- 全体設定 --- */
    body {
        background-color: #020617; /* 共通の深い紺色 */
        color: white;
        font-family: "Helvetica Neue", Arial, sans-serif;
        margin: 0;
        padding: 20px;
        text-align: center;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    h1 {
        color: #00ffff;
        font-size: 28px;
        margin-bottom: 20px;
        font-weight: bold;
        text-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }

    /* --- 学生情報カード --- */
    .student-info-card {
        background-color: rgba(255, 255, 255, 0.1);
        border: 1px solid #00ffff;
        border-radius: 15px;
        padding: 15px 30px;
        margin-bottom: 30px;
        display: inline-block;
        min-width: 250px;
    }
    .student-name {
        font-size: 20px;
        font-weight: bold;
        color: #fff;
        margin: 0;
    }
    .student-id {
        font-size: 14px;
        color: #94a3b8;
        margin-top: 5px;
    }

    /* --- テーブルエリア --- */
    .table-container {
        width: 100%;
        max-width: 800px;
        background-color: #ffffff; /* テーブル内は見やすく白背景 */
        border-radius: 12px;
        overflow: hidden; /* 角丸のため */
        box-shadow: 0 4px 15px rgba(0,0,0,0.5);
        color: #333;
        margin-bottom: 30px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        font-size: 15px;
    }

    th {
        background-color: #f1f5f9;
        color: #475569;
        font-weight: bold;
        padding: 15px;
        text-align: left;
        border-bottom: 2px solid #e2e8f0;
        white-space: nowrap;
    }

    td {
        padding: 15px;
        border-bottom: 1px solid #e2e8f0;
        text-align: left;
        vertical-align: top;
        line-height: 1.5;
    }

    /* 最後の行の下線は消す */
    tr:last-child td { border-bottom: none; }

    /* ステータスバッジ */
    .status-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        color: white;
        background-color: #64748b; /* デフォルト */
    }
    /* ステータスごとの色分け例 */
    .status-badge[data-status="内定獲得"] { background-color: #00c853; } /* 緑 */
    .status-badge[data-status="選考"] { background-color: #0288d1; }     /* 青 */
    .status-badge[data-status="辞退"] { background-color: #ff5252; }     /* 赤 */

    /* --- 戻るボタン --- */
    .back-btn {
        display: inline-block;
        padding: 12px 35px;
        background-color: transparent;
        color: #00ffff;
        border: 2px solid #00ffff;
        border-radius: 50px;
        text-decoration: none;
        font-weight: bold;
        font-size: 16px;
        transition: 0.3s;
    }
    .back-btn:hover {
        background-color: #00ffff;
        color: #020617;
        transform: translateY(-3px);
    }

    /* --- メッセージ --- */
    .no-data {
        padding: 30px;
        color: #64748b;
        text-align: center;
    }
</style>
</head>
<body>

    <h1>就活情報確認</h1>

    <div class="student-info-card">
        <div class="student-name">
            <i class="fas fa-user-graduate"></i> <%= (studentName != null) ? studentName : "学生情報なし" %>
        </div>
        <div class="student-id">ID: <%= (studentId != null) ? studentId : "--" %></div>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th style="width: 25%;">会社名</th>
                    <th style="width: 15%;">状況</th>
                    <th style="width: 15%;">登録日</th>
                    <th style="width: 45%;">備考</th>
                </tr>
            </thead>
            <tbody>
                <%
                if (attendanceList != null && !attendanceList.isEmpty()) {
                    for (Map<String, Object> row : attendanceList) {
                        String status = (String)row.get("progress");
                        if(status == null) status = "未登録";
                %>
                <tr>
                    <td style="font-weight:bold; color:#0f172a;">
                        <%= row.get("company") != null ? row.get("company") : "--" %>
                    </td>
                    <td>
                        <span class="status-badge" data-status="<%= status %>"><%= status %></span>
                    </td>
                    <td style="color:#64748b; font-size:13px;">
                        <%= row.get("date") != null ? row.get("date") : "--" %>
                    </td>
                    <td style="color:#334155;">
    <%= (row.get("notes") != null && !((String)row.get("notes")).trim().isEmpty())
            ? row.get("notes")
            : "-----" %>
</td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="4" class="no-data">
                        まだ登録された情報はありません。
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <a href="<%= request.getContextPath() %>/LogIn/parent_home.jsp" class="back-btn">
        <i class="fas fa-home"></i> メニューへ戻る
    </a>

</body>
</html>