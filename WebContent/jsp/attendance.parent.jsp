<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>出席状況 - キャンパスグリッド</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background-color: #030820;
            color: #FFFFFF;
            font-family: 'Noto Sans JP', sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
        }
        .container {
            width: 100%;
            max-width: 800px;
        }
        .card {
            background: #FFF;
            color: #333;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.5);
        }
        h2 { color: #00E5FF; margin-top: 0; border-bottom: 2px solid #eee; padding-bottom: 10px; }

        /* テーブルデザイン */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f0f9ff; color: #333; font-weight: bold; }
        tr:last-child td { border-bottom: none; }

        /* ステータスバッジ */
        .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; display: inline-block; }
        .status-present { background-color: #d1fae5; color: #065f46; } /* 緑 */
        .status-absent { background-color: #fee2e2; color: #991b1b; }  /* 赤 */
        .status-late { background-color: #fef3c7; color: #92400e; }    /* 黄 */

        .back-btn {
            display: inline-block;
            margin-top: 20px;
            color: #69F0AE;
            text-decoration: none;
            font-weight: bold;
        }
        .back-btn:hover { text-decoration: underline; }

        .no-data { text-align: center; color: #777; padding: 20px; }
    </style>
</head>
<body>

    <%
        // データの受け取り
        String childId = (String) request.getAttribute("childId");
        List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("attendanceList");
        String errorMsg = (String) request.getAttribute("errorMsg");

        SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy/MM/dd");
        SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm");
    %>

    <div class="container">
        <div class="card">
            <h2><i class="fas fa-child"></i> お子様の出席記録</h2>
            <% if (errorMsg != null) { %>
                <p style="color: red;"><%= errorMsg %></p>
            <% } else { %>
                <p>学生ID: <strong><%= childId != null ? childId : "未設定" %></strong></p>
            <% } %>
        </div>

        <div class="card">
            <% if (list != null && list.size() > 0) { %>
                <table>
                    <thead>
                        <tr>
                            <th>日付</th>
                            <th>状態</th>
                            <th>時間</th>
                            <th>理由</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> record : list) {
                             String status = (String) record.get("Status");
                             // バッジの色分け
                             String badgeClass = "status-badge ";
                             if ("出席".equals(status)) badgeClass += "status-present";
                             else if ("欠席".equals(status)) badgeClass += "status-absent";
                             else if ("遅刻".equals(status)) badgeClass += "status-late";
                             else badgeClass += "status-present";

                             // 時間の整形 (登校 - 下校)
                             String inTime = record.get("Check_In_Time") != null ? sdfTime.format(record.get("Check_In_Time")) : "--:--";
                             String outTime = record.get("Check_Out_Time") != null ? sdfTime.format(record.get("Check_Out_Time")) : "--:--";
                        %>
                        <tr>
                            <td><%= sdfDate.format(record.get("Target_Date")) %></td>
                            <td><span class="<%= badgeClass %>"><%= status %></span></td>
                            <td><%= inTime %> ～ <%= outTime %></td>
                            <td><%= record.get("Absence_Reason") != null ? record.get("Absence_Reason") : "-" %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="no-data">出席データがまだありません。</div>
            <% } %>
        </div>

        <div style="text-align: center;">
            <a href="parent_home.jsp" class="back-btn"><i class="fas fa-arrow-left"></i> メニューへ戻る</a>
        </div>
    </div>

</body>
</html>