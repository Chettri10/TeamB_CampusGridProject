<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.AttendanceDao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>提出画像・遅延証明書一覧</title>
<style>
    body { font-family: "Helvetica Neue", Arial, sans-serif; background-color: #f4f4f9; padding: 20px; text-align: center; }
    h2 { color: #333; margin-bottom: 30px; }

    .gallery { display: flex; flex-wrap: wrap; justify-content: center; gap: 20px; }

    .card {
        background: white; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        width: 300px; overflow: hidden; text-align: left; transition: transform 0.2s;
        border: 1px solid #ddd;
    }
    .card:hover { transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0,0,0,0.15); }

    .img-container {
        width: 100%; height: 200px; background-color: #eee; border-bottom: 1px solid #ddd;
    }
    img { width: 100%; height: 100%; object-fit: cover; cursor: pointer; }

    .info { padding: 15px; }

    .user-header { display: flex; align-items: center; margin-bottom: 12px; border-bottom: 1px solid #eee; padding-bottom: 8px; }
    .user-icon {
        width: 45px; height: 45px; background-color: #007bff; color: white;
        border-radius: 50%; display: flex; align-items: center; justify-content: center;
        font-weight: bold; font-size: 20px; margin-right: 12px;
    }
    .user-meta { display: flex; flex-direction: column; }
    .user-name { font-weight: bold; font-size: 16px; color: #333; }
    .user-id { font-size: 12px; color: #888; }

    .detail-row { font-size: 14px; margin-bottom: 6px; color: #555; }
    .label { font-weight: bold; color: #888; font-size: 11px; display: inline-block; width: 40px; }
    .reason-tag {
        background-color: #fff3cd; color: #856404; padding: 4px 10px; border-radius: 4px;
        font-weight: bold; display: block; margin-top: 8px; text-align: center;
    }

    button {
        padding: 12px 30px; font-size: 16px; margin-top: 30px; cursor: pointer;
        background-color: #28a745; color: white; border: none; border-radius: 5px;
    }
</style>
</head>
<body>
    <h2>📸 提出画像・遅延証明書一覧</h2>

    <div class="gallery">
        <%
            AttendanceDao dao = new AttendanceDao();
            // 写真があるデータを全員分取得
            List<Map<String, String>> list = dao.getRecordsWithImages();

            if (list != null && list.size() > 0) {
                for (Map<String, String> record : list) {
                    // 画像パスの調整 ("uploads/..." -> "../uploads/...")
                    String imgPath = "../" + record.get("image");
                    String userId = record.get("id");
                    String userName = record.get("userName"); // ★DAOから取得した名前
                    String datetime = record.get("datetime");
                    String status = record.get("status");
                    String reason = record.get("reason");
                    if(reason == null || reason.isEmpty()) reason = "(理由なし)";
        %>
            <div class="card">
                <div class="img-container">
                    <a href="<%= imgPath %>" target="_blank">
                        <img src="<%= imgPath %>" title="クリックで拡大">
                    </a>
                </div>

                <div class="info">
                    <div class="user-header">
                        <div class="user-icon"><%= userName.substring(0, 1) %></div>
                        <div class="user-meta">
                            <span class="user-name"><%= userName %></span>
                            <span class="user-id">ID: <%= userId %></span>
                        </div>
                    </div>

                    <div class="detail-row"><span class="label">日時</span> <%= datetime %></div>
                    <div class="detail-row"><span class="label">状態</span> <%= status %></div>

                    <div class="reason-tag">理由: <%= reason %></div>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <p style="color:#888; font-size:18px; margin-top:50px;">現在、アップロードされた写真はありません。</p>
        <%
            }
        %>
    </div>

    <br>
    <button onclick="location.reload()">🔄 最新の状態に更新</button>
</body>
</html>