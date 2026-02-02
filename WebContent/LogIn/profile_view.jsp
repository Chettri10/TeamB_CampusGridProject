<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.UserDao" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // --- 1. セッションチェック ---
    String userId = (String) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/LogIn/login.jsp");
        return;
    }

    // --- 2. データベースからユーザー情報を取得 ---
    UserDao dao = new UserDao();
    // ★前回の NoSuchMethodError が出ている場合は、Eclipseで「プロジェクトのクリーン」と「サーバー再起動」を必ず行ってください
    Map<String, Object> userData = dao.getUserById(userId);

    // データ格納用変数の初期化
    String userName = "未設定";
    String email = "未登録";
    String phoneNumber = "未登録";
    String birthDate = "未登録";
    String routeInfo = "未登録";
    String roleName = "ゲスト";
    String roleValue = ""; // 役職判定用 (1:先生, 2:学生, 3:保護者)

    // データが取得できた場合、変数にセット
    if (userData != null) {
        if (userData.get("USER_NAME") != null) userName = (String) userData.get("USER_NAME");
        if (userData.get("EMAIL") != null) email = (String) userData.get("EMAIL");
        if (userData.get("PHONE_NUMBER") != null) phoneNumber = (String) userData.get("PHONE_NUMBER");
        if (userData.get("ROUTE_CONFIRMATION") != null) routeInfo = (String) userData.get("ROUTE_CONFIRMATION");

        // 生年月日のフォーマット
        if (userData.get("DATE_OF_BIRTH") != null) {
            birthDate = userData.get("DATE_OF_BIRTH").toString();
        }

        // --- 3. ROLE の判定と表示名の設定 ---
        if (userData.get("ROLE") != null) {
            roleValue = (String) userData.get("ROLE");

            if ("1".equals(roleValue)) {
                roleName = "先生";
            } else if ("2".equals(roleValue)) {
                roleName = "学生";
            } else if ("3".equals(roleValue)) {
                roleName = "保護者";
            } else {
                roleName = "その他";
            }
        }
    }

    // アイコン用の頭文字
    String initial = (userName.length() > 0) ? userName.substring(0, 1) : "U";
%>

<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>プロフィール詳細 - CAMPUS GRID</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
    :root {
        --bg-color: #020617;
        --card-bg: #1e293b;
        --text-color: #ffffff;
        --sub-text: #94a3b8;
        --accent-cyan: #00ffff;
        --border-color: rgba(255, 255, 255, 0.1);
    }

    body {
        background-color: var(--bg-color);
        color: var(--text-color);
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro JP", sans-serif;
        margin: 0; padding: 0;
        display: flex;
        justify-content: center;
        min-height: 100vh;
    }

    .container {
        width: 100%;
        max-width: 500px;
        padding: 20px;
        box-sizing: border-box;
    }

    /* ヘッダー */
    .page-header {
        display: flex;
        align-items: center;
        margin-bottom: 30px;
        padding-top: 10px;
    }
    .back-btn {
        color: var(--accent-cyan);
        text-decoration: none;
        font-size: 16px;
        display: flex;
        align-items: center;
        gap: 5px;
        font-weight: bold;
        transition: opacity 0.2s;
        cursor: pointer;
    }
    .back-btn:hover { opacity: 0.8; }

    .page-title {
        flex-grow: 1;
        text-align: center;
        margin: 0;
        font-size: 18px;
        font-weight: bold;
        padding-right: 50px;
    }

    /* アバターエリア */
    .profile-top {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 30px;
    }
    .avatar-large {
        width: 90px;
        height: 90px;
        background: linear-gradient(135deg, #00c6fb, #005bea);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 36px;
        font-weight: bold;
        color: #fff;
        box-shadow: 0 0 20px rgba(0, 255, 255, 0.2);
        margin-bottom: 15px;
    }
    .user-name-large {
        font-size: 22px;
        font-weight: bold;
        margin-bottom: 5px;
    }
    .role-badge {
        background: rgba(0, 255, 255, 0.1);
        color: var(--accent-cyan);
        border: 1px solid rgba(0, 255, 255, 0.3);
        font-size: 13px;
        padding: 4px 15px;
        border-radius: 20px;
        font-weight: bold;
        margin-top: 5px;
    }

    /* 情報リスト */
    .info-card {
        background: var(--card-bg);
        border-radius: 20px;
        padding: 10px 20px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
    }

    .info-row {
        display: flex;
        flex-direction: column;
        padding: 15px 0;
        border-bottom: 1px solid var(--border-color);
    }
    /* 最後の要素の下線は消すが、条件分岐が入るためCSSでの制御が難しい場合がある。
       見た目を崩さないよう、JSやCSSでの調整も可能だが、ここではシンプルにする */
    .info-row:last-child { border-bottom: none; }

    .info-label {
        font-size: 13px;
        color: var(--sub-text);
        margin-bottom: 6px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .info-label i {
        color: var(--accent-cyan);
        width: 16px;
        text-align: center;
    }

    .info-value {
        font-size: 16px;
        font-weight: 500;
        padding-left: 28px;
        word-break: break-all;
    }

    .route-text { color: #e2e8f0; line-height: 1.5; }

    /* アクションボタン */
    .action-area { margin-top: 30px; }
    .btn-edit {
        display: block;
        width: 100%;
        padding: 15px;
        background: var(--accent-cyan);
        color: #020617;
        text-align: center;
        text-decoration: none;
        font-weight: bold;
        border-radius: 50px;
        box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3);
        transition: transform 0.2s;
    }
    .btn-edit:active { transform: scale(0.98); }
</style>
</head>
<body>

    <div class="container">
        <div class="page-header">
            <a href="#" onclick="window.history.back(); return false;" class="back-link back-btn">
                <i class="fas fa-chevron-left"></i> 戻る
            </a>
            <h1 class="page-title">プロフィール詳細</h1>
        </div>

        <div class="profile-top">
            <div class="avatar-large"><%= initial %></div>
            <div class="user-name-large"><%= userName %></div>
            <div class="role-badge"><%= roleName %></div>
        </div>

        <div class="info-card">

            <div class="info-row">
                <div class="info-label"><i class="fas fa-id-card"></i> ユーザーID</div>
                <div class="info-value"><%= userId %></div>
            </div>

            <div class="info-row">
                <div class="info-label"><i class="fas fa-envelope"></i> メールアドレス</div>
                <div class="info-value"><%= email %></div>
            </div>

            <div class="info-row">
                <div class="info-label"><i class="fas fa-phone"></i> 電話番号</div>
                <div class="info-value"><%= phoneNumber %></div>
            </div>

            <div class="info-row">
                <div class="info-label"><i class="fas fa-birthday-cake"></i> 生年月日</div>
                <div class="info-value"><%= birthDate %></div>
            </div>

            <% if ("2".equals(roleValue)) { %>
            <div class="info-row">
                <div class="info-label"><i class="fas fa-train"></i> 路線情報</div>
                <div class="info-value route-text"><%= routeInfo %></div>
            </div>
            <% } %>
            </div>

    </div>

</body>
</html>