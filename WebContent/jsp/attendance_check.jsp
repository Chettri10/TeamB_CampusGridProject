<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Date" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>出席状況一覧</title>
<style>
    /* --- クール＆モダンな青テーマ --- */
    :root {
        --bg-main: #021024;
        --text-main: #ffffff;
        --accent-cyan: #00e5ff;
        --accent-hover: #6effff;
        --panel-bg: #ffffff;
        --table-header: #052c48;
        --status-green: #00c853;
        --status-red: #ff1744;
        --status-orange: #ff9100;
        --status-purple: #d500f9;
    }

    body {
        background-color: var(--bg-main);
        color: var(--text-main);
        font-family: "Helvetica Neue", Arial, sans-serif;
        padding: 30px;
        text-align: center;
    }

    h1 {
        color: var(--text-main);
        margin-bottom: 25px;
        font-size: 28px;
        text-shadow: 0 2px 4px rgba(0,0,0,0.5);
        letter-spacing: 1px;
    }

    /* --- 日付操作エリア --- */
    .date-control {
        margin-bottom: 30px;
        padding: 10px;
        display: inline-block;
    }

    .nav-link {
        text-decoration: none;
        color: var(--accent-cyan);
        font-weight: bold;
        margin: 0 20px;
        font-size: 18px;
        transition: color 0.3s;
    }
    .nav-link:hover { color: var(--accent-hover); text-shadow: 0 0 8px var(--accent-cyan); }

    .date-form-container {
        display: inline-block;
        background: rgba(255, 255, 255, 0.1);
        padding: 8px 15px;
        border-radius: 8px;
        border: 1px solid rgba(0, 229, 255, 0.3);
    }

    input[type="date"] {
        padding: 6px 10px;
        font-size: 16px;
        border: 1px solid #ccc;
        border-radius: 4px;
        background-color: #fff;
        color: #333;
    }

    button {
        padding: 6px 20px;
        background-color: var(--accent-cyan);
        color: #021024;
        border: none;
        cursor: pointer;
        border-radius: 4px;
        font-weight: bold;
        font-size: 15px;
        margin-left: 10px;
        transition: all 0.2s;
        box-shadow: 0 0 10px rgba(0, 229, 255, 0.2);
    }
    button:hover {
        background-color: var(--accent-hover);
        box-shadow: 0 0 15px rgba(0, 229, 255, 0.6);
    }

    /* --- 集計ダッシュボード --- */
    .dashboard {
        display: flex;
        justify-content: center;
        gap: 20px;
        margin-bottom: 40px;
    }
    .status-card {
        background: var(--panel-bg);
        color: #333;
        padding: 15px 0;
        border-radius: 8px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        width: 110px;
        text-align: center;
        border-bottom: 4px solid #ccc;
    }
    .card-present { border-bottom-color: var(--status-green); }
    .card-late { border-bottom-color: var(--status-red); }
    .card-early { border-bottom-color: var(--status-orange); }
    .card-absent { border-bottom-color: var(--status-purple); }
    .card-unregistered { border-bottom-color: #999; }

    .status-label { font-size: 14px; color: #666; font-weight: bold; display: block; margin-bottom: 5px; }
    .count-number { font-size: 26px; font-weight: bold; display: block; }

    .text-green { color: var(--status-green); }
    .text-red { color: var(--status-red); }
    .text-orange { color: var(--status-orange); }
    .text-purple { color: var(--status-purple); }
    .text-gray { color: #666; }

    /* --- テーブルデザイン --- */
    table {
        width: 60%;
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
        font-weight: normal;
        border-bottom: 2px solid var(--accent-cyan);
    }
    td {
        border-bottom: 1px solid #eee;
        padding: 15px;
        color: #333;
        text-align: center;
    }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:hover { background-color: #f0f8ff; }

    /* 学生名リンクのスタイル */
    .link-student {
        color: #052c48;
        font-weight: bold;
        text-decoration: none;
        transition: color 0.2s;
        border-bottom: 1px solid transparent;
        font-size: 1.1em;
        display: block;
        width: 100%;
        height: 100%;
    }
    .link-student:hover {
        color: var(--accent-cyan);
        border-bottom-color: var(--accent-cyan);
    }

    a.home-link {
        text-decoration: none;
        color: var(--accent-cyan);
        display: inline-block;
        margin-top: 40px;
        font-size: 16px;
        border-bottom: 1px solid transparent;
        transition: all 0.3s;
    }
    a.home-link:hover { border-bottom-color: var(--accent-cyan); }
</style>
</head>
<body>

    <h1>出席状況一覧</h1>

    <div class="date-control">
        <a href="<%= request.getContextPath() %>/AttManagementListServlet?targetDate=<%= request.getAttribute("prevDate") %>" class="nav-link">&lt; 前日</a>

        <div class="date-form-container">
            <form action="<%= request.getContextPath() %>/AttManagementListServlet" style="display: inline;">
                <label style="color: #fff; margin-right: 8px;">日付:</label>
                <input type="date" name="targetDate" value="<%= request.getAttribute("displayDate") %>">
                <button type="submit">表示</button>
            </form>
        </div>

        <a href="<%= request.getContextPath() %>/AttManagementListServlet?targetDate=<%= request.getAttribute("nextDate") %>" class="nav-link">翌日 &gt;</a>
    </div>

    <div class="dashboard">
        <div class="status-card card-present">
            <span class="status-label">出席</span>
            <span class="count-number text-green"><%= request.getAttribute("countPresent") %>名</span>
        </div>
        <div class="status-card card-late">
            <span class="status-label">遅刻</span>
            <span class="count-number text-red"><%= request.getAttribute("countLate") %>名</span>
        </div>
        <div class="status-card card-early">
            <span class="status-label">早退</span>
            <span class="count-number text-orange"><%= request.getAttribute("countEarly") %>名</span>
        </div>
        <div class="status-card card-absent">
            <span class="status-label">欠席</span>
            <span class="count-number text-purple"><%= request.getAttribute("countAbsent") %>名</span>
        </div>
        <div class="status-card card-unregistered">
            <span class="status-label">未登録</span>
            <span class="count-number text-gray"><%= request.getAttribute("countUnregistered") %>名</span>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th width="30%">学籍番号</th>
                <th width="70%">氏名</th>
            </tr>
        </thead>
        <tbody>
        <%
            List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("attendanceList");

            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> data : list) {
        %>
            <tr>
                <td>
                    <a href="StudentHistoryServlet?userId=<%= data.get("userId") %>" class="link-student">
                        <%= data.get("userId") %>
                    </a>
                </td>
                <td>
                    <a href="StudentHistoryServlet?userId=<%= data.get("userId") %>" class="link-student">
                        <%= data.get("userName") %>
                    </a>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="2">データがありません。</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <br>
    <p style="color: #ccc; font-size: 0.9em;">※学生をクリックすると詳細・履歴の確認と編集ができます。</p>
    <a href="teacher_home.jsp" class="home-link">先生ホームへ戻る</a>

</body>
</html>