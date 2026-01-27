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
        --status-blue: #00b0ff; /* 公欠用の青色を追加 */
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
    .text-blue { color: var(--status-blue); } /* 公欠テキスト用 */
    .text-gray { color: #666; }

    table { width: 90%; margin: 0 auto; border-collapse: separate; background-color: var(--panel-bg); border-radius: 8px; overflow: hidden; }
    thead { background-color: var(--table-header); color: #fff; }
    th { padding: 15px; border-bottom: 2px solid var(--accent-cyan); }
    td { border-bottom: 1px solid #eee; padding: 15px; color: #333; text-align: center; vertical-align: middle; }

    .time-text { font-family: 'Courier New', monospace; font-weight: bold; }
    .link-student { color: #052c48; font-weight: bold; text-decoration: none; }
    .home-link { text-decoration: none; color: var(--accent-cyan); display: inline-block; margin-top: 40px; }

    .btn-edit {
        background-color: var(--accent-cyan);
        color: var(--bg-main);
        padding: 6px 15px;
        text-decoration: none;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        transition: all 0.3s;
        display: inline-block;
    }
    .btn-edit:hover {
        background-color: var(--accent-hover);
        box-shadow: 0 0 10px var(--accent-cyan);
        transform: scale(1.05);
    }
    .text-disabled { color: #ccc; font-size: 0.85em; }
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
            <span class="status-label">欠席/公欠</span>
            <span class="count-number text-purple"><%= (int)request.getAttribute("countAbsent") %>名</span>
        </div>
        <div class="status-card card-unregistered">
            <span class="status-label">未登録</span>
            <span class="count-number text-gray"><%= request.getAttribute("countUnregistered") %>名</span>
        </div>
    </div>

    <table>
        <thead>
            <tr>
                <th width="12%">学籍番号</th>
                <th width="18%">氏名</th>
                <th width="12%">出席時間</th>
                <th width="12%">退室時間</th>
                <th width="15%">状態</th>
                <th width="17%">備考</th>
                <th width="14%">未登録編集</th>
            </tr>
        </thead>
        <tbody>
        <%
            Object displayDateObj = request.getAttribute("displayDate");
            Object todayObj = request.getAttribute("today");
            String displayDateStr = (displayDateObj != null) ? displayDateObj.toString() : "";
            String todayStr = (todayObj != null) ? todayObj.toString() : "";
            boolean isToday = displayDateStr.equals(todayStr);

            List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("attendanceList");
            if (list != null && !list.isEmpty()) {
                for (Map<String, Object> data : list) {
                    String statusText = (String) data.get("status");
                    String checkIn = (String) data.get("checkInTime");
                    String checkOut = (String) data.get("checkOutTime");
                    String certPath = (String) data.get("certificatePath");

                    // ★ 理由の取得
                    String reason = (String) data.get("reason");
                    if (reason == null) reason = "";

                    // 色分け判定の修正
                    String statusClass = "text-gray";
                    if ("出席".equals(statusText)) statusClass = "text-green";
                    else if ("遅刻".equals(statusText) || "早退・遅刻".equals(statusText)) statusClass = "text-red";
                    else if ("早退".equals(statusText)) statusClass = "text-orange";
                    else if ("欠席".equals(statusText)) statusClass = "text-purple";
                    else if ("公欠".equals(statusText)) statusClass = "text-blue"; // 公欠は青色

                    // ★ 編集可能判定: 「今日」or「未登録」or「公欠」
                    boolean canEdit = isToday || "未登録".equals(statusText) || "公欠".equals(statusText);
        %>
            <tr>
                <td><a href="StudentHistoryServlet?userId=<%= data.get("userId") %>" class="link-student"><%= data.get("userId") %></a></td>
                <td><a href="StudentHistoryServlet?userId=<%= data.get("userId") %>" class="link-student"><%= data.get("userName") %></a></td>
                <td class="time-text"><%= (checkIn != null) ? checkIn : "" %></td>
                <td class="time-text"><%= (checkOut != null) ? checkOut : "" %></td>
                <td><span class="<%= statusClass %>" style="font-weight: bold;"><%= statusText %></span></td>

                <td style="text-align: left; font-size: 0.9em;">
                    <% if (certPath != null && !certPath.trim().isEmpty()) { %>
                        <div style="color: var(--accent-cyan); font-weight: bold; font-size: 0.8em; margin-bottom: 2px;">
                            <i class="fas fa-file-alt"></i> [証明書あり]
                        </div>
                    <% } %>
                    <%= reason %>
                </td>
                <td>
                    <% if (canEdit) { %>
                        <a href="AttManagementEditServlet?userId=<%= data.get("userId") %>&targetDate=<%= displayDateStr %>" class="btn-edit">編集</a>
                    <% } else { %>
                        <span class="text-disabled">編集不可</span>
                    <% } %>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="7">データがありません。</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <a href="<%= request.getContextPath() %>/LogIn/teacher_home.jsp" class="home-link">ホームへ戻る</a>

</body>
</html>