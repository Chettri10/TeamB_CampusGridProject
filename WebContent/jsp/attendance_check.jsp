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
    h1 { color: #e65100; }

    /* 日付選択フォーム */
    .date-selector { margin-bottom: 20px; background: white; padding: 15px; display: inline-block; border-radius: 8px; }
    input[type="date"] { padding: 5px; font-size: 16px; }
    button { padding: 5px 15px; background-color: #ff9800; color: white; border: none; cursor: pointer; border-radius: 4px; }

    /* テーブルデザイン */
    table { width: 90%; margin: 0 auto; border-collapse: collapse; background-color: white; }
    th, td { border: 1px solid #ccc; padding: 12px; text-align: center; }
    th { background-color: #ff9800; color: white; }

    /* ステータスの色分け */
    .status-出席 { color: green; font-weight: bold; }
    .status-遅刻 { color: red; font-weight: bold; }
    .status-早退 { color: orange; font-weight: bold; }
    .status-未登録 { color: #aaa; }

    a { text-decoration: none; color: #e65100; }
</style>
</head>
<body>

    <h1>出席状況一覧</h1>

    <div class="date-selector">
<form action="<%= request.getContextPath() %>/AttManagementListServlet">
<label>日付: </label>
<input type="date" name="targetDate" value="<%= request.getAttribute("displayDate") %>">
<button type="submit">表示</button>
</form>
</div>

    <table>
<thead>
<tr>
<th>学籍番号</th>
<th>氏名</th>
<th>出席時刻</th>
<th>状況</th>
<th>備考 (遅刻理由など)</th>
</tr>
</thead>
<tbody>
<%
                List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("attendanceList");
                if (list != null && !list.isEmpty()) {
                    for (Map<String, Object> data : list) {
                        String status = (String)data.get("status");
            %>
<tr>
<td><%= data.get("userId") %></td>
<td><%= data.get("userName") %></td>
<td><%= data.get("checkInTime") %></td>
<td>
<span class="status-<%= status %>"><%= status %></span>
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
<a href="teacher_home.jsp">先生ホームへ戻る</a>

</body>
</html>