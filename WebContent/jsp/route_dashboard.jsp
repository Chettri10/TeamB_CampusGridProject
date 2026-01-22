<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="60"> <title>Campus Grid - 運行状況モニター</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<style>
    body { font-family: "Helvetica Neue", Arial, sans-serif; background-color: #111827; color: #f3f4f6; margin: 0; padding: 20px; }

    header { text-align: center; margin-bottom: 30px; }
    h2 { font-size: 24px; color: #fff; display: inline-block; border-bottom: 2px solid #3b82f6; padding-bottom: 5px; }
    .last-update { font-size: 12px; color: #9ca3af; margin-top: 5px; }

    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 20px;
        max-width: 1200px;
        margin: 0 auto;
    }

    /* カードのスタイル */
    .route-card {
        background-color: #1f2937;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        border-left: 6px solid #4b5563;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        min-height: 160px;
        transition: transform 0.2s;
    }
    .route-card:hover { transform: translateY(-5px); box-shadow: 0 10px 15px rgba(0,0,0,0.5); }

    .line-name { font-size: 18px; font-weight: bold; margin-bottom: 15px; color: #e5e7eb; border-bottom: 1px solid #374151; padding-bottom: 10px; }
    .line-name i { margin-right: 8px; color: #3b82f6; }

    /* 状態表示バッジ */
    .status-badge {
        font-size: 18px; font-weight: bold; color: #fff;
        text-align: center; padding: 10px; border-radius: 8px;
        background-color: rgba(255,255,255,0.05); margin-bottom: 15px;
        letter-spacing: 1px;
    }

    .user-info { font-size: 12px; color: #9ca3af; margin-bottom: 15px; }
    .user-count { font-weight: bold; color: #d1d5db; }

    /* 詳細ボタン */
    .detail-link { text-align: center; margin-top: auto; }
    .detail-link a {
        color: #60a5fa; font-size: 13px; text-decoration: none;
        border: 1px solid #60a5fa; padding: 6px 15px; border-radius: 20px;
        transition: 0.3s; display: inline-block;
    }
    .detail-link a:hover { background-color: #60a5fa; color: #000; }

    /* 状態別の色設定 */
    /* 平常 */
    .status-normal { border-left-color: #10b981; }
    .status-normal .status-badge { color: #10b981; background-color: rgba(16, 185, 129, 0.1); }
    .status-normal .line-name i { color: #10b981; }

    /* 遅延・乱れ */
    .status-delay { border-left-color: #f59e0b; }
    .status-delay .status-badge { color: #f59e0b; background-color: rgba(245, 158, 11, 0.1); animation: pulse 2s infinite; }
    .status-delay .line-name i { color: #f59e0b; }

    /* 見合わせ・運休 */
    .status-stop { border-left-color: #ef4444; }
    .status-stop .status-badge { color: #ef4444; background-color: rgba(239, 68, 68, 0.1); }
    .status-stop .line-name i { color: #ef4444; }

    @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
</style>
</head>
<body>

    <header>
        <h2><i class="fas fa-desktop"></i> 運行状況モニター</h2>
        <div class="last-update">自動更新中 (60秒間隔) - 最終取得: <%= new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date()) %></div>
    </header>

    <div class="dashboard-grid">
        <%
            List<Map<String, String>> list = (List<Map<String, String>>) request.getAttribute("routeList");
            if (list != null && list.size() > 0) {
                for (Map<String, String> route : list) {
                    String status = route.get("status");
                    String lineName = route.get("lineName");
                    String userName = route.get("userName");
                    String userId = route.get("userId");

                    String cardClass = "route-card";
                    if (status.contains("平常")) {
                        cardClass += " status-normal";
                    } else if (status.contains("遅延") || status.contains("遅れ") || status.contains("乱れ")) {
                        cardClass += " status-delay";
                    } else if (status.contains("見合わせ") || status.contains("運休")) {
                        cardClass += " status-stop";
                    }
        %>

        <div class="<%= cardClass %>">
            <div class="line-name"><i class="fas fa-subway"></i> <%= lineName %></div>

            <div class="status-badge"><%= status %></div>

            <div class="user-info">
                利用学生: <span class="user-count"><%= userName %></span> (<%= userId %>)
            </div>

            <div class="detail-link">
                <a href="https://transit.yahoo.co.jp/diainfo/area/4" target="_blank">
                    <i class="fas fa-external-link-alt"></i> 詳細を確認
                </a>
            </div>
        </div>

        <%
                }
            } else {
        %>
            <div style="color: #666; grid-column: 1/-1; text-align: center; padding: 50px;">
                登録されている路線がありません
            </div>
        <%
            }
        %>
    </div>

</body>
</html>