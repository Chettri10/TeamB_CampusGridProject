<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>学生別 出席履歴</title>
<style>
    :root {
        --bg-main: #021024;
        --accent-cyan: #00e5ff;
        --panel-bg: #ffffff;
        --table-header: #052c48;
        --status-green: #00c853;
        --status-red: #ff1744;
        --status-orange: #ff9100;
    }

    body {
        background-color: var(--bg-main);
        color: #fff;
        font-family: "Helvetica Neue", Arial, sans-serif;
        padding: 30px;
        text-align: center;
    }

    h1 { margin-bottom: 10px; text-shadow: 0 2px 4px rgba(0,0,0,0.5); }
    h2 { color: var(--accent-cyan); margin-bottom: 30px; font-weight: normal; }

    /* テーブルデザイン */
    table {
        width: 80%;
        margin: 0 auto;
        border-collapse: separate;
        border-spacing: 0;
        background-color: var(--panel-bg);
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 0 20px rgba(0,0,0,0.5);
    }
    thead {
        background-color: var(--table-header);
        color: #fff;
    }
    th {
        padding: 15px;
        border-bottom: 2px solid var(--accent-cyan);
    }
    td {
        border-bottom: 1px solid #eee;
        padding: 12px;
        color: #333;
        text-align: center;
    }
    tbody tr:hover { background-color: #f0f8ff; }

    /* ステータスバッジ */
    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 15px;
        font-size: 14px;
        font-weight: bold;
        min-width: 60px;
    }
    .badge-出席 { background-color: #e8f5e9; color: var(--status-green); border: 1px solid var(--status-green); }
    .badge-遅刻 { background-color: #ffebee; color: var(--status-red); border: 1px solid var(--status-red); }
    .badge-早退 { background-color: #fff3e0; color: var(--status-orange); border: 1px solid var(--status-orange); }
    .badge-欠席 { background-color: #fce4ec; color: #880e4f; border: 1px solid #880e4f; }
    .badge-未登録 { background-color: #f5f5f5; color: #999; border: 1px solid #ccc; }

    /* 戻るボタン */
    .btn-back {
        display: inline-block;
        margin-top: 30px;
        padding: 10px 30px;
        background-color: #e0e0e0;
        color: #333;
        text-decoration: none;
        border-radius: 30px;
        font-weight: bold;
        transition: all 0.2s;
    }
    .btn-back:hover {
        background-color: var(--accent-cyan);
        color: #021024;
    }
</style>
</head>
<body>

    <h1>学生別 出席履歴</h1>
    <h2>
        <%= request.getAttribute("studentName") %>
        <span style="font-size: 0.7em; color: #ccc;">(<%= request.getAttribute("studentId") %>)</span>
    </h2>

    <table>
        <thead>
            <tr>
                <th>日付</th>
                <th>出席時刻</th>
                <th>退室時刻</th>
                <th>状況</th>
                <th>備考</th>
            </tr>
        </thead>
        <tbody>
        <%
            List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("historyList");
            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> data : list) {
                    String status = (String)data.get("status");
        %>
            <tr>
                <td style="font-weight: bold;"><%= data.get("date") %></td>

                <td style="font-family: monospace; font-size: 1.1em;"><%= data.get("checkInTime") %></td>
                <td style="font-family: monospace; font-size: 1.1em;"><%= data.get("checkOutTime") %></td>

                <td>
                    <span class="status-badge badge-<%= status %>"><%= status %></span>
                </td>

                <td style="text-align: left;"><%= data.get("reason") %></td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="5">データがありません。</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <br>
    <a href="AttManagementListServlet" class="btn-back">一覧へ戻る</a>

</body>
</html>