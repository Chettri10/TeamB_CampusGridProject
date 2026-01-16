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
    body { background-color: #fff3e0; color: #333; font-family: sans-serif; padding: 30px; text-align: center; }
    h1 { color: #e65100; margin-bottom: 10px; }

    /* --- 集計ダッシュボード --- */
    .dashboard {
        display: flex;
        justify-content: center;
        gap: 20px;
        margin-bottom: 30px;
    }
    .status-card {
        background: white;
        padding: 10px 20px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        min-width: 80px;
        text-align: center;
        border-top: 5px solid #ccc;
    }
    /* 各カードの色設定 */
    .card-present { border-color: green; }
    .card-late { border-color: red; }
    .card-early { border-color: orange; }
    .card-unregistered { border-color: #aaa; }

    .count-number { font-size: 24px; font-weight: bold; display: block; margin-top: 5px; }
    /* ---------------------------------- */

    .date-control { margin-bottom: 20px; background: white; padding: 15px; display: inline-block; border-radius: 8px; }
    input[type="date"] { padding: 5px; font-size: 16px; }
    button { padding: 5px 15px; background-color: #ff9800; color: white; border: none; cursor: pointer; border-radius: 4px; }

    .nav-link { text-decoration: none; color: #e65100; font-weight: bold; margin: 0 15px; font-size: 18px; }
    .nav-link:hover { text-decoration: underline; }

    table { width: 95%; margin: 0 auto; border-collapse: collapse; background-color: white; }
    th, td { border: 1px solid #ccc; padding: 12px; text-align: center; }
    th { background-color: #ff9800; color: white; }

    /* ステータスの色分け */
    .status-出席 { color: green; font-weight: bold; }
    .status-遅刻 { color: red; font-weight: bold; }
    .status-早退 { color: orange; font-weight: bold; }
    .status-未登録 { color: #aaa; }

    .btn-edit { background-color: #4CAF50; color: white; padding: 5px 10px; text-decoration: none; border-radius: 4px; font-size: 14px; }
    .btn-edit:hover { background-color: #45a049; }

    a.home-link { text-decoration: none; color: #e65100; display: inline-block; margin-top: 20px; }
</style>
</head>
<body>

    <h1>出席状況一覧</h1>

    <div class="date-control">
        <a href="<%= request.getContextPath() %>/AttManagementListServlet?targetDate=<%= request.getAttribute("prevDate") %>" class="nav-link">&lt; 前日</a>
        <form action="<%= request.getContextPath() %>/AttManagementListServlet" style="display: inline;">
            <label>日付: </label>
            <input type="date" name="targetDate" value="<%= request.getAttribute("displayDate") %>">
            <button type="submit">表示</button>
        </form>
        <a href="<%= request.getContextPath() %>/AttManagementListServlet?targetDate=<%= request.getAttribute("nextDate") %>" class="nav-link">翌日 &gt;</a>
    </div>

    <div class="dashboard">
        <div class="status-card card-present">
            <span>出席</span>
            <span class="count-number" style="color: green;"><%= request.getAttribute("countPresent") %>名</span>
        </div>
        <div class="status-card card-late">
            <span>遅刻</span>
            <span class="count-number" style="color: red;"><%= request.getAttribute("countLate") %>名</span>
        </div>
        <div class="status-card card-early">
            <span>早退</span>
            <span class="count-number" style="color: orange;"><%= request.getAttribute("countEarly") %>名</span>
        </div>
        <div class="status-card card-unregistered">
            <span>未登録</span>
            <span class="count-number" style="color: #666;"><%= request.getAttribute("countUnregistered") %>名</span>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th>学籍番号</th>
                <th>氏名</th>
                <th>出席時刻</th>
                <th>退室時刻</th> <th>状況</th>
                <th>備考 (遅刻理由など)</th>
                <th>操作</th>
            </tr>
        </thead>
        <tbody>
        <%
            List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("attendanceList");
            Date displayDate = (Date)request.getAttribute("displayDate");

            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> data : list) {
                    String status = (String)data.get("status");

                    // 退室時刻の取得（null対策）
                    Object checkOutObj = data.get("checkOutTime");
                    String checkOutStr = (checkOutObj == null) ? "--:--" : checkOutObj.toString();
        %>
            <tr>
                <td><%= data.get("userId") %></td>
                <td><%= data.get("userName") %></td>
                <td><%= data.get("checkInTime") == null ? "--:--" : data.get("checkInTime") %></td>

                <td><%= checkOutStr %></td>

                <td>
                    <span class="status-<%= status %>"><%= status %></span>
                </td>
                <td style="text-align: left;"><%= data.get("reason") == null ? "" : data.get("reason") %></td>
                <td>
                    <a href="AttManagementEditServlet?userId=<%= data.get("userId") %>&targetDate=<%= displayDate %>" class="btn-edit">編集</a>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="7">データがありません。</td> </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <br>
    <a href="teacher_home.jsp" class="home-link">先生ホームへ戻る</a>

</body>
</html>