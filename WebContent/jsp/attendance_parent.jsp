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

    // 日付フォーマット（表示用）
    SimpleDateFormat sdfDateDisplay = new SimpleDateFormat("MM/dd (E)", Locale.JAPAN);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>出席状況一覧 - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    /* --- iPhone 14 Pro Max (430px) 最適化設定 --- */
    :root {
        --sat: env(safe-area-inset-top, 50px);
        --sab: env(safe-area-inset-bottom, 34px);
    }

    * { box-sizing: border-box; }

    html {
        background-color: #000; /* 枠外は黒 */
        height: 100%;
    }

    body {
        background-color: #020617;
        color: white;
        font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
        margin: 0 auto;
        padding: 0;
        text-align: center;

        /* iPhone 14 Pro Max 幅固定 */
        max-width: 430px;
        min-height: 100vh;
        position: relative;
        box-shadow: 0 0 50px rgba(0,0,0,0.5);

        /* Dynamic Island + ヘッダー分の余白 */
        padding-top: calc(var(--sat) + 60px);
        padding-bottom: calc(var(--sab) + 20px);
    }

    /* --- ヘッダーエリア（戻るボタンを含む） --- */
    .header-nav {
        position: absolute;
        top: calc(var(--sat) + 10px);
        left: 0;
        width: 100%;
        padding: 0 20px;
        display: flex;
        justify-content: flex-start; /* 左寄せ */
        z-index: 100;
    }

    .back-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        background: rgba(21, 31, 66, 0.8);
        color: #00ffff;
        text-decoration: none;
        border-radius: 20px;
        font-weight: bold;
        font-size: 14px;
        backdrop-filter: blur(4px);
        transition: 0.2s;
        border: 1px solid rgba(0, 255, 255, 0.2);
    }
    .back-btn:active { background: rgba(0, 255, 255, 0.1); }

    h1 {
        color: #00ffff;
        font-size: 24px;
        margin: 10px 0 5px 0;
        font-weight: 900;
        letter-spacing: 1px;
    }
    .sub-title {
        color: #94a3b8;
        font-size: 13px;
        margin-bottom: 25px;
    }

    .container {
        width: 100%;
        padding: 0 20px;
    }

    /* エラーメッセージ */
    .error-msg {
        color: #ff5252;
        margin-bottom: 20px;
        background: rgba(255, 82, 82, 0.1);
        padding: 10px;
        border-radius: 8px;
        font-size: 14px;
    }

    /* --- カード型リストデザイン --- */
    .record-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .record-card {
        background-color: #1e293b; /* カード背景 */
        border-radius: 16px;
        padding: 16px;
        text-align: left;
        border: 1px solid rgba(255,255,255,0.05);
        box-shadow: 0 4px 6px rgba(0,0,0,0.2);
    }

    /* カード上部：日付とステータス */
    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
        padding-bottom: 8px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }

    .record-date {
        font-size: 16px;
        font-weight: bold;
        color: white;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .record-date i { color: #00ffff; font-size: 14px; }

    /* ステータスバッジ */
    .status-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 20px;
        color: white;
        font-size: 11px;
        font-weight: bold;
        min-width: 60px;
        text-align: center;
    }
    .status-present { background-color: #00c853; box-shadow: 0 0 5px rgba(0,200,83,0.4); }
    .status-late { background-color: #ffb300; color: #000; }
    .status-absent { background-color: #ff5252; }
    .status-early { background-color: #ff9800; color: #000; }
    .status-none { background-color: #64748b; }

    /* 時間表示エリア */
    .time-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
        margin-bottom: 10px;
    }
    .time-box {
        background: rgba(0,0,0,0.2);
        padding: 8px;
        border-radius: 8px;
        text-align: center;
    }
    .time-label {
        font-size: 10px;
        color: #94a3b8;
        display: block;
        margin-bottom: 2px;
        font-weight: bold;
    }
    .time-value {
        font-size: 18px;
        font-weight: bold;
        letter-spacing: 0.5px;
        font-family: monospace; /* 数字を等幅に */
    }
    .time-in { color: #00c853; }
    .time-out { color: #ff5252; }
    .time-empty { color: #64748b; font-size: 14px; }

    /* 理由表示 */
    .reason-box {
        font-size: 13px;
        color: #cbd5e1;
        background: rgba(255,255,255,0.05);
        padding: 8px 12px;
        border-radius: 8px;
        line-height: 1.5;
        margin-top: 5px;
    }
    .reason-label {
        color: #94a3b8;
        font-size: 10px;
        margin-right: 5px;
        font-weight: bold;
    }

</style>
</head>
<body>

    <div class="header-nav">
        <a href="<%= request.getContextPath() %>/LogIn/parent_home.jsp" class="back-btn">
            <i class="fas fa-chevron-left"></i> ホームに戻る
        </a>
    </div>

    <h1>学生出席状況</h1>
    <div class="sub-title">学生ID: <%= childId != null ? childId : "不明" %></div>

    <div class="container">
        <% if (errorMsg != null) { %>
            <div class="error-msg"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
        <% } %>

        <% if (attendanceList != null && !attendanceList.isEmpty()) { %>
            <div class="record-list">
                <% for (Map<String, Object> record : attendanceList) {
                    String status = (String) record.get("Status");

                    // 文字列置換ロジック (維持)
                    if (status != null) {
                        status = status.replace("早退・遅刻", "遅刻・早退");
                    }

                    Object dateObj = record.get("Target_Date");
                    Object inTimeObj = record.get("Check_In_Time");
                    Object outTimeObj = record.get("Check_Out_Time");
                    String reason = (String) record.get("Absence_Reason");

                    // バッジの色判定
                    String badgeClass = "status-present";
                    if (status == null || status.equals("未登録")) badgeClass = "status-none";
                    else if (status.contains("欠席")) badgeClass = "status-absent";
                    else if (status.contains("遅刻")) badgeClass = "status-late";
                    else if (status.contains("早退")) badgeClass = "status-early";
                %>

                <div class="record-card">
                    <div class="card-header">
                        <div class="record-date">
                            <i class="far fa-calendar-alt"></i>
                            <%= dateObj != null ? dateObj.toString() : "" %>
                        </div>
                        <span class="status-badge <%= badgeClass %>">
                            <%= status != null ? status : "未登録" %>
                        </span>
                    </div>

                    <div class="time-container">
                        <div class="time-box">
                            <span class="time-label">登校</span>
                            <% if(inTimeObj != null) { %>
                                <span class="time-value time-in"><%= sdfTime.format(inTimeObj) %></span>
                            <% } else { %>
                                <span class="time-value time-empty">--:--</span>
                            <% } %>
                        </div>
                        <div class="time-box">
                            <span class="time-label">退室</span>
                            <% if(outTimeObj != null) { %>
                                <span class="time-value time-out"><%= sdfTime.format(outTimeObj) %></span>
                            <% } else { %>
                                <span class="time-value time-empty">--:--</span>
                            <% } %>
                        </div>
                    </div>

                    <% if (reason != null && !reason.trim().isEmpty()) { %>
                        <div class="reason-box">
                            <span class="reason-label"><i class="fas fa-comment-alt"></i> 理由</span>
                            <%= reason %>
                        </div>
                    <% } %>
                </div>

                <% } %>
            </div>
        <% } else { %>
            <div style="margin-top: 50px; color: #64748b;">
                <i class="fas fa-history" style="font-size: 40px; margin-bottom: 15px; display: block;"></i>
                <p>出席データが見つかりません</p>
            </div>
        <% } %>
    </div>

</body>
</html>