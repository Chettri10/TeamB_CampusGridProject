<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        margin: 10px 0 20px 0;
        font-weight: 900;
        letter-spacing: 1px;
    }

    /* --- 学生情報カード --- */
    .student-info-card {
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(0, 255, 255, 0.3);
        border-radius: 16px;
        padding: 15px 20px;
        margin: 0 20px 25px 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 5px;
    }
    .student-name {
        font-size: 18px;
        font-weight: bold;
        color: #fff;
    }
    .student-id {
        font-size: 13px;
        color: #94a3b8;
    }

    /* --- カード型リストエリア --- */
    .list-container {
        width: 100%;
        padding: 0 20px;
        display: flex;
        flex-direction: column;
        gap: 15px;
    }

    .job-card {
        background-color: #1e293b;
        border-radius: 16px;
        padding: 16px;
        text-align: left;
        border: 1px solid rgba(255,255,255,0.05);
        box-shadow: 0 4px 6px rgba(0,0,0,0.2);
        position: relative;
    }

    /* カードヘッダー：会社名と日付 */
    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 10px;
    }
    .company-name {
        font-size: 18px;
        font-weight: bold;
        color: white;
        line-height: 1.4;
        flex: 1;
        margin-right: 10px;
    }
    .regist-date {
        font-size: 11px;
        color: #94a3b8;
        white-space: nowrap;
        margin-top: 4px;
    }

    /* ステータスバッジ */
    .status-badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: bold;
        color: white;
        background-color: #64748b; /* デフォルト */
        margin-bottom: 12px;
    }
    .status-badge[data-status="内定獲得"] { background-color: #00c853; box-shadow: 0 0 8px rgba(0, 200, 83, 0.3); }
    .status-badge[data-status="選考"] { background-color: #0288d1; }
    .status-badge[data-status="書類提出済"] { background-color: #0288d1; }
    .status-badge[data-status="辞退"] { background-color: #ff5252; }

    /* 備考エリア */
    .notes-box {
        background: rgba(0, 0, 0, 0.2);
        padding: 10px;
        border-radius: 8px;
        font-size: 14px;
        color: #cbd5e1;
        line-height: 1.5;
    }
    .notes-label {
        font-size: 10px;
        color: #94a3b8;
        font-weight: bold;
        display: block;
        margin-bottom: 4px;
    }

    /* --- メッセージ --- */
    .no-data {
        padding: 50px 20px;
        color: #64748b;
        text-align: center;
    }
    .no-data i {
        font-size: 40px;
        margin-bottom: 15px;
        display: block;
    }

</style>
</head>
<body>

    <div class="header-nav">
        <a href="<%= request.getContextPath() %>/LogIn/parent_home.jsp" class="back-btn">
            <i class="fas fa-chevron-left"></i> ホームに戻る
        </a>
    </div>

    <h1>就活情報確認</h1>

    <div class="student-info-card">
        <div class="student-name">
            <i class="fas fa-user-graduate"></i> <%= (studentName != null) ? studentName : "学生情報なし" %>
        </div>
        <div class="student-id">ID: <%= (studentId != null) ? studentId : "--" %></div>
    </div>

    <div class="list-container">
        <%
        if (attendanceList != null && !attendanceList.isEmpty()) {
            for (Map<String, Object> row : attendanceList) {
                String status = (String)row.get("progress");
                if(status == null) status = "未登録";
                String company = (String)row.get("company");
                String date = (String)row.get("date");
                String notes = (String)row.get("notes");
        %>
            <div class="job-card">
                <div class="card-header">
                    <div class="company-name"><%= company != null ? company : "--" %></div>
                    <div class="regist-date"><%= date != null ? date : "--" %></div>
                </div>

                <span class="status-badge" data-status="<%= status %>"><%= status %></span>

                <% if (notes != null && !notes.trim().isEmpty()) { %>
                    <div class="notes-box">
                        <span class="notes-label"><i class="fas fa-pen"></i> 備考</span>
                        <%= notes %>
                    </div>
                <% } else { %>
                    <div class="notes-box" style="color:#64748b; font-style:italic;">
                        備考なし
                    </div>
                <% } %>
            </div>
        <%
            }
        } else {
        %>
            <div class="no-data">
                <i class="fas fa-briefcase"></i>
                <p>まだ登録された就活情報はありません。</p>
            </div>
        <% } %>
    </div>

</body>
</html>