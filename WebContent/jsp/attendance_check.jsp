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
    }

    .date-control { margin-bottom: 30px; display: inline-block; }
    .nav-link { text-decoration: none; color: var(--accent-cyan); font-weight: bold; margin: 0 20px; font-size: 18px; transition: color 0.3s; }
    .nav-link:hover { color: var(--accent-hover); text-shadow: 0 0 8px var(--accent-cyan); }

    .date-form-container {
        display: inline-block;
        background: rgba(255, 255, 255, 0.1);
        padding: 8px 15px;
        border-radius: 8px;
        border: 1px solid rgba(0, 229, 255, 0.3);
    }

    input[type="date"] { padding: 6px 10px; border-radius: 4px; border: 1px solid #ccc; }
    button { padding: 6px 20px; background-color: var(--accent-cyan); border: none; cursor: pointer; border-radius: 4px; font-weight: bold; }

    /* --- 集計ダッシュボード --- */
    .dashboard { display: flex; justify-content: center; gap: 20px; margin-bottom: 40px; }
    .status-card {
        background: var(--panel-bg);
        color: #333;
        padding: 15px 0;
        border-radius: 8px;
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

    table { width: 90%; margin: 0 auto; border-collapse: separate; background-color: var(--panel-bg); border-radius: 8px; overflow: hidden; }
    thead { background-color: var(--table-header); color: #fff; }
    th { padding: 15px; border-bottom: 2px solid var(--accent-cyan); }
    td { border-bottom: 1px solid #eee; padding: 15px; color: #333; text-align: center; }

    .time-text { font-family: 'Courier New', monospace; font-weight: bold; }
    .link-student { color: #052c48; font-weight: bold; text-decoration: none; }
    .home-link { text-decoration: none; color: var(--accent-cyan); display: inline-block; margin-top: 40px; }
</style>
</head>
<body>

    <h1>出席状況一覧</h1>

    <div class="date-control">
        <a href="<%= request.getContextPath() %>/AttManagementListServlet?targetDate=<%= request.getAttribute("prevDate") %>" class="nav-link">&lt; 前日</a>
        <div class="date-form-container">
            <form action="<%= request.getContextPath() %>/AttManagementListServlet" style="display: inline;">
                <input type="date" name="targetDate" value="<%= request.getAttribute("displayDate") %>">
                <button type="submit">表示</button>
            </form>
        </div>
        <a href="<%= request.getContextPath() %>/AttManagementListServlet?targetDate=<%= request.getAttribute("nextDate") %>" class="nav-link">翌日 &gt;</a>
    </div>

    <div class="dashboard">
        <div class="status-card card-present">
            <span class="status-label">出席</span>
            <span id="disp-present" class="count-number text-green">0名</span>
        </div>
        <div class="status-card card-late">
            <span class="status-label">遅刻</span>
            <span id="disp-late" class="count-number text-red">0名</span>
        </div>
        <div class="status-card card-early">
            <span class="status-label">早退</span>
            <span id="disp-early" class="count-number text-orange">0名</span>
        </div>
        <div class="status-card card-absent">
            <span class="status-label">欠席</span>
            <span id="disp-absent" class="count-number text-purple">0名</span>
        </div>
        <div class="status-card card-unregistered">
            <span class="status-label">未登録</span>
            <span id="disp-unregistered" class="count-number text-gray">0名</span>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th width="15%">学籍番号</th>
                <th width="25%">氏名</th>
                <th width="12%">出席時間</th>
                <th width="12%">退室時間</th>
                <th width="18%">状態</th>
                <th width="18%">備考</th> </tr>
        </thead>
        <tbody>
        <%
            int cPresent = 0, cLate = 0, cEarly = 0, cAbsent = 0, cUnreg = 0;

            List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("attendanceList");
            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> data : list) {
                    String checkIn = (String) data.get("checkInTime");
                    String checkOut = (String) data.get("checkOutTime");
                    String dbStatus = (String) data.get("status");
                    String certPath = (String) data.get("certificatePath"); // 追加
                    String statusText = (dbStatus != null) ? dbStatus : "未登録";

                    // --- 自動判定ロジック ---
                    if (checkIn != null && !checkIn.equals("--:--")) {
                        if (checkIn.compareTo("09:00") > 0) {
                            statusText = "遅刻";
                        } else {
                            statusText = "出席";
                        }
                    }
                    if (checkOut != null && !checkOut.equals("--:--") && checkOut.compareTo("18:00") < 0) {
                        statusText = "早退";
                    }

                    // --- カウント ---
                    if ("出席".equals(statusText)) cPresent++;
                    else if ("遅刻".equals(statusText)) cLate++;
                    else if ("早退".equals(statusText)) cEarly++;
                    else if ("欠席".equals(statusText)) cAbsent++;
                    else cUnreg++;

                    String statusClass = "text-gray";
                    if ("出席".equals(statusText)) statusClass = "text-green";
                    else if ("遅刻".equals(statusText)) statusClass = "text-red";
                    else if ("早退".equals(statusText)) statusClass = "text-orange";
                    else if ("欠席".equals(statusText)) statusClass = "text-purple";
        %>
            <tr>
                <td><a href="StudentHistoryServlet?userId=<%= data.get("userId") %>" class="link-student"><%= data.get("userId") %></a></td>
                <td><a href="StudentHistoryServlet?userId=<%= data.get("userId") %>" class="link-student"><%= data.get("userName") %></a></td>
                <td class="time-text"><%= checkIn %></td>
                <td class="time-text"><%= checkOut %></td>
                <td><span class="<%= statusClass %>" style="font-weight: bold;"><%= statusText %></span></td>
                <td>
                    <%-- 証明書パスが存在する場合のみ表示 --%>
                    <% if (certPath != null && !certPath.trim().isEmpty()) { %>
                        <span style="color: #333;">(あり)</span>
                    <% } %>
                </td>
            </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="home-link">ホームへ戻る</a>

    <script>
        document.getElementById('disp-present').innerText = '<%= cPresent %>名';
        document.getElementById('disp-late').innerText = '<%= cLate %>名';
        document.getElementById('disp-early').innerText = '<%= cEarly %>名';
        document.getElementById('disp-absent').innerText = '<%= cAbsent %>名';
        document.getElementById('disp-unregistered').innerText = '<%= cUnreg %>名';
    </script>

</body>
</html>